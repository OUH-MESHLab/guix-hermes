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
;;; Phase 5 will add:
;;;   - hermes-service-type      (system) — long-running gateway on a server
;;;   - home-hermes-service-type (Guix Home) — workstation-level daemon
;;;
;;; Both follow the env-file pattern (secrets sourced from a file managed
;;; out of band by sops/pass) — same shape as (guix-openclaw services
;;; openclaw).
;;;
;;; Code:

(define-module (guix-hermes services hermes)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix records))
