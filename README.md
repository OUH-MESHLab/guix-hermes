# guix-hermes

A [Guix](https://guix.gnu.org) channel that provides declarative, reproducible
package and service definitions for
[Hermes Agent](https://github.com/NousResearch/hermes-agent) — Nous Research's
self-improving AI agent that creates skills from experience, persists across
sessions, and runs anywhere from a $5 VPS to a GPU cluster.

**Status:** early scaffold (Phase 1 of 6 — see `CLAUDE.md`).  The channel
currently exports no packages.  Don't add it to your `channels.scm` yet.

---

## Planned contents

| Module                                          | What it will provide                                                                       |
|-------------------------------------------------|--------------------------------------------------------------------------------------------|
| `(guix-hermes packages hermes)`                 | The `hermes-agent` package (Python, pyproject-build-system)                                |
| `(guix-hermes packages python-hermes-deps)`     | Generated PyPI dependency tree (synthesised from upstream `uv.lock`)                       |
| `(guix-hermes services hermes)`                 | `hermes-service-type` (system) and `home-hermes-service-type` (Guix Home), env-file based  |

---

## Scope (initial)

- **Core CLI** + `[messaging]` extras (Telegram / Discord / Slack).
- `[voice]`, `[matrix]`, `[honcho]`, `[mcp]`, `[acp]`, TUI/web subtrees:
  deferred — see `CLAUDE.md` for the phased roadmap.
- **Exact upstream pins honoured** — upstream's supply-chain policy after the
  Mini Shai-Hulud worm (2026-05-12) makes version skew load-bearing.
  Synthesis driven directly from upstream `uv.lock`.

---

## Upstream reference

- Repo: <https://github.com/NousResearch/hermes-agent>
- License: MIT
- Build system: setuptools / `pyproject-build-system`
- Python: `>=3.11` (upstream Nix flake uses `python312`)
- Runtime deps (non-Python): `nodejs_22`, `ripgrep`, `git`, `openssh`,
  `ffmpeg`, `wl-clipboard`/`xclip`
- The upstream `flake.nix` + `nix/*.nix` use `uv2nix` to synthesise the
  dependency tree from `uv.lock`.  Guix has no `uv2nix` equivalent, so
  guix-hermes will ship its own `uv.lock` reader (Phase 2).
