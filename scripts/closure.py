#!/usr/bin/env python3
"""Compute the transitive dependency closure of hermes-agent for the
extras we ship in the channel (core + messaging), as resolved by
upstream `uv.lock`.  Emits a plain list of (name, version) tuples for
inspection — no Scheme yet.

Usage:
    python3 scripts/closure.py [--extras=messaging,...]
"""

from __future__ import annotations

import argparse
import sys
import tomllib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
LOCKFILE = REPO_ROOT / ".upstream" / "uv.lock"

# Environment we resolve markers under — workstation Linux, Python 3.12.
ENV = {
    "sys_platform": "linux",
    "platform_system": "Linux",
    "platform_machine": "x86_64",
    "python_version": "3.12",
    "python_full_version": "3.12.0",
    "implementation_name": "cpython",
    "platform_python_implementation": "CPython",
}


def normalize(name: str) -> str:
    """PEP 503 normalization."""
    return name.lower().replace("_", "-").replace(".", "-")


def eval_marker(marker: str) -> bool:
    """Very small PEP 508 marker subset.  Returns True if dep should be kept.

    Handles: ==, !=, >=, <=, >, <, in, not in, and, or, parens, and the
    env vars listed in ENV.  Anything we can't parse defaults to True
    (include with warning), which is safe for closure walking (we'd
    rather over-include than miss deps).
    """
    if not marker:
        return True
    # Quick wins.
    s = marker.strip()
    # `extra == 'X'` markers should not appear in resolved deps; if they
    # do, treat as False (we route extras via package.optional-dependencies).
    if "extra ==" in s or "extra !=" in s:
        return False
    try:
        import packaging.markers
    except ImportError:
        # Fall back to a manual subset evaluator.
        return _eval_marker_manual(s)
    try:
        return packaging.markers.Marker(s).evaluate(ENV)
    except Exception as exc:
        print(f"warning: marker '{s}' failed to evaluate ({exc}); keeping",
              file=sys.stderr)
        return True


def _eval_marker_manual(s: str) -> bool:
    """Minimal manual evaluator for the markers actually seen in hermes
    uv.lock: sys_platform == 'win32', sys_platform != 'win32',
    python_full_version >= '3.X', etc.  Returns True if dep should be kept."""
    # Cheap pattern matching for the handful of marker shapes we see.
    # If we see something complex, return True (include).
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
    print(f"warning: unrecognised marker '{s}'; keeping", file=sys.stderr)
    return True


def closure(packages: dict, roots: list, extras: list[str]) -> dict:
    """Walk the dep graph from hermes-agent core + chosen extras.

    Returns dict[name] = package_entry for everything reachable under ENV."""
    hermes = packages["hermes-agent"]
    queue = list(hermes.get("dependencies", []))
    for extra in extras:
        queue.extend(hermes.get("optional-dependencies", {}).get(extra, []))

    visited: dict[str, dict] = {}
    activated: dict[str, set] = {}
    while queue:
        dep = queue.pop()
        name = normalize(dep["name"])
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
        # Walk activated extras too, so their deps land in the closure.
        for e in activated.get(name, set()):
            for d in pkg.get("optional-dependencies", {}).get(e, []):
                queue.append(d)
    return visited


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--extras", default="messaging",
                    help="Comma-separated optional groups from hermes-agent's "
                         "[package.optional-dependencies] to include "
                         "(default: messaging).  Pass '' for core only.")
    args = ap.parse_args()

    with LOCKFILE.open("rb") as f:
        lock = tomllib.load(f)
    packages = {normalize(p["name"]): p for p in lock["package"]}

    extras = [e.strip() for e in args.extras.split(",") if e.strip()]
    chosen = closure(packages, packages["hermes-agent"], extras)
    # Don't emit hermes-agent itself (it's the root — packaged separately).
    chosen.pop("hermes-agent", None)

    print(f"# closure size: {len(chosen)} packages "
          f"(extras: {extras or ['(core only)']})", flush=True)
    for name in sorted(chosen):
        print(f"{name}\t{chosen[name]['version']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
