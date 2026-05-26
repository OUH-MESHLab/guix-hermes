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
;;; Phase 3 scope: get `guix build hermes-agent` to succeed.  Runtime
;;; wrapping (PATH for nodejs / ripgrep / ffmpeg / git), bundled
;;; skills + plugins, and the system / home services live in Phases
;;; 4 and 5.
;;;
;;; Code:

(define-module (guix-hermes packages hermes)
  #:use-module (guix-hermes packages python-hermes-deps)
  #:use-module (guix build-system pyproject)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public hermes-agent
  (package
    (name "hermes-agent")
    (version "0.14.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://files.pythonhosted.org/packages/78/ac/"
             "0535aab709872130fca6118256315164704d92a7427be116984e6e0e3997/"
             "hermes_agent-" version ".tar.gz"))
       (sha256
        (base32 "0jysbq4jjzj473db7mxih75ha61rh3hj7772nkm0bcwhb4918b4g"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      ;; Tests pull dev-only extras (debugpy, pytest-split, pytest-xdist,
      ;; ty, ruff) that are deliberately out of scope.
      #:tests? #f))
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
                             ;  pulled via python-hermes-deps if listed).
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
