;;; guix-hermes --- Guix channel for Hermes Agent
;;; Copyright © 2026 Rafael Palomar <rafael.palomar@ous-research.no>
;;;
;;; This file is part of guix-hermes.
;;;
;;; guix-hermes is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; guix-hermes is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with guix-hermes.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;;
;;; Upstream: https://github.com/NousResearch/hermes-agent
;;; License : MIT (Expat)
;;; Build   : pyproject-build-system (setuptools backend), Python >=3.11
;;;
;;; The full transitive runtime dependency closure lives in
;;; (guix-hermes packages python-hermes-deps).  This module names the
;;; direct dependencies — both core and the `[messaging]` extra — and
;;; the build system resolves the rest through propagated-inputs.
;;;
;;; Phase 4 additions on top of Phase 3:
;;;
;;;   - install-bundled-assets phase
;;;       Copies the upstream `skills/`, `plugins/` and `optional-skills/`
;;;       trees from the source checkout to `<out>/share/hermes-agent/`,
;;;       filtering out `__pycache__/` and `index-cache/` directories.
;;;       Mirrors what upstream's Nix flake does in `nix/hermes-agent.nix`.
;;;
;;;   - wrap-runtime phase
;;;       Wraps every entry-point under `<out>/bin/` with:
;;;         * PATH prefix for nodejs, ripgrep, git, ffmpeg, openssh,
;;;           wl-clipboard, xclip — every tool Hermes shells out to.
;;;         * HERMES_BUNDLED_SKILLS, HERMES_BUNDLED_PLUGINS and
;;;           HERMES_OPTIONAL_SKILLS pointed at the share/ tree.
;;;       The env-var names match what `hermes_cli/plugins.py` and
;;;       `tools/skills_sync.py` actually read at runtime.
;;;
;;; Code:

(define-module (guix-hermes packages hermes)
  #:use-module (guix-hermes packages python-hermes-deps)
  #:use-module (guix build-system pyproject)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (gnu packages bash)            ; bash-minimal (wrap-program)
  #:use-module (gnu packages freedesktop)     ; wl-clipboard
  #:use-module (gnu packages node)            ; node
  #:use-module (gnu packages python-build)    ; python-setuptools
  #:use-module (gnu packages rust-apps)       ; ripgrep
  #:use-module (gnu packages ssh)             ; openssh
  #:use-module (gnu packages version-control) ; git
  #:use-module (gnu packages video)           ; ffmpeg
  #:use-module (gnu packages xdisorg))        ; xclip

(define-public hermes-agent
  (package
    (name "hermes-agent")
    (version "0.15.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://files.pythonhosted.org/packages/21/c9/"
             "df2a8712a5924c7b2370bad0b544eb21a7bf7c1ec0ff4f1e0a2d93b5dfd7/"
             "hermes_agent-" version ".tar.gz"))
       (sha256
        (base32 "1vx3vhl3xsh6q5570s1v4p03yjdwc3k65y045xy7yhymszq94y77"))
       (modules '((guix build utils)))
       (snippet
        ;; Relax pyyaml's exact-equality pin so the Guix sanity-check
        ;; phase passes when the dep lands at the channel-pinned
        ;; (downgraded) 6.0.2 instead of upstream's 6.0.3.  pyyaml
        ;; patch-version diffs touch only the bundled LibYAML
        ;; snapshot, not the Python API.  Upstream pins exactly for
        ;; supply-chain reasons; this exception is documented in
        ;; PIN_DOWNGRADES (see scripts/regen-deps.py).
        #~(begin
            (substitute* "pyproject.toml"
              (("^[[:space:]]*\"pyyaml==6\\.0\\.3\",")
               "  \"pyyaml>=6.0,<7\","))))))
    (build-system pyproject-build-system)
    (arguments
     (list
      ;; Tests pull dev-only extras (debugpy, pytest-split, pytest-xdist,
      ;; ty, ruff) that are deliberately out of scope.
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-bundled-assets
            (lambda _
              ;; Copy skills/, plugins/, optional-skills/ from the source
              ;; tree to <out>/share/hermes-agent/, filtering out caches.
              ;; setup.py's data_files declaration drops them outside
              ;; site-packages, so we install them by hand here.
              (let ((share (string-append #$output
                                          "/share/hermes-agent")))
                (for-each
                 (lambda (dir)
                   (when (file-exists? dir)
                     (copy-recursively
                      dir
                      (string-append share "/" dir)
                      #:select?
                      (lambda (file stat)
                        (let ((b (basename file)))
                          (not (or (string=? b "__pycache__")
                                   (string=? b "index-cache"))))))))
                 (list "skills" "plugins" "optional-skills")))))
          (add-after 'wrap 'wrap-runtime
            (lambda _
              ;; Prepend runtime tools to PATH and pin HERMES_BUNDLED_*
              ;; to the share/ tree.  Hermes shells out to node (LSP +
              ;; browser-automation glue), ripgrep (search), git
              ;; (repo introspection), ffmpeg (audio/voice memos),
              ;; openssh (remote terminal backends).  Clipboard tools
              ;; let `hermes` paste into the TUI on Wayland / X11.
              (let* ((out      #$output)
                     (bin      (string-append out "/bin"))
                     (share    (string-append out "/share/hermes-agent"))
                     (tool-bin (lambda (p)
                                 (string-append p "/bin")))
                     (path
                      (string-join
                       (list (tool-bin #$(this-package-input "node"))
                             (tool-bin #$(this-package-input "ripgrep"))
                             (tool-bin #$(this-package-input "git"))
                             (tool-bin #$(this-package-input "ffmpeg"))
                             (tool-bin #$(this-package-input "openssh"))
                             (tool-bin #$(this-package-input "wl-clipboard"))
                             (tool-bin #$(this-package-input "xclip")))
                       ":")))
                (for-each
                 (lambda (prog)
                   (when (file-exists? prog)
                     (wrap-program prog
                       `("PATH" ":" prefix (,path))
                       `("HERMES_BUNDLED_SKILLS" =
                         (,(string-append share "/skills")))
                       `("HERMES_BUNDLED_PLUGINS" =
                         (,(string-append share "/plugins")))
                       `("HERMES_OPTIONAL_SKILLS" =
                         (,(string-append share "/optional-skills"))))))
                 (list (string-append bin "/hermes")
                       (string-append bin "/hermes-agent")
                       (string-append bin "/hermes-acp")))))))))
    (native-inputs
     (list python-setuptools))
    (inputs
     ;; Runtime dependencies that `hermes` invokes as subprocesses or
     ;; whose bin/ goes on PATH via the wrap-runtime phase.
     (list bash-minimal              ; wrap-program needs sh
           node                      ; v22.16 on current Guix; engines.node >= 20
           ripgrep
           git
           ffmpeg
           openssh
           wl-clipboard
           xclip))
    (propagated-inputs
     ;; Order mirrors upstream pyproject.toml [project.dependencies] +
     ;; [project.optional-dependencies.messaging].  Win32-only tzdata
     ;; omitted (Guix targets POSIX).
     (list
      ;; Core
      python-croniter
      python-cryptography
      python-fire
      python-httpx           ; pyproject pins httpx[socks]; socks support
                             ; needs python-socksio at runtime (transitive,
                             ; pulled via python-hermes-deps if listed).
      python-jinja2
      python-openai
      python-prompt-toolkit
      python-psutil
      python-pydantic
      python-pyjwt           ; pyproject pins pyjwt[crypto] — extra deps
                             ; (cryptography) overlap with core, already
                             ; in the closure.
      python-python-dotenv
      python-pyyaml
      python-requests
      python-rich
      python-ruamel-yaml
      python-tenacity
      ;; Messaging extra
      python-aiohttp
      python-brotlicffi
      python-discord-py
      python-python-telegram-bot
      python-qrcode
      python-slack-bolt
      python-slack-sdk))
    (home-page "https://github.com/NousResearch/hermes-agent")
    (synopsis "Self-improving AI agent — terminal-first, multi-platform")
    (description
     "Hermes Agent is a self-hosted AI assistant that creates skills from
experience, persists across sessions, and routes conversations through
messaging platforms (Telegram, Discord, Slack, and others).  It runs from a
single gateway process and supports model providers such as OpenAI,
Anthropic, OpenRouter, and self-hosted endpoints.

This package ships the core CLI plus the messaging adapters (Telegram,
Discord, Slack).  Optional extras for voice (faster-whisper, local STT),
Matrix bridges, Honcho, MCP and ACP are deliberately omitted; add them
out of band if needed.")
    (license license:expat)))
