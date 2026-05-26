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
import re
import sys
import tomllib
from pathlib import Path
from textwrap import indent

REPO_ROOT = Path(__file__).resolve().parent.parent
LOCKFILE = REPO_ROOT / ".upstream" / "uv.lock"
LOCKFILE_PYPROJECT = REPO_ROOT / ".upstream" / "pyproject.toml"
PYPROJECT_CACHE = REPO_ROOT / ".upstream" / "sdist-pyproject"
UPSTREAM_MAP = REPO_ROOT / ".upstream" / "upstream-map.data"
OUTPUT = REPO_ROOT / "guix-hermes" / "packages" / "python-hermes-deps.scm"

# Packages whose upstream Guix recipe is incompatible with our pinned
# version (typically: major build-system change).  Treat as "missing"
# even though `guix show` finds an older copy — we synthesise from
# scratch so the build-backend probe picks up the right native-inputs.
FORCE_MISSING: set[str] = set()


# Documented exceptions to exact-pin policy: packages where building
# our pinned upstream version requires effort disproportionate to the
# functional gain (typically a fresh Rust crate vendoring tree, an
# upstream CMake-build-system change, etc.) and where the upstream Guix
# version satisfies every reverse-dependency constraint in our closure.
#
# When a package is in PIN_DOWNGRADES, we treat it as a "match" against
# upstream Guix regardless of version — i.e. re-export upstream as-is.
PIN_DOWNGRADES = {
    # cryptography 46.x switched setuptools-rust → maturin AND brought
    # in a fresh Rust crate dependency tree that would need hermetic
    # vendoring to build under Guix.  Closure analysis: only pyjwt[crypto]
    # needs it, and pyjwt 2.12.1 only requires cryptography>=3.4.0 —
    # Guix's 44.0.0 satisfies.  Accept the downgrade.
    "python-cryptography",
    # pycparser is a low-level transitive dep of cffi (no API surface
    # exposed to hermes-agent itself).  Bumping 2.22 → 3.0 breaks
    # upstream Guix's install-doc phase (CHANGES → CHANGELOG.md rename).
    # Not worth a snippet workaround.
    "python-pycparser",
    # python-certifi is just the Mozilla CA bundle.  Two versions in
    # the closure (ours via python-requests, upstream's via the
    # `match'-mode python-httpcore) collide at profile build time.
    # The version difference is purely cosmetic (cert store snapshot
    # date); accept the downgrade rather than rewrite every transitive.
    "python-certifi",
    # python-cffi is a low-level FFI helper used by brotlicffi and
    # (downgraded) cryptography.  Same conflict pattern: ours via
    # brotlicffi-mismatch (cffi 2.0.0) vs upstream's via cryptography-
    # downgrade (cffi 1.17.1).  Accept the older variant — cffi 1.x
    # vs 2.x is API-stable for both reverse-deps in our closure.
    "python-cffi",
    # python-pytz is a timezone database wrapper.  Patch-version
    # diffs (2025.1 vs 2025.2) only update Olson tzdata snapshots;
    # the diff doesn't move any timezone our closure relies on.
    # python-icalendar (in curie's email profile) propagates 2025.1;
    # our croniter pins 2025.2.  Accept the downgrade rather than
    # cascade-rewrite icalendar.
    "python-pytz",
    # python-pyyaml — patch-version diff (6.0.2 vs 6.0.3) with no API
    # change.  Conflict surfaces when hermes-agent meets workstation
    # tooling that reaches pyyaml via other paths (rofi-rbw via
    # configargparse on curie).
    "python-pyyaml",
}


# Per-package source snippets — applied to the (origin) of a "missing"
# package when its upstream pyproject.toml needs surgery to build with
# the build-tooling versions Guix currently ships.  Keyed by Guix name.
# Each value is a list of (substitute* spec) entries that will be
# rendered as a snippet running inside the source tree.
# Per-package native-inputs override — when the auto-detected set
# isn't enough, replace the entire (native-inputs (list ...)) form
# with this verbatim Scheme string.  Keyed by Guix name.
NATIVE_INPUTS_OVERRIDES: dict[str, str] = {
    "python-cryptography":
        # maturin + Rust toolchain (cargo lives in the "cargo" output of `rust`).
        "(list maturin python-cffi rust `(,rust \"cargo\"))",
}


# Per-package wheel fallback — use the binary wheel from PyPI instead
# of building from sdist.  Use sparingly: only when source-building
# would require hermetic Rust crate vendoring or a similar undertaking
# we deliberately defer.  Keyed by Guix name.
WHEEL_FALLBACK = {
    # jiter is a Rust extension (PyO3); sdist requires hermetic cargo
    # crate vendoring which is days of work for marginal benefit.
    # The manylinux wheel is glibc 2.17 ABI-compatible with Guix.
    "python-jiter",
    # davey is Discord's Rust-based voice encryption library, pulled
    # in via discord-py[voice].  Same Rust-vendoring problem as jiter.
    "python-davey",
}


# Per-package: skip the Guix sanity-check phase.  Use when a package's
# entry-points require optional extras (e.g. python-dotenv's `dotenv`
# CLI needs the [cli] extra which pulls click — out of our closure).
SKIP_SANITY_CHECK: set[str] = {
    "python-python-dotenv",
    # ruamel-yaml-clib is a Cython companion to ruamel.yaml; the bare
    # module can't be imported without its parent package on sys.path.
    "python-ruamel-yaml-clib",
    # slack-sdk's legacy `slack/__init__.py` alias module unconditionally
    # `import aiohttp` from RTMClient — aiohttp is an optional dep,
    # always present in our closure via [messaging] but not a direct
    # propagated-input.
    "python-slack-sdk",
}


SOURCE_SNIPPETS: dict[str, list[str]] = {
    "python-cryptography": [
        # 1) Drop PEP 639 license-files array — maturin 1.8.1 in Guix
        #    can't parse it; maturin 1.9+ adds that support.
        # 2) Relax maturin version pin from 1.9.4 → 1.8 so we can build
        #    with Guix's maturin.  Cryptography 46.0.7's actual maturin
        #    API surface is compatible with 1.8.x; the >=1.9.4 pin is
        #    forward-looking (CI tests against newer maturin features).
        '(substitute* "pyproject.toml"'
        '\n               (("^license-files = .*") "")'
        '\n               (("\\"maturin>=1\\\\.9\\\\.4,<2\\"") "\\"maturin>=1.8,<2\\""))',
    ],
}

# Map of upstream `[build-system].build-backend` strings to the
# Guix-side native-input package name that provides it.  None means
# setuptools (default — no extra native-input needed).
BACKEND_TO_GUIX = {
    "setuptools.build_meta": "python-setuptools",
    "setuptools.build_meta:__legacy__": "python-setuptools",
    "_custom_build": "python-setuptools",                         # NumPy etc.
    "flit_core.buildapi": "python-flit-core",
    "hatchling.build": "python-hatchling",
    "poetry.core.masonry.api": "python-poetry-core",
    "pdm.backend": "python-pdm-backend",
    "pdm.pep517.api": "python-pdm-backend",
    "maturin": "maturin",
    "mesonpy": "python-meson-python",
    "scikit_build_core.build": "python-scikit-build-core",
    # In-tree custom backends used by packages that ship their own
    # PEP 517 hook scripts (pyyaml, yarl, multidict, etc.).  These
    # invariably wrap setuptools under the hood — the backend itself
    # ships in the sdist alongside pyproject.toml.
    "_pyyaml_pep517": "python-setuptools",
    "pep517_backend.hooks": "python-setuptools",
    "backend": "python-setuptools",                   # generic fallback name
}

# Helper packages that often appear in [build-system].requires *in
# addition to* the backend, and that we want as native-inputs when seen.
# Keys are normalised PyPI names (PEP 503), values are Guix names.
EXTRA_BUILD_DEPS = {
    "setuptools-scm": "python-setuptools-scm",
    "setuptools-rust": "python-setuptools-rust",
    "cython": "python-cython",
    # Hatchling plugin ecosystem — surface as native-inputs when present.
    "hatch-vcs": "python-hatch-vcs",
    "hatch-fancy-pypi-readme": "python-hatch-fancy-pypi-readme",
    # aio-libs in-tree backend (frozenlist/multidict/yarl/aiohttp/propcache)
    # uses pep517_backend.hooks which imports expandvars to evaluate env vars
    # during the cythonize step.
    "expandvars": "python-expandvars",
    # Build backends declared again in requires (hatchling, poetry-core,
    # flit-core) are handled separately via BACKEND_TO_GUIX.
    "hatchling": None,
    "poetry-core": None,
    "flit-core": None,
    "pdm-backend": None,
    "maturin": None,
    # Helpers we treat as provided by the python build env.
    "wheel": None,
    "setuptools": None,
    "pip": None,
    "tomli": None,
    "packaging": None,
    "pluggy": None,
    "trove-classifiers": None,
}

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


def closure(packages: dict, extras: list[str]) -> tuple[dict[str, dict], dict[str, set[str]]]:
    """Return (visited, activated_extras).

    `visited` maps normalised pypi name → lockfile package entry.
    `activated_extras` maps normalised pypi name → set of extras that
    were requested for that package by *something* in the walk
    (e.g. hermes-agent declares `httpx[socks]`, so socks lands in
    activated_extras["httpx"]).  The emitter consults this to
    augment propagated-inputs with the right optional-dependencies."""
    hermes = packages["hermes-agent"]
    queue = list(hermes.get("dependencies", []))
    for extra in extras:
        queue.extend(hermes.get("optional-dependencies", {}).get(extra, []))

    visited: dict[str, dict] = {}
    activated: dict[str, set[str]] = {}
    while queue:
        dep = queue.pop()
        name = normalize(dep["name"])
        # Always record requested extras even if we've already visited
        # — different callers may activate different extras.
        for e in (dep.get("extra") or []):
            activated.setdefault(name, set()).add(e)
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
        # Also walk into any activated extra so its deps land in the
        # closure (and that extra's own extras propagate).
        for e in activated.get(name, set()):
            for d in pkg.get("optional-dependencies", {}).get(e, []):
                queue.append(d)
    visited.pop("hermes-agent", None)
    activated.pop("hermes-agent", None)
    return visited, activated


# Will be set by main() so the emit_* helpers can consult it without
# threading it through every call site.
_ACTIVATED_EXTRAS: dict[str, set[str]] = {}


def collect_props(pkg: dict, name: str) -> list[str]:
    """Build the propagated-inputs list for a package: its regular
    dependencies, plus the deps of any extras activated for it by the
    closure walk."""
    out: list[str] = []
    for d in pkg.get("dependencies", []):
        if not eval_marker(d.get("marker", "")):
            continue
        out.append(guix_name(d["name"]))
    for e in _ACTIVATED_EXTRAS.get(normalize(name), set()):
        for d in pkg.get("optional-dependencies", {}).get(e, []):
            if not eval_marker(d.get("marker", "")):
                continue
            out.append(guix_name(d["name"]))
    return sorted(set(out))


# ---------------------------------------------------------------------------
# source picking — prefer sdist for Guix's build-from-source ethos.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# build-backend probing — extract pyproject.toml from each sdist
# ---------------------------------------------------------------------------


def fetch_pyproject(name: str, version: str, sdist_url: str) -> dict | None:
    """Return the parsed pyproject.toml from `name-version.tar.gz`, cached
    under `.upstream/sdist-pyproject/`.  Returns None if the sdist has no
    pyproject.toml (legacy setup.py-only package)."""
    cache_path = PYPROJECT_CACHE / f"{name}-{version}.toml"
    sentinel = PYPROJECT_CACHE / f"{name}-{version}.none"
    if sentinel.exists():
        return None
    if not cache_path.exists():
        import subprocess
        print(f"  fetching pyproject.toml for {name}-{version}", file=sys.stderr)
        # Only extract the *top-level* pyproject.toml — many sdists are
        # workspaces (pydantic, etc.) and bundle subpackage pyprojects too.
        # Two slashes ('*/*/...') would match subpackages; one slash means
        # exactly <name-version>/pyproject.toml.
        proc = subprocess.run(
            ["bash", "-c",
             f"curl -fsSL {sdist_url} | "
             "tar -xz --to-stdout --wildcards --no-wildcards-match-slash "
             "'*/pyproject.toml'"],
            capture_output=True, timeout=60,
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            sentinel.write_text("# no pyproject.toml in sdist\n")
            return None
        cache_path.write_bytes(proc.stdout)
    return tomllib.loads(cache_path.read_text())


def detect_native_inputs(pyproject: dict | None) -> list[str]:
    """Pick the Guix native-input package names for this dep's build env.

    Looks at `[build-system].build-backend` (mandatory) and
    `[build-system].requires` (we pluck the entries that map via
    EXTRA_BUILD_DEPS).  For the aio-libs in-tree `pep517_backend.hooks`
    backend we also tack on Cython + a gcc-toolchain because their
    `[tool.local.cythonize]` step pre-compiles .pyx → .c → .so during
    build_wheel.  The aio-libs `requires` list deliberately omits
    Cython on the assumption that `pip` would install it lazily on
    first use — which never happens in a hermetic Guix build.
    """
    if not pyproject:
        return []
    bs = pyproject.get("build-system", {})
    backend = bs.get("build-backend", "setuptools.build_meta")
    inputs: list[str] = []
    if backend in BACKEND_TO_GUIX:
        g = BACKEND_TO_GUIX[backend]
        if g:
            inputs.append(g)
    else:
        print(f"warning: unknown build-backend '{backend}'", file=sys.stderr)
    # aio-libs in-tree backend pre-cythonizes .pyx — needs Cython + C compiler.
    if backend == "pep517_backend.hooks":
        for extra in ("python-cython", "gcc-toolchain"):
            if extra not in inputs:
                inputs.append(extra)
    for req in bs.get("requires", []):
        bare = req.split(";")[0].split(">")[0].split("<")[0].split("=")[0]\
                  .split("!")[0].split("~")[0].split("[")[0].strip()
        norm = normalize(bare)
        if norm in EXTRA_BUILD_DEPS:
            g = EXTRA_BUILD_DEPS[norm]
            if g and g not in inputs:
                inputs.append(g)
    return inputs


# ---------------------------------------------------------------------------
# upstream-map — parse .upstream/upstream-map.data into a Python dict
# ---------------------------------------------------------------------------


# One line per package, e.g.:
#   ("python-aiohttp" mismatch "3.11.18" (gnu packages python-web)) ; want 3.13.4
#   ("python-jiter" missing "0.13.0" #f)
_UPSTREAM_RE = re.compile(
    r'^\s*\("(?P<name>python-[^"]+)"\s+'
    r'(?P<status>match|mismatch|missing)\s+'
    r'"(?P<version>[^"]*)"\s+'
    r'(?:\((?P<module>[^)]+)\)|#f)\)'
)


def load_upstream_map(path: Path) -> dict[str, dict]:
    """Returns {guix-name: {status, version, module}} parsed from
    `upstream-map.scm`.  module is a tuple of symbol names like
    ('gnu','packages','python-web'), or None when status == 'missing'."""
    if not path.exists():
        print(f"warning: {path} not found — every package will be emitted "
              "from scratch (slow + redundant).", file=sys.stderr)
        return {}
    out: dict[str, dict] = {}
    for line in path.read_text().splitlines():
        m = _UPSTREAM_RE.match(line)
        if not m:
            continue
        out[m["name"]] = {
            "status": m["status"],
            "version": m["version"],
            "module": tuple(m["module"].split()) if m["module"] else None,
        }
    return out


def module_to_scheme(module: tuple) -> str:
    """('gnu','packages','python-web') → '(gnu packages python-web)'."""
    return "(" + " ".join(module) + ")"


def pick_source(pkg: dict, prefer_wheel: bool = False) -> tuple[str, str, str]:
    """Return (url, sha256_hex, kind) where kind is 'sdist' or 'wheel'.

    With prefer_wheel=True we look for a Linux cp311 manylinux wheel
    first — used for Rust-extension packages we don't want to source-
    build.  Falls back to sdist if no suitable wheel is found.
    """
    sdist = pkg.get("sdist")
    wheels = pkg.get("wheels", [])

    if prefer_wheel:
        # Prefer manylinux cp311 x86_64 wheels.
        for w in wheels:
            url = w["url"]
            if ("cp311-cp311-manylinux" in url
                    and ("x86_64" in url or "amd64" in url)):
                return url, w["hash"].removeprefix("sha256:"), "wheel"
        # Fall through to sdist if no matching wheel.

    if sdist:
        return sdist["url"], sdist["hash"].removeprefix("sha256:"), "sdist"

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


HEADER_PROLOGUE = """\
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
;;;   guix repl scripts/probe-upstream.scm < /tmp/want.tsv \\
;;;     > .upstream/upstream-map.data
;;;   guix shell python python-packaging curl gzip tar -- \\
;;;     python3 scripts/regen-deps.py --extras=messaging
;;;
;;; Source of truth: .upstream/uv.lock at upstream tag {upstream_ref}.
;;; Closure: {n_packages} Python packages (core + extras: {extras}).
;;;
;;; Strategy per package (driven by .upstream/upstream-map.data):
;;;   - match     ({n_match}): re-export upstream Guix definition
;;;   - mismatch  ({n_mismatch}): inherit upstream, bump version + source
;;;   - missing   ({n_missing}): full from-scratch definition
;;;   - downgrade ({n_downgrade}): re-export upstream despite version drift
;;;                         (documented exception, see scripts/regen-deps.py)
;;;
;;; Code:

(define-module (guix-hermes packages python-hermes-deps)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)     ; substitute-keyword-arguments
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system pyproject)
  ;; Build-backend providers — re-used from upstream Guix.
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)  ; cython, expandvars, …
  ;; C toolchain for Cython-compiled extensions (multidict, yarl,
  ;; propcache, aiohttp, ruamel-yaml-clib).
  #:use-module (gnu packages commencement)
  ;; Rust toolchain for maturin-built packages (cryptography 46+).
  #:use-module (gnu packages rust-apps)  ; maturin
  #:use-module (gnu packages rust)       ; rust (rustc + cargo output)
{extra_use_modules})
"""


def emit_pure_reexport(gname: str, upstream: dict) -> str:
    """Bare `(@ MOD GNAME)` re-export of an upstream package.  Used for
    PIN_DOWNGRADE cases: the channel deliberately accepts upstream's
    version *including* its propagated-inputs.  Touching those would
    create a derivation distinct from upstream's and clash with paths
    through other transitives that still reference the original."""
    mod = module_to_scheme(upstream["module"])
    return (
        f";; pure re-export ({upstream['version']} from {mod})\n"
        f"(define-public {gname}\n"
        f"  (@ {mod} {gname}))\n"
    )


def emit_match(gname: str, pkg: dict, upstream: dict) -> str:
    """Match on version with upstream Guix, but inherit-rebind
    propagated-inputs to the channel's closure-resolved transitive set.

    A bare `(@ MOD GNAME)` re-export would inherit upstream's
    propagated-inputs — those reference upstream's *other* package
    definitions, which may have older versions of things we
    explicitly pin elsewhere.  The result is profile-level conflicts
    where the same package appears at two versions on different
    propagation paths.  Inheriting and re-binding propagated-inputs
    closes that loop without rebuilding the source.
    """
    mod = module_to_scheme(upstream["module"])
    prop_names = collect_props(pkg, pkg["name"])
    if not prop_names:
        # No transitive deps to re-bind — pure re-export is safe.
        return emit_pure_reexport(gname, upstream)
    # Drop *all* upstream python-* propagated-inputs (their versions
    # may not match our closure) and append our channel-pinned set.
    # Non-Python upstream propagated-inputs (libsodium for pynacl,
    # libffi for cffi, …) are preserved by the prefix filter.
    return (
        f";; match: {upstream['version']} (from {mod}); python-* propagated-\n"
        f";; inputs replaced with channel closure (system-lib inputs preserved).\n"
        f"(define-public {gname}\n"
        f"  (let ((base (@ {mod} {gname})))\n"
        f"    (package\n"
        f"      (inherit base)\n"
        f"      (propagated-inputs\n"
        f"       (append\n"
        f"        ;; Keep non-Python upstream propagated-inputs (libsodium,\n"
        f"        ;; libffi, …); strip their (label _) pairs so the result\n"
        f"        ;; is a flat list of packages that Guix can auto-label.\n"
        f"        (map (lambda (i) (if (pair? i) (cadr i) i))\n"
        f"             (filter (lambda (i)\n"
        f"                       (let ((label (if (pair? i) (car i)\n"
        f"                                        (package-name i))))\n"
        f"                         (not (string-prefix? \"python-\" label))))\n"
        f"                     (package-propagated-inputs base)))\n"
        f"        (list " + " ".join(prop_names) + ")))\n"
        f"      (arguments\n"
        f"       (substitute-keyword-arguments (package-arguments base)\n"
        f"         ((#:tests? was-tests? #f) #f))))))\n"
    )


def emit_mismatch(gname: str, pkg: dict, upstream: dict) -> str:
    """Inherit upstream's build recipe, bump version + source to our pin.

    Also disables the test suite (upstream's tests target the older
    version) and *appends* any new build-backend deps detected from the
    new version's pyproject.toml — packages frequently change backend
    between minor releases (e.g. jinja2 3.1.2 → 3.1.6 was setuptools →
    flit-core), and a bare inherit would lose those.
    """
    name = pkg["name"]
    version = pkg["version"]
    url, sha_hex, kind = pick_source(pkg)
    sha_b32 = hex_to_nix_base32(sha_hex)
    mod = module_to_scheme(upstream["module"])
    note = "" if kind == "sdist" else "      ;; XXX wheel only — no sdist on PyPI\n"

    pyproject = fetch_pyproject(name, version, url) if kind == "sdist" else None
    native = detect_native_inputs(pyproject)
    if native:
        native_block = (
            f"      (native-inputs\n"
            f"       (modify-inputs (package-native-inputs base)\n"
            f"         (append " + " ".join(native) + ")))\n"
        )
    else:
        native_block = ""

    # propagated-inputs: rebind via modify-inputs so upstream's system-
    # lib propagated-inputs (libsodium etc.) survive while our pinned
    # python-* set lands.  Also covers the "uv.lock says zero deps but
    # upstream Guix has stale python-* propagated-inputs" case (e.g.
    # urllib3 2.5.0 propagates idna 3.10; 2.6.3 has zero runtime deps).
    prop_names = collect_props(pkg, pkg["name"])
    # Drop all upstream python-* propagated-inputs, keep system libs,
    # append our channel-pinned set.  Same shape as emit_match — the
    # only difference is that mismatch also bumps version + source.
    if prop_names:
        appendix = "(list " + " ".join(prop_names) + ")"
    else:
        appendix = "'()"
    prop_block = (
        f"      (propagated-inputs\n"
        f"       (append\n"
        f"        ;; Keep non-Python upstream propagated-inputs (libsodium,\n"
        f"        ;; libffi, …); strip their (label _) pairs so the result\n"
        f"        ;; is a flat list of packages that Guix can auto-label.\n"
        f"        (map (lambda (i) (if (pair? i) (cadr i) i))\n"
        f"             (filter (lambda (i)\n"
        f"                       (let ((label (if (pair? i) (car i)\n"
        f"                                        (package-name i))))\n"
        f"                         (not (string-prefix? \"python-\" label))))\n"
        f"                     (package-propagated-inputs base)))\n"
        f"        " + appendix + "))\n"
    )

    return (
        f";; mismatch: want {version}, upstream Guix has {upstream['version']}\n"
        f"(define-public {gname}\n"
        f"  (let ((base (@ {mod} {gname})))\n"
        f"    (package\n"
        f"      (inherit base)\n"
        f"      (version \"{version}\")\n"
        f"      (source\n"
        f"       (origin\n"
        f"         (method url-fetch)\n"
        f"         (uri \"{url}\")\n"
        f"{note}"
        f"         (sha256\n"
        f"          (base32 \"{sha_b32}\"))))\n"
        f"{native_block}"
        f"{prop_block}"
        f"      (arguments\n"
        f"       (substitute-keyword-arguments (package-arguments base)\n"
        f"         ((#:tests? was-tests? #f) #f))))))\n"
    )


def emit_missing(name: str, gname: str, pkg: dict) -> str:
    """Full from-scratch definition — package isn't in upstream Guix."""
    version = pkg["version"]
    url, sha_hex, kind = pick_source(pkg, prefer_wheel=(gname in WHEEL_FALLBACK))
    sha_b32 = hex_to_nix_base32(sha_hex)

    prop_names = collect_props(pkg, pkg["name"])
    prop_block = (
        "    (propagated-inputs\n"
        "     (list " + " ".join(prop_names) + "))\n"
    ) if prop_names else ""

    pyproject = (fetch_pyproject(name, version, url)
                 if kind == "sdist" and gname not in WHEEL_FALLBACK
                 else None)
    if gname in NATIVE_INPUTS_OVERRIDES:
        native_block = (
            "    (native-inputs\n"
            "     " + NATIVE_INPUTS_OVERRIDES[gname] + ")\n"
        )
    elif gname in WHEEL_FALLBACK:
        # Pre-built wheel — no build deps needed.
        native_block = ""
    else:
        native = detect_native_inputs(pyproject)
        native_block = (
            "    (native-inputs\n"
            "     (list " + " ".join(native) + "))\n"
        ) if native else ""

    backend = (pyproject or {}).get("build-system", {}).get(
        "build-backend", "setuptools.build_meta")
    if gname in WHEEL_FALLBACK:
        # Pre-built wheel — skip unpack/build, just stage the .whl in dist/
        # and let the standard install phase install from it.  RUNPATH
        # validation is also skipped (wheels carry their own RPATHs).
        args_block = (
            "    (arguments\n"
            "     (list\n"
            "      #:tests? #f\n"
            "      #:phases\n"
            "      #~(modify-phases %standard-phases\n"
            "          (replace 'unpack\n"
            "            (lambda* (#:key source #:allow-other-keys)\n"
            "              (mkdir-p \"dist\")\n"
            "              (copy-file source\n"
            "                         (string-append \"dist/\" (basename source)))))\n"
            "          (delete 'build)\n"
            "          (delete 'validate-runpath))))\n"
        )
    elif backend == "pep517_backend.hooks":
        args_block = (
            "    (arguments\n"
            "     (list\n"
            "      #:tests? #f\n"
            "      #:phases\n"
            "      #~(modify-phases %standard-phases\n"
            "          (add-after 'build 'aiolibs-promote-wheel\n"
            "            (lambda _\n"
            "              (for-each (lambda (whl)\n"
            "                          (rename-file whl\n"
            "                            (string-append \"dist/\"\n"
            "                                           (basename whl))))\n"
            "                        (find-files \"dist\" \"\\\\.whl$\")))))))\n"
        )
    elif gname in SKIP_SANITY_CHECK:
        args_block = (
            "    (arguments\n"
            "     (list\n"
            "      #:tests? #f\n"
            "      #:phases\n"
            "      #~(modify-phases %standard-phases\n"
            "          (delete 'sanity-check))))\n"
        )
    else:
        args_block = "    (arguments (list #:tests? #f))\n"

    if kind == "sdist":
        note = ""
    elif gname in WHEEL_FALLBACK:
        note = ("    ;; binary wheel (Rust extension) — see WHEEL_FALLBACK in "
                "scripts/regen-deps.py\n")
    else:
        note = "    ;; XXX wheel only — no sdist on PyPI\n"

    # Optional source snippet for packages whose pyproject.toml needs
    # surgery to build against the build-tooling versions Guix ships.
    snippets = SOURCE_SNIPPETS.get(gname, [])
    if snippets:
        snippet_block = (
            "       (modules '((guix build utils)))\n"
            "       (snippet\n"
            "        #~(begin\n"
            + "".join(f"           {s}\n" for s in snippets)
            + "           #t))\n"
        )
    else:
        snippet_block = ""

    return (
        f";; missing from upstream Guix — full hand-defined package\n"
        f"(define-public {gname}\n"
        f"  (package\n"
        f"    (name \"{gname}\")\n"
        f"    (version \"{version}\")\n"
        f"{note}"
        f"    (source\n"
        f"     (origin\n"
        f"       (method url-fetch)\n"
        f"       (uri \"{url}\")\n"
        f"       (sha256\n"
        f"        (base32 \"{sha_b32}\"))\n"
        f"{snippet_block}"
        f"       ))\n"
        f"    (build-system pyproject-build-system)\n"
        f"{args_block}"
        f"{native_block}"
        f"{prop_block}"
        f"    (home-page \"https://pypi.org/project/{name}/\")\n"
        f"    (synopsis \"{name} (auto-generated; see Phase 3)\")\n"
        f"    (description \"Auto-generated package definition for @code{{{name}}} from upstream @file{{uv.lock}}.  Synopsis, description and license will be filled in during Phase 3.\")\n"
        f"    (license license:expat)))\n"
    )


def emit_package(name: str, pkg: dict, upstream: dict | None) -> str:
    gname = guix_name(name)
    if gname in PIN_DOWNGRADES and upstream and upstream["status"] != "missing":
        # Re-export upstream regardless of version drift; documented
        # exception to exact-pin policy.  See PIN_DOWNGRADES docstring.
        # Pure re-export — do not rebind propagated-inputs (would
        # diverge from the upstream derivation that other transitives
        # reach by other paths).
        return (
            f";; PIN DOWNGRADE: upstream Guix {upstream['version']} "
            f"(closure asks {pkg['version']}; see PIN_DOWNGRADES)\n"
            + emit_pure_reexport(gname, upstream)
        )
    if gname in FORCE_MISSING:
        return emit_missing(name, gname, pkg)
    if upstream is None or upstream["status"] == "missing":
        return emit_missing(name, gname, pkg)
    if upstream["status"] == "match":
        return emit_match(gname, pkg, upstream)
    return emit_mismatch(gname, pkg, upstream)


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
    chosen, activated = closure(packages, extras)
    global _ACTIVATED_EXTRAS
    _ACTIVATED_EXTRAS = activated

    upstream = load_upstream_map(UPSTREAM_MAP)

    # Gather every module we'll need to import.  Anything missing from the
    # upstream map gets treated as "missing" — full hand-defined package.
    modules_used: set[tuple] = set()
    n_match = n_mismatch = n_missing = n_downgrade = 0
    for name in chosen:
        gname = guix_name(name)
        info = upstream.get(gname)
        if gname in PIN_DOWNGRADES and info and info["status"] != "missing":
            n_downgrade += 1
            modules_used.add(info["module"])
        elif info and info["status"] == "match":
            n_match += 1
            modules_used.add(info["module"])
        elif info and info["status"] == "mismatch" and gname not in FORCE_MISSING:
            n_mismatch += 1
            modules_used.add(info["module"])
        else:
            n_missing += 1
    # We always emit Cython-using packages from upstream so rust-apps is
    # not strictly needed unless a missing pkg uses maturin.
    extra_uses = "\n".join(
        f"  #:use-module {module_to_scheme(m)}"
        for m in sorted(modules_used)
    )

    body = [HEADER_PROLOGUE.format(
        upstream_ref=args.upstream_ref,
        n_packages=len(chosen),
        extras=", ".join(extras) if extras else "(core only)",
        n_match=n_match,
        n_mismatch=n_mismatch,
        n_missing=n_missing,
        n_downgrade=n_downgrade,
        extra_use_modules=extra_uses,
    )]
    for name in sorted(chosen):
        body.append("\n")
        body.append(emit_package(name, chosen[name], upstream.get(guix_name(name))))

    OUTPUT.write_text("".join(body))
    print(f"wrote {OUTPUT} "
          f"({len(chosen)} pkgs: {n_match} match, "
          f"{n_mismatch} mismatch, {n_missing} missing, "
          f"{n_downgrade} downgrade)",
          file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
