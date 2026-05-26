# scripts/

Helpers for maintaining the channel.  Run them from the repo root.

## `closure.py` — inspect the dep graph

Walks the resolved `uv.lock` and prints `name<TAB>version` for every
package reachable from `hermes-agent`'s core dependencies plus the
optional groups passed via `--extras`.  Read-only.

```bash
guix shell python python-packaging -- python3 scripts/closure.py
guix shell python python-packaging -- python3 scripts/closure.py --extras=''
guix shell python python-packaging -- python3 scripts/closure.py --extras=messaging,slack
```

Use this to sanity-check what would be generated before running
`regen-deps.py`, or to diff scope changes over time.

## `regen-deps.py` — generate `python-hermes-deps.scm`

Reads `.upstream/uv.lock` and emits
`guix-hermes/packages/python-hermes-deps.scm` — one `define-public`
per package, with sdist URL + nix-base32 sha256 + propagated-inputs
wired up from the resolved closure.

```bash
guix shell python python-packaging -- \
  python3 scripts/regen-deps.py --extras=messaging
```

After regen, verify the module still loads:

```bash
guix repl -L . -- <(echo '(use-modules (guix-hermes packages python-hermes-deps))')
```

### What's pinned where

| Pin                              | Lives in                              | How to bump                                                                                       |
|----------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------|
| Upstream `hermes-agent` ref      | `.upstream/uv.lock`, `pyproject.toml` | `gh api repos/NousResearch/hermes-agent/contents/<file>?ref=<tag>` (see workflow below)           |
| Extras included                  | `--extras=` arg + `python-hermes-deps.scm` header | rerun `regen-deps.py` with a new value                                              |
| nix-base32 of each sdist         | generated automatically from `uv.lock` `sha256:…` hex                                  | n/a                                                                                |

### Re-pinning to a newer upstream release

1. Find the new tag:
   ```bash
   gh api repos/NousResearch/hermes-agent/releases --jq '.[].tag_name' | head
   ```
2. Re-vendor the lockfile + pyproject:
   ```bash
   UPSTREAM_REF=v2026.X.Y
   cd .upstream
   for f in uv.lock pyproject.toml; do
     gh api "repos/NousResearch/hermes-agent/contents/$f?ref=$UPSTREAM_REF" \
       --jq '.content' | base64 -d > "$f"
   done
   ```
3. Regenerate the deps module:
   ```bash
   guix shell python python-packaging -- \
     python3 scripts/regen-deps.py --extras=messaging \
     --upstream-ref="$UPSTREAM_REF"
   ```
4. Inspect the diff.  Any new packages outside the existing closure
   may need Phase 3-style cleanups (build-backend, native-inputs).
   The generator marks new entries with the Phase 3 TODO placeholders.

## Phase 2 generator design — why it's tiny

Unlike the openclaw npm-binary path, this generator does **not**:

- talk to PyPI (everything we need is already in `uv.lock`)
- resolve versions (the lockfile already did)
- patch any Guix importer (the generator emits Scheme directly)

It's just a TOML reader + a 30-line nix-base32 encoder + a marker
evaluator (PEP 508 subset) + an emitter.  ~250 lines total.

The hard work in this packaging effort lives in Phase 3 (per-package
build-system / native-inputs / license cleanup) — *not* in the
dependency synthesis step.
