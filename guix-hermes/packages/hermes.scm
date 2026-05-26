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
;;; License : MIT
;;; Build   : pyproject-build-system (setuptools backend), Python >=3.11.
;;;
;;; Phase 1 stub.  The (define-public hermes-agent ...) form is intentionally
;;; absent until Phase 3 — the dependency tree must be synthesised first
;;; (see (guix-hermes packages python-hermes-deps), Phase 2).
;;;
;;; Code:

(define-module (guix-hermes packages hermes)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:))
