#!/usr/bin/env python3
"""Regenerate `guix-hermes/packages/python-hermes-deps.scm` from the
upstream `uv.lock` vendored under `.upstream/`.

This is the channel's analogue of nixpkgs' uv2nix — but tiny, because
the lockfile already carries every (name, version, url, sha256) we
need.  No PyPI walks, no resolution.

Usage:
    guix shell python python-packaging -- python3 scripts/regen-deps.py

Inputs:
    .upstream/uv.lock                    pinned at a known upstream ref
    --extras=messaging                   chosen optional groups

Outputs:
    guix-hermes/packages/python-hermes-deps.scm

What the generator does NOT do (intentional Phase 2 limits):
    - synopses / descriptions / home-pages       → all placeholder
    - licenses                                   → defaults to MIT
    - per-package build-backend overrides        → autodetect
    - native-inputs / test deps                  → tests disabled
    - upstream-Guix package substitution         → Phase 3
These are addressed in Phase 3 when we iterate `guix build`.
"""

from __future__ import annotations

import argparse
import sys
import tomllib
from pathlib import Path
from textwrap import indent

REPO_ROOT = Path(__file__).resolve().parent.parent
LOCKFILE = REPO_ROOT / ".upstream" / "uv.lock"
LOCKFILE_PYPROJECT = REPO_ROOT / ".upstream" / "pyproject.toml"
OUTPUT = REPO_ROOT / "guix-hermes" / "packages" / "python-hermes-deps.scm"

ENV = {
    "sys_platform": "linux",
    "platform_system": "Linux",
    "platform_machine": "x86_64",
    "python_version": "3.12",
    "python_full_version": "3.12.0",
    "implementation_name": "cpython",
    "platform_python_implementation": "CPython",
}

NIX_BASE32 = "0123456789abcdfghijklmnpqrsvwxyz"


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------


def normalize(name: str) -> str:
    """PEP 503 normalization."""
    return name.lower().replace("_", "-").replace(".", "-")


def guix_name(pypi_name: str) -> str:
    """Convert a PyPI package name to its Guix convention name.

    Examples:
        pydantic          → python-pydantic
        pydantic_core     → python-pydantic-core
        python-telegram-bot → python-python-telegram-bot
    """
    norm = normalize(pypi_name)
    return f"python-{norm}"


def nix_base32(b: bytes) -> str:
    """Encode bytes as Nix's base32 (Guix's `(base32 \"…\")` format).

    The encoding is *not* RFC4648 base32 — it uses a 32-char alphabet
    (digits + lowercase letters minus e/o/t/u to reduce typo confusion)
    and a non-standard bit-grouping derived from Nix's source.
    """
    length = (len(b) * 8 - 1) // 5 + 1
    out = []
    for n in range(length - 1, -1, -1):
        b_idx = n * 5 // 8
        b_off = n * 5 % 8
        c = b[b_idx] >> b_off
        if b_idx + 1 < len(b):
            c |= b[b_idx + 1] << (8 - b_off)
        out.append(NIX_BASE32[c & 0x1F])
    return "".join(out)


def hex_to_nix_base32(hex_str: str) -> str:
    return nix_base32(bytes.fromhex(hex_str))


# ---------------------------------------------------------------------------
# marker evaluation
# ---------------------------------------------------------------------------


def eval_marker(marker: str) -> bool:
    if not marker:
        return True
    s = marker.strip()
    if "extra ==" in s or "extra !=" in s:
        return False
    try:
        import packaging.markers
        return packaging.markers.Marker(s).evaluate(ENV)
    except ImportError:
        pass
    except Exception as exc:
        print(f"warning: marker '{s}' failed ({exc}); keeping",
              file=sys.stderr)
        return True
    return _eval_marker_manual(s)


def _eval_marker_manual(s: str) -> bool:
    s = s.strip()
    if s.startswith("sys_platform == "):
        rhs = s.split("==", 1)[1].strip().strip("'\"")
        return ENV["sys_platform"] == rhs
    if s.startswith("sys_platform != "):
        rhs = s.split("!=", 1)[1].strip().strip("'\"")
        return ENV["sys_platform"] != rhs
    if s.startswith("python_full_version >= "):
        rhs = s.split(">=", 1)[1].strip().strip("'\"")
        return tuple(map(int, ENV["python_full_version"].split("."))) >= \
               tuple(map(int, rhs.split(".")))
    if s.startswith("python_full_version < "):
        rhs = s.split("<", 1)[1].strip().strip("'\"")
        return tuple(map(int, ENV["python_full_version"].split("."))) < \
               tuple(map(int, rhs.split(".")))
    if "extra ==" in s or "extra !=" in s:
        return False
    print(f"warning: unrecognised marker '{s}'; keeping",
          file=sys.stderr)
    return True


# ---------------------------------------------------------------------------
# closure walk
# ---------------------------------------------------------------------------


def closure(packages: dict, extras: list[str]) -> dict[str, dict]:
    hermes = packages["hermes-agent"]
    queue = list(hermes.get("dependencies", []))
    for extra in extras:
        queue.extend(hermes.get("optional-dependencies", {}).get(extra, []))

    visited: dict[str, dict] = {}
    while queue:
        dep = queue.pop()
        name = normalize(dep["name"])
        if name in visited:
            continue
        if not eval_marker(dep.get("marker", "")):
            continue
        if name not in packages:
            print(f"warning: dep '{name}' not in lockfile (skipping)",
                  file=sys.stderr)
            continue
        pkg = packages[name]
        visited[name] = pkg
        for d in pkg.get("dependencies", []):
            queue.append(d)
    visited.pop("hermes-agent", None)
    return visited


# ---------------------------------------------------------------------------
# source picking — prefer sdist for Guix's build-from-source ethos.
# ---------------------------------------------------------------------------


def pick_source(pkg: dict) -> tuple[str, str, str]:
    """Return (url, sha256_hex, kind) where kind is 'sdist' or 'wheel'.

    Raises if no acceptable source exists.
    """
    sdist = pkg.get("sdist")
    if sdist:
        return sdist["url"], sdist["hash"].removeprefix("sha256:"), "sdist"
    wheels = pkg.get("wheels", [])
    if not wheels:
        raise RuntimeError(f"{pkg['name']}: no sdist and no wheels")
    # Pick a py3-none-any wheel if available (purelib), else the first one.
    for w in wheels:
        if "-py3-none-any.whl" in w["url"] or "-py2.py3-none-any.whl" in w["url"]:
            return w["url"], w["hash"].removeprefix("sha256:"), "wheel"
    w = wheels[0]
    return w["url"], w["hash"].removeprefix("sha256:"), "wheel"


# ---------------------------------------------------------------------------
# Scheme emission
# ---------------------------------------------------------------------------


HEADER = """\
;;; guix-hermes --- Guix channel for Hermes Agent
;;; Copyright © 2026 Rafael Palomar <rafael.palomar@ous-research.no>
;;;
;;; This file is part of guix-hermes.
;;;
;;; guix-hermes is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or
;;; (at your option) any later version.

;;; Commentary:
;;;
;;; GENERATED FILE — DO NOT EDIT BY HAND.
;;;
;;; Regenerate with:
;;;   guix shell python python-packaging -- \\
;;;     python3 scripts/regen-deps.py --extras=messaging
;;;
;;; Source of truth: .upstream/uv.lock at upstream tag {upstream_ref}.
;;; Closure: {n_packages} Python packages (core + extras: {extras}).
;;;
;;; Phase 2 limits (cleaned up in Phase 3):
;;;   - synopsis / description / home-page are placeholders
;;;   - license defaults to MIT (Expat); per-package overrides come later
;;;   - tests disabled; native-inputs to be added as build failures surface
;;;
;;; Code:

(define-module (guix-hermes packages python-hermes-deps)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system pyproject))
"""


def emit_package(name: str, pkg: dict) -> str:
    version = pkg["version"]
    url, sha_hex, kind = pick_source(pkg)
    sha_b32 = hex_to_nix_base32(sha_hex)

    # propagated-inputs from this pkg's resolved deps (filtered by markers).
    prop_names: list[str] = []
    for d in pkg.get("dependencies", []):
        if not eval_marker(d.get("marker", "")):
            continue
        prop_names.append(guix_name(d["name"]))
    prop_names = sorted(set(prop_names))

    if prop_names:
        prop_block = (
            "    (propagated-inputs\n"
            "     (list " + " ".join(prop_names) + "))\n"
        )
    else:
        prop_block = ""

    note = "" if kind == "sdist" else "    ;; XXX wheel only — no sdist on PyPI\n"

    return (
        f"(define-public {guix_name(name)}\n"
        f"  (package\n"
        f"    (name \"{guix_name(name)}\")\n"
        f"    (version \"{version}\")\n"
        f"{note}"
        f"    (source\n"
        f"     (origin\n"
        f"       (method url-fetch)\n"
        f"       (uri \"{url}\")\n"
        f"       (sha256\n"
        f"        (base32 \"{sha_b32}\"))))\n"
        f"    (build-system pyproject-build-system)\n"
        f"    (arguments (list #:tests? #f))\n"
        f"{prop_block}"
        f"    (home-page \"https://pypi.org/project/{name}/\")\n"
        f"    (synopsis \"{name} (auto-generated; see Phase 3)\")\n"
        f"    (description \"Auto-generated package definition for @code{{{name}}} from upstream @file{{uv.lock}}.  Synopsis, description and license will be filled in during Phase 3.\")\n"
        f"    (license license:expat)))\n"
    )


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--extras", default="messaging",
                    help="Comma-separated optional groups (default: messaging)")
    ap.add_argument("--upstream-ref", default="v2026.5.16",
                    help="Upstream git ref the vendored lockfile was taken "
                         "from (for the generated-file header).")
    args = ap.parse_args()

    with LOCKFILE.open("rb") as f:
        lock = tomllib.load(f)
    packages = {normalize(p["name"]): p for p in lock["package"]}

    extras = [e.strip() for e in args.extras.split(",") if e.strip()]
    chosen = closure(packages, extras)

    body = [HEADER.format(
        upstream_ref=args.upstream_ref,
        n_packages=len(chosen),
        extras=", ".join(extras) if extras else "(core only)",
    )]
    for name in sorted(chosen):
        body.append("\n")
        body.append(emit_package(name, chosen[name]))

    OUTPUT.write_text("".join(body))
    print(f"wrote {OUTPUT} ({len(chosen)} packages)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
