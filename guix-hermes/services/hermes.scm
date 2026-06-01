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
;;; Two shepherd services for `hermes gateway`:
;;;
;;;   hermes-service-type        — system service (runs as a dedicated
;;;                                 `hermes' user, state in /var/lib/hermes).
;;;   home-hermes-service-type   — Guix Home service (runs as the user,
;;;                                 state in ~/.hermes).
;;;
;;; Both invoke `hermes gateway' under shepherd.  Secrets (OpenAI key,
;;; Anthropic key, Telegram bot token, Discord token, Slack signing
;;; secret, …) belong in an `environment-file' — a plain KEY=value file
;;; readable only by the service user, managed out of band by sops, pass,
;;; or whichever secret store you use.  Never put secrets in the service
;;; record (it lands in the world-readable Guix store).
;;;
;;; Usage — system (server / NAS):
;;;
;;;   (service hermes-service-type
;;;     (hermes-configuration
;;;       (environment-file "/etc/hermes/secrets.env")
;;;       (log-level "info")))
;;;
;;;   /etc/hermes/secrets.env example:
;;;     OPENAI_API_KEY=sk-...
;;;     ANTHROPIC_API_KEY=sk-ant-...
;;;     TELEGRAM_BOT_TOKEN=123:ABC...
;;;     DISCORD_BOT_TOKEN=...
;;;     SLACK_SIGNING_SECRET=...
;;;
;;; Usage — home (workstation):
;;;
;;;   (service home-hermes-service-type
;;;     (home-hermes-configuration
;;;       (environment-file
;;;         (string-append (getenv "HOME") "/.hermes/secrets.env"))))
;;;
;;; Code:

(define-module (guix-hermes services hermes)
  #:use-module (guix-hermes packages hermes)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages admin)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix records)
  #:export (hermes-configuration
            hermes-configuration?
            hermes-configuration-hermes
            hermes-configuration-user
            hermes-configuration-group
            hermes-configuration-home-directory
            hermes-configuration-environment-file
            hermes-configuration-log-level
            hermes-configuration-extra-args
            hermes-service-type

            home-hermes-configuration
            home-hermes-configuration?
            home-hermes-configuration-hermes
            home-hermes-configuration-environment-file
            home-hermes-configuration-log-level
            home-hermes-configuration-extra-args
            home-hermes-service-type))


;;;
;;; Configuration records
;;;

(define-record-type* <hermes-configuration>
  hermes-configuration make-hermes-configuration
  hermes-configuration?
  ;; The hermes-agent package to invoke.
  (hermes            hermes-configuration-hermes
                     (default hermes-agent))
  ;; System user that owns the process.
  (user              hermes-configuration-user
                     (default "hermes"))
  ;; System group.
  (group             hermes-configuration-group
                     (default "hermes"))
  ;; HERMES_HOME — root of all persistent Hermes state (sessions,
  ;; memory, skills index, downloads).
  (home-directory    hermes-configuration-home-directory
                     (default "/var/lib/hermes"))
  ;; Path to a KEY=value file sourced at startup.  Keeps API keys and
  ;; channel tokens out of the world-readable Guix store.
  (environment-file  hermes-configuration-environment-file
                     (default #f))
  ;; Log verbosity.  Hermes itself honours HERMES_LOG_LEVEL.
  (log-level         hermes-configuration-log-level
                     (default "info"))
  ;; Extra arguments to pass to `hermes gateway' (a list of strings).
  (extra-args        hermes-configuration-extra-args
                     (default '())))

(define-record-type* <home-hermes-configuration>
  home-hermes-configuration make-home-hermes-configuration
  home-hermes-configuration?
  (hermes            home-hermes-configuration-hermes
                     (default hermes-agent))
  (environment-file  home-hermes-configuration-environment-file
                     (default #f))
  (log-level         home-hermes-configuration-log-level
                     (default "info"))
  (extra-args        home-hermes-configuration-extra-args
                     (default '())))


;;;
;;; System accounts
;;;

(define %hermes-accounts
  (list (user-group
         (name "hermes")
         (system? #t))
        (user-account
         (name "hermes")
         (group "hermes")
         (system? #t)
         (comment "Hermes Agent gateway daemon")
         (home-directory "/var/lib/hermes")
         (shell (file-append shadow "/sbin/nologin")))))


;;;
;;; Activation — system service only
;;;
;;; Creates HERMES_HOME (state dir) with correct ownership and a
;;; permission bit that lets only the service user read it.  The
;;; first launch of `hermes setup' would populate config.yaml; we
;;; deliberately don't seed one here because Hermes config is
;;; interactive (model picks, OAuth provider, channel onboarding).
;;;

(define (hermes-activation config)
  (let ((state-dir (hermes-configuration-home-directory config))
        (user      (hermes-configuration-user config)))
    #~(begin
        (use-modules (guix build utils))
        (let* ((u   (getpwnam #$user))
               (uid (passwd:uid u))
               (gid (passwd:gid u)))
          (mkdir-p #$state-dir)
          (chown #$state-dir uid gid)
          (chmod #$state-dir #o750)))))


;;;
;;; Environment-variable construction
;;;
;;; Builds the env-var list passed to make-forkexec-constructor.
;;; Lines from ENV-FILE (KEY=VALUE only, comments and blanks dropped)
;;; are appended after the base set so they override defaults.
;;;

(define (hermes-environment-variables home-dir log-level env-file)
  #~(let* ((base-env
            (list (string-append "HERMES_HOME=" #$home-dir)
                  (string-append "HERMES_LOG_LEVEL=" #$log-level)
                  ;; Keep TLS roots reachable for the runtime providers.
                  "SSL_CERT_DIR=/etc/ssl/certs"
                  "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"))
           (file-env
            (if (and #$env-file (file-exists? #$env-file))
                (filter (lambda (s)
                          (and (not (string-null? s))
                               (not (string-prefix? "#" s))
                               (string-index s #\=)))
                        (string-split
                         (call-with-input-file #$env-file
                           (@ (ice-9 textual-ports) get-string-all))
                         #\newline))
                '())))
      (append base-env file-env)))


;;;
;;; System shepherd service
;;;

(define (hermes-shepherd-service config)
  (let* ((pkg        (hermes-configuration-hermes config))
         (user       (hermes-configuration-user config))
         (group      (hermes-configuration-group config))
         (state-dir  (hermes-configuration-home-directory config))
         (log-level  (hermes-configuration-log-level config))
         (env-file   (hermes-configuration-environment-file config))
         (extra-args (hermes-configuration-extra-args config))
         (env-vars   (hermes-environment-variables
                      state-dir log-level env-file)))
    (list
     (shepherd-service
      (provision '(hermes))
      (documentation "Run the Hermes Agent gateway.")
      (requirement '(user-processes networking))
      (modules '((ice-9 textual-ports)))
      (start #~(lambda _
                 ((make-forkexec-constructor
                   (cons* #$(file-append pkg "/bin/hermes")
                          ;; `gateway' is a command GROUP; `run' is the
                          ;; foreground entry point.  Bare `gateway' only
                          ;; works via an implicit default and is fragile.
                          "gateway" "run"
                          (list #$@extra-args))
                   #:user #$user
                   #:group #$group
                   #:log-file (string-append #$state-dir "/hermes.log")
                   #:environment-variables #$env-vars))))
      (stop #~(make-kill-destructor))
      (respawn? #t)))))


;;;
;;; System service type
;;;

(define hermes-service-type
  (service-type
   (name 'hermes)
   (extensions
    (list (service-extension shepherd-root-service-type
                             hermes-shepherd-service)
          (service-extension account-service-type
                             (const %hermes-accounts))
          (service-extension activation-service-type
                             hermes-activation)))
   (default-value (hermes-configuration))
   (description
    "Run the Hermes Agent gateway as a Shepherd system service.
Hermes routes LLM conversations through Telegram, Discord, Slack,
and other messaging platforms.  API keys and channel credentials
belong in the @var{environment-file}, not in the service record
itself (that file lives in the world-readable Guix store).")))


;;;
;;; Home shepherd service
;;;

(define (home-hermes-shepherd-service config)
  (let* ((pkg        (home-hermes-configuration-hermes config))
         (log-level  (home-hermes-configuration-log-level config))
         (env-file   (home-hermes-configuration-environment-file config))
         (extra-args (home-hermes-configuration-extra-args config))
         ;; Home-mode HERMES_HOME resolves to $HOME/.hermes by default;
         ;; pass an empty string here so the upstream code path picks
         ;; the default via `get_hermes_home`.  Logs go under
         ;; $HOME/.hermes/hermes.log (the default state dir).
         (state-dir "")
         (env-vars   (hermes-environment-variables
                      state-dir log-level env-file)))
    (list
     (shepherd-service
      (provision '(hermes))
      (documentation "Run the Hermes Agent gateway (home service).")
      (requirement '())
      (modules '((ice-9 textual-ports)))
      (start #~(lambda _
                 ((make-forkexec-constructor
                   (cons* #$(file-append pkg "/bin/hermes")
                          ;; `gateway' is a command GROUP; `run' is the
                          ;; foreground entry point.  Bare `gateway' only
                          ;; works via an implicit default and is fragile.
                          "gateway" "run"
                          (list #$@extra-args))
                   #:log-file (string-append
                               (getenv "HOME") "/.hermes/hermes.log")
                   #:environment-variables #$env-vars))))
      (stop #~(make-kill-destructor))
      (respawn? #t)))))


;;;
;;; Home service type
;;;

(define home-hermes-service-type
  (service-type
   (name 'home-hermes)
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-hermes-shepherd-service)
          (service-extension home-profile-service-type
                             (compose list home-hermes-configuration-hermes))))
   (default-value (home-hermes-configuration))
   (description
    "Run the Hermes Agent gateway as a Guix Home Shepherd service.
State is kept in @file{~/.hermes}.  API keys and channel credentials
belong in the @var{environment-file}, not in the service record.")))
