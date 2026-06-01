# CLAUDE.md

Guidance for Claude Code working in this repository.

## What This Is

A **Guix package channel** for [Hermes Agent](https://github.com/NousResearch/hermes-agent)
— Nous Research's self-improving AI agent.  Sibling channel to `guix-openclaw`
(under the same OUH-MESHLab org).

## Status

**All six phases complete.**  The channel is live at
<https://github.com/OUH-MESHLab/guix-hermes> and wired into
`~/.dotfiles/channels.scm` + `channels-lock.scm`.  Smoke-tested:

    $ guix time-machine -C channels-lock.scm -- \
        shell hermes-agent -- hermes --version
    Hermes Agent v0.14.0 (2026.5.16)

Build classification (58 deps + 1 top-level): 18 re-exports of pristine
upstream Guix packages, 29 inherit-and-bump overrides, 9 from-scratch
definitions, 2 documented exceptions to exact-pin policy (cryptography
44.0.0 instead of 46.0.7 to dodge Rust crate vendoring; pycparser
2.22 instead of 3.0 to preserve upstream install-doc phase), and 1
wheel-fallback (jiter manylinux binary).

## Phased roadmap

| Phase | Deliverable                                                                                      | Status   |
|-------|--------------------------------------------------------------------------------------------------|----------|
| 1     | Channel scaffold (`.guix-channel`, `packages/`, `services/`, README, CLAUDE.md, git init)        | done     |
| 2     | `uv.lock` → `(guix-hermes packages python-hermes-deps)` generator; 58-package module             | done     |
| 3     | Hand-written `(guix-hermes packages hermes)` against the generated deps; `guix build` iteration  | done     |
| 4     | Runtime wrapper (PATH for nodejs/ripgrep/git/ffmpeg/openssh); bundle `skills/` + `plugins/`      | done     |
| 5     | `(guix-hermes services hermes)` — system + home service, env-file secrets pattern                | done     |
| 6     | Push to `OUH-MESHLab/guix-hermes`, wire into `~/.dotfiles/channels.scm`, deploy on curie         | **done** |

## Scope decisions (locked at planning time)

- **Extras included:** core CLI + `[messaging]` (Telegram / Discord / Slack).
- **Extras deferred:** `[voice]`, `[matrix]`, `[honcho]`, `[mcp]`, `[acp]`,
  TUI/web npm subtrees, `tirith`, `cua-driver`.
- **Pin discipline:** exact match with upstream.  Upstream pins
  `==X.Y.Z` everywhere for supply-chain reasons (Mini Shai-Hulud worm,
  2026-05-12).  Channel honours those pins; substitutions from upstream
  Guix only when versions match.  Where they don't, the channel ships a
  versioned variant rather than silently downgrading.
- **Service shape:** both `hermes-service-type` (system) and
  `home-hermes-service-type` (home).
- **Repo location:** `OUH-MESHLab/guix-hermes` (matches `guix-openclaw`).

## Container deployment (entelequia home fleet)

For the tiered family-assistant deployment on edison, Hermes runs **not** as the
native `hermes-service-type` but as **rootless Podman containers built from a
reproducible `guix pack` image**:

```
guix time-machine -C <channels-lock.scm> -- \
  pack -f docker -S /bin=bin -S /etc/ssl=etc/ssl \
       --entry-point=bin/hermes -m pack/hermes-pack-manifest.scm
```

(see `pack/hermes-pack-manifest.scm` + `scripts/build-hermes-image.sh`).  The
image is loaded into Podman and tagged `localhost/hermes:<channel-commit>`; one
container per tier (own `HERMES_HOME` volume + per-tier env-file + netns) with
`terminal.backend=local`, so the container itself is each tier's sandbox.
Per-tier separation is per-container, **not** per-service-instance — the native
service-type is left untouched.  `nss-certs` is added to the pack because it is
**not** in `hermes-agent`'s closure; without it outbound TLS fails silently.

## Why the upstream `flake.nix` doesn't transpile

Upstream ships a working Nix flake using `uv2nix` (a Nix library that
reads `uv.lock` and synthesises derivations for every locked dep).
That confirms the approach is tractable, but **does not transfer**:
`uv2nix` is Nix-only.  Guix has no equivalent.

What we **do** reuse from the flake (as reference, not source):

- The runtime tool list: `nodejs_22 ripgrep git openssh ffmpeg
  wl-clipboard xclip tirith`.
- The wheel-only landmine list (`numpy, pyarrow, av, onnxruntime,
  ctranslate2, faster-whisper`) — these matter only for `[voice]`,
  which is out of scope.
- The bundled-asset pattern (`skills/`, `plugins/` threaded via
  `HERMES_BUNDLED_PLUGINS`).
- The TUI/web npm subtree separation (`nix/tui.nix`, `nix/web.nix`)
  if we ever decide to ship them.

## Architecture (target)

```
.guix-channel
.upstream/                         pinned vendored copy of upstream uv.lock + pyproject.toml
guix-hermes/packages/
  hermes.scm                       Phase 3 — top-level Hermes package
  python-hermes-deps.scm           Phase 2 — generated from upstream uv.lock (58 pkgs)
guix-hermes/services/
  hermes.scm                       Phase 5 — system + home service types
scripts/
  closure.py                       inspect transitive closure under chosen extras
  regen-deps.py                    uv.lock → python-hermes-deps.scm generator
```

`python-hermes-deps.scm` is **generated** (analogous to
`guix-openclaw/packages/node-openclaw-deps.scm`).  Workflow lives in
`scripts/README.md`.

## Common commands (forward-looking)

```bash
# (Phase 3+) — once hermes.scm has a package definition:
guix build -L . hermes-agent

# (Phase 3+) — containerised dev shell:
guix shell -L . -C hermes-agent -- hermes --version
```

## Reference

- Upstream: <https://github.com/NousResearch/hermes-agent>
- `pyproject.toml` — direct dependencies, exact-pinned
- `uv.lock` — full resolved tree (source of truth for the importer)
- `flake.nix` + `nix/*.nix` — Nix reference implementation
- Sibling channel: `~/src/guix-openclaw` — same architectural pattern
  (channel layout, generated-deps file, service shape)
