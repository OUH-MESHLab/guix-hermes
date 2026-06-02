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
;;;   guix repl scripts/probe-upstream.guile < /tmp/want.tsv \
;;;     > .upstream/upstream-map.data
;;;   guix shell python python-packaging curl gzip tar -- \
;;;     python3 scripts/regen-deps.py --extras=messaging
;;;
;;; Source of truth: .upstream/uv.lock at upstream tag v2026.5.16.
;;; Closure: 62 Python packages (core + extras: messaging, pty).
;;;
;;; Strategy per package (driven by .upstream/upstream-map.data):
;;;   - match     (19): re-export upstream Guix definition
;;;   - mismatch  (26): inherit upstream, bump version + source
;;;   - missing   (11): full from-scratch definition
;;;   - downgrade (6): re-export upstream despite version drift
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
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-compression)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages time))

;; pure re-export (2.6.1 from (gnu packages python-web))
(define-public python-aiohappyeyeballs
  (@ (gnu packages python-web) python-aiohappyeyeballs))

;; mismatch: want 3.13.3, upstream Guix has 3.11.18
(define-public python-aiohttp
  (let ((base (@ (gnu packages python-web) python-aiohttp)))
    (package
      (inherit base)
      (version "3.13.3")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/50/42/32cf8e7704ceb4481406eb87161349abb46a57fee3f008ba9cb610968646/aiohttp-3.13.3.tar.gz")
         (sha256
          (base32 "124zpgyxm16ccxq94ykz7dfhr6ybn8cjhjjgmvdg50ip7pjfwjd9"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-aiohappyeyeballs python-aiosignal python-attrs python-frozenlist python-multidict python-propcache python-yarl)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; match: 1.4.0 (from (gnu packages python-web)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-aiosignal
  (let ((base (@ (gnu packages python-web) python-aiosignal)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-frozenlist python-typing-extensions)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; pure re-export (0.7.0 from (gnu packages python-xyz))
(define-public python-annotated-types
  (@ (gnu packages python-xyz) python-annotated-types))

;; match: 4.12.1 (from (gnu packages python-xyz)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-anyio
  (let ((base (@ (gnu packages python-xyz) python-anyio)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-idna python-typing-extensions)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 25.4.0, upstream Guix has 25.3.0
(define-public python-attrs
  (let ((base (@ (gnu packages python-xyz) python-attrs)))
    (package
      (inherit base)
      (version "25.4.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/6b/5c/685e6633917e101e5dcb62b9dd76946cbb57c26e133bae9e0cd36033c0a9/attrs-25.4.0.tar.gz")
         (sha256
          (base32 "04byqlshrdvxb4xqaplxwhmf9rhvmiamvcs87brrx1ghhydrdm8n"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling python-hatch-vcs python-hatch-fancy-pypi-readme)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 1.2.0.1, upstream Guix has 1.1.0.0
(define-public python-brotlicffi
  (let ((base (@ (gnu packages python-compression) python-brotlicffi)))
    (package
      (inherit base)
      (version "1.2.0.1")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/8a/b6/017dc5f852ed9b8735af77774509271acbf1de02d238377667145fcee01d/brotlicffi-1.2.0.1.tar.gz")
         (sha256
          (base32 "0732blw0kh284l67jssw98kylxr3i5ddk9hlck87lc3qc9cmq3f2"))))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-cffi)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; PIN DOWNGRADE: upstream Guix 2025.06.15 (closure asks 2026.2.25; see PIN_DOWNGRADES)
;; pure re-export (2025.06.15 from (gnu packages python-crypto))
(define-public python-certifi
  (@ (gnu packages python-crypto) python-certifi))

;; PIN DOWNGRADE: upstream Guix 1.17.1 (closure asks 2.0.0; see PIN_DOWNGRADES)
;; pure re-export (1.17.1 from (gnu packages libffi))
(define-public python-cffi
  (@ (gnu packages libffi) python-cffi))

;; mismatch: want 3.4.4, upstream Guix has 3.4.2
(define-public python-charset-normalizer
  (let ((base (@ (gnu packages python-xyz) python-charset-normalizer)))
    (package
      (inherit base)
      (version "3.4.4")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/13/69/33ddede1939fdd074bce5434295f38fae7136463422fe4fd3e0e89b98062/charset_normalizer-3.4.4.tar.gz")
         (sha256
          (base32 "06p20hsbfmg9pdc307ffnb7nwfmlwyw06dp4423z4d8w262pjlwl"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 6.0.0, upstream Guix has 5.0.1
(define-public python-croniter
  (let ((base (@ (gnu packages python-xyz) python-croniter)))
    (package
      (inherit base)
      (version "6.0.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/ad/2f/44d1ae153a0e27be56be43465e5cb39b9650c781e001e7864389deb25090/croniter-6.0.0.tar.gz")
         (sha256
          (base32 "0xsm4m44f89r8z4irn799w4z3cchfyqc5qpchfli8qcm2frh9i9p"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-python-dateutil python-pytz)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; PIN DOWNGRADE: upstream Guix 44.0.0 (closure asks 46.0.7; see PIN_DOWNGRADES)
;; pure re-export (44.0.0 from (gnu packages python-crypto))
(define-public python-cryptography
  (@ (gnu packages python-crypto) python-cryptography))

;; missing from upstream Guix — full hand-defined package
(define-public python-davey
  (package
    (name "python-davey")
    (version "0.1.4")
    ;; binary wheel (Rust extension) — see WHEEL_FALLBACK in scripts/regen-deps.py
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/68/aa/c250f75cb6a4213e1f01eb965180f30ff9dda834d11a4a2e5895c96989fe/davey-0.1.4-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl")
       (sha256
        (base32 "021cx6h9mm9vd6043gwdc5xh7d279vbm104085d876giixfn9vwd"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (mkdir-p "dist")
              (copy-file source
                         (string-append "dist/" (basename source)))))
          (delete 'build)
          (delete 'validate-runpath))))
    (home-page "https://pypi.org/project/davey/")
    (synopsis "davey (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{davey} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-discord-py
  (package
    (name "python-discord-py")
    (version "2.7.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ef/57/9a2d9abdabdc9db8ef28ce0cf4129669e1c8717ba28d607b5ba357c4de3b/discord_py-2.7.1.tar.gz")
       (sha256
        (base32 "1nj929j1351if3bbchgvr715vljhnpb9v2hlk15jw59manjfdm94"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-setuptools))
    (propagated-inputs
     (list python-aiohttp python-davey python-pynacl))
    (home-page "https://pypi.org/project/discord-py/")
    (synopsis "discord-py (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{discord-py} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; pure re-export (1.9.0 from (gnu packages python-xyz))
(define-public python-distro
  (@ (gnu packages python-xyz) python-distro))

;; mismatch: want 0.7.1, upstream Guix has 0.7.0
(define-public python-fire
  (let ((base (@ (gnu packages python-xyz) python-fire)))
    (package
      (inherit base)
      (version "0.7.1")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/c0/00/f8d10588d2019d6d6452653def1ee807353b21983db48550318424b5ff18/fire-0.7.1.tar.gz")
         (sha256
          (base32 "1gww18kqdi9pp0r4zsl95a5wgn64vj8d041k6kxripinqw2qy81v"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-termcolor)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; pure re-export (1.8.0 from (gnu packages python-web))
(define-public python-frozenlist
  (@ (gnu packages python-web) python-frozenlist))

;; pure re-export (0.16.0 from (gnu packages python-web))
(define-public python-h11
  (@ (gnu packages python-web) python-h11))

;; match: 1.0.9 (from (gnu packages python-web)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-httpcore
  (let ((base (@ (gnu packages python-web) python-httpcore)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-certifi python-h11)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; match: 0.28.1 (from (gnu packages python-web)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-httpx
  (let ((base (@ (gnu packages python-web) python-httpx)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-anyio python-certifi python-httpcore python-idna python-socksio)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 3.15, upstream Guix has 3.10
(define-public python-idna
  (let ((base (@ (gnu packages python-xyz) python-idna)))
    (package
      (inherit base)
      (version "3.15")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/82/77/7b3966d0b9d1d31a36ddf1746926a11dface89a83409bf1483f0237aa758/idna-3.15.tar.gz")
         (sha256
          (base32 "1p2znvysp572n791d4il9mpqi3k16yj7s1aym69713skx93295na"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-flit-core)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 3.1.6, upstream Guix has 3.1.2
(define-public python-jinja2
  (let ((base (@ (gnu packages python-xyz) python-jinja2)))
    (package
      (inherit base)
      (version "3.1.6")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz")
         (sha256
          (base32 "0vbdyr1vx0w1hgxs149lr0gq5njndpp9lzjqb8kz2d8dk42zndq1"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-flit-core)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-markupsafe)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; missing from upstream Guix — full hand-defined package
(define-public python-jiter
  (package
    (name "python-jiter")
    (version "0.13.0")
    ;; binary wheel (Rust extension) — see WHEEL_FALLBACK in scripts/regen-deps.py
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/f8/4c/09b93e30e984a187bc8aaa3510e1ec8dcbdcd71ca05d2f56aac0492453aa/jiter-0.13.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl")
       (sha256
        (base32 "14sdpdsrgzlwyfx0fy9ih90qixsbzk5svjyq8ln6mwk6gvcagaxx"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (mkdir-p "dist")
              (copy-file source
                         (string-append "dist/" (basename source)))))
          (delete 'build)
          (delete 'validate-runpath))))
    (home-page "https://pypi.org/project/jiter/")
    (synopsis "jiter (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{jiter} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; mismatch: want 4.0.0, upstream Guix has 3.0.0
(define-public python-markdown-it-py
  (let ((base (@ (gnu packages python-xyz) python-markdown-it-py)))
    (package
      (inherit base)
      (version "4.0.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/5b/f5/4ec618ed16cc4f8fb3b701563655a69816155e79e24a17b651541804721d/markdown_it_py-4.0.0.tar.gz")
         (sha256
          (base32 "1wxr3kd9q02rmidyng0k4knf0x5x8plr9c8pf402r4sgld52n2nb"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-flit-core)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-mdurl)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; pure re-export (3.0.3 from (gnu packages python-xyz))
(define-public python-markupsafe
  (@ (gnu packages python-xyz) python-markupsafe))

;; pure re-export (0.1.2 from (gnu packages python-xyz))
(define-public python-mdurl
  (@ (gnu packages python-xyz) python-mdurl))

;; mismatch: want 6.7.1, upstream Guix has 6.7.0
(define-public python-multidict
  (let ((base (@ (gnu packages python-xyz) python-multidict)))
    (package
      (inherit base)
      (version "6.7.1")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/1a/c2/c2d94cbe6ac1753f3fc980da97b3d930efe1da3af3c9f5125354436c073d/multidict-6.7.1.tar.gz")
         (sha256
          (base32 "0gb2mhmp30jgs2d8rw9lpambclrc2x4n0svpwnim6776pshm4rpc"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 2.24.0, upstream Guix has 1.3.5
(define-public python-openai
  (let ((base (@ (gnu packages python-web) python-openai)))
    (package
      (inherit base)
      (version "2.24.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/55/13/17e87641b89b74552ed408a92b231283786523edddc95f3545809fab673c/openai-2.24.0.tar.gz")
         (sha256
          (base32 "0wx6k6zy49grqpwsyd57c58nk7bvwqinlwf47frirl6v83snjmqy"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling python-hatch-fancy-pypi-readme)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-anyio python-distro python-httpx python-jiter python-pydantic python-sniffio python-tqdm python-typing-extensions)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 3.0.52, upstream Guix has 3.0.51
(define-public python-prompt-toolkit
  (let ((base (@ (gnu packages python-xyz) python-prompt-toolkit)))
    (package
      (inherit base)
      (version "3.0.52")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/a1/96/06e01a7b38dce6fe1db213e061a4602dd6032a8a97ef6c1a862537732421/prompt_toolkit-3.0.52.tar.gz")
         (sha256
          (base32 "0mg83cmh8h6qxlbjwbxh918kgw9nwzdivpl5vqhp73lwja9f3k98"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-wcwidth)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 0.4.1, upstream Guix has 0.2.1
(define-public python-propcache
  (let ((base (@ (gnu packages python-xyz) python-propcache)))
    (package
      (inherit base)
      (version "0.4.1")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/9e/da/e9fc233cf63743258bff22b3dfa7ea5baef7b5bc324af47a0ad89b8ffc6f/propcache-0.4.1.tar.gz")
         (sha256
          (base32 "0gbwr4il9v049wvspi3wal73f85ykbsfqdszami07s1pqsl0g0gl"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools python-cython gcc-toolchain python-expandvars)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 7.2.2, upstream Guix has 7.0.0
(define-public python-psutil
  (let ((base (@ (gnu packages python-xyz) python-psutil)))
    (package
      (inherit base)
      (version "7.2.2")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz")
         (sha256
          (base32 "0wlkyn4bpd40dnhxdf1v56y3vhzmlpdciwa7sm7k9bq6skwgaih7"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; missing from upstream Guix — full hand-defined package
(define-public python-ptyprocess
  (package
    (name "python-ptyprocess")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/20/e5/16ff212c1e452235a90aeb09066144d0c5a6a8c0834397e03f5224495c4e/ptyprocess-0.7.0.tar.gz")
       (sha256
        (base32 "081j893x6c9qrfszp8swfqlpvk8agh1jc32y9140pvnf90xhlpaw"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-flit-core))
    (home-page "https://pypi.org/project/ptyprocess/")
    (synopsis "ptyprocess (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{ptyprocess} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; PIN DOWNGRADE: upstream Guix 2.22 (closure asks 3.0; see PIN_DOWNGRADES)
;; pure re-export (2.22 from (gnu packages python-xyz))
(define-public python-pycparser
  (@ (gnu packages python-xyz) python-pycparser))

;; missing from upstream Guix — full hand-defined package
(define-public python-pydantic
  (package
    (name "python-pydantic")
    (version "2.13.4")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/18/a5/b60d21ac674192f8ab0ba4e9fd860690f9b4a6e51ca5df118733b487d8d6/pydantic-2.13.4.tar.gz")
       (sha256
        (base32 "1xly174bw09r8izym10fz4sw9dzkyfbc3mffxvpv3a6sgasmc1y4"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-hatchling python-hatch-fancy-pypi-readme))
    (propagated-inputs
     (list python-annotated-types python-pydantic-core python-typing-extensions python-typing-inspection))
    (home-page "https://pypi.org/project/pydantic/")
    (synopsis "pydantic (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pydantic} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-pydantic-core
  (package
    (name "python-pydantic-core")
    (version "2.46.4")
    ;; binary wheel (Rust extension) — see WHEEL_FALLBACK in scripts/regen-deps.py
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/5f/97/2aab507d3d00ca626e8e57c1eac6a79e4e5fbcc63eb99733ff55d1717f65/pydantic_core-2.46.4-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl")
       (sha256
        (base32 "1kkwhgzxqbqca270mds1cdnb045mzrshp2na3mlb24jbn50rav4j"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (mkdir-p "dist")
              (copy-file source
                         (string-append "dist/" (basename source)))))
          (delete 'build)
          (delete 'validate-runpath))))
    (propagated-inputs
     (list python-typing-extensions))
    (home-page "https://pypi.org/project/pydantic-core/")
    (synopsis "pydantic-core (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pydantic-core} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; mismatch: want 2.19.2, upstream Guix has 2.19.1
(define-public python-pygments
  (let ((base (@ (gnu packages python-build) python-pygments)))
    (package
      (inherit base)
      (version "2.19.2")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/b0/77/a5b8c569bf593b0140bde72ea885a803b82086995367bf2037de0159d924/pygments-2.19.2.tar.gz")
         (sha256
          (base32 "11xqsnnh0iip4vh2lfbh5xa46dy47d9vqw39ad98jzzcgi3v4v33"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 2.12.1, upstream Guix has 2.10.1
(define-public python-pyjwt
  (let ((base (@ (gnu packages python-xyz) python-pyjwt)))
    (package
      (inherit base)
      (version "2.12.1")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/c2/27/a3b6e5bf6ff856d2509292e95c8f57f0df7017cf5394921fc4e4ef40308a/pyjwt-2.12.1.tar.gz")
         (sha256
          (base32 "0av70ddpd7bhpy014rwf491b5gl4bzc3swfv0b808746vwm7ljn7"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-cryptography)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; match: 1.5.0 (from (gnu packages python-crypto)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-pynacl
  (let ((base (@ (gnu packages python-crypto) python-pynacl)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-cffi)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; pure re-export (0.20220715.0 from (gnu packages python-xyz))
(define-public python-pypng
  (@ (gnu packages python-xyz) python-pypng))

;; missing from upstream Guix — full hand-defined package
(define-public python-python-dateutil
  (package
    (name "python-python-dateutil")
    (version "2.9.0.post0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz")
       (sha256
        (base32 "1lqak92ka6p96wjbf3zr9691gm7b01g7s8c8af3wvqd7ilh59p9p"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-setuptools python-setuptools-scm))
    (propagated-inputs
     (list python-six))
    (home-page "https://pypi.org/project/python-dateutil/")
    (synopsis "python-dateutil (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-dateutil} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-python-dotenv
  (package
    (name "python-python-dotenv")
    (version "1.2.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/82/ed/0301aeeac3e5353ef3d94b6ec08bbcabd04a72018415dcb29e588514bba8/python_dotenv-1.2.2.tar.gz")
       (sha256
        (base32 "1wwwg7gasqmnv5y2hb3w1155c8nai6zzih8x5hn0ifnpzf8ildrc"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check))))
    (native-inputs
     (list python-setuptools))
    (home-page "https://pypi.org/project/python-dotenv/")
    (synopsis "python-dotenv (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-dotenv} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-python-telegram-bot
  (package
    (name "python-python-telegram-bot")
    (version "22.6")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/cd/9b/8df90c85404166a6631e857027866263adb27440d8af1dbeffbdc4f0166c/python_telegram_bot-22.6.tar.gz")
       (sha256
        (base32 "0hip24nvzhgl3nlr4swnarwz6887098pjs18ar203zwd1z0qrbjh"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-hatchling))
    (propagated-inputs
     (list python-httpx python-tornado))
    (home-page "https://pypi.org/project/python-telegram-bot/")
    (synopsis "python-telegram-bot (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-telegram-bot} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; PIN DOWNGRADE: upstream Guix 2025.1 (closure asks 2025.2; see PIN_DOWNGRADES)
;; pure re-export (2025.1 from (gnu packages time))
(define-public python-pytz
  (@ (gnu packages time) python-pytz))

;; PIN DOWNGRADE: upstream Guix 6.0.2 (closure asks 6.0.3; see PIN_DOWNGRADES)
;; pure re-export (6.0.2 from (gnu packages python-xyz))
(define-public python-pyyaml
  (@ (gnu packages python-xyz) python-pyyaml))

;; mismatch: want 7.4.2, upstream Guix has 8.2
(define-public python-qrcode
  (let ((base (@ (gnu packages python-xyz) python-qrcode)))
    (package
      (inherit base)
      (version "7.4.2")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/30/35/ad6d4c5a547fe9a5baf85a9edbafff93fc6394b014fab30595877305fa59/qrcode-7.4.2.tar.gz")
         (sha256
          (base32 "0iaq1yrrbb0l1z4kfa881ra6v7i38w3v55inv7djgq97912nkncx"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-pypng python-typing-extensions)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 2.33.0, upstream Guix has 2.32.5
(define-public python-requests
  (let ((base (@ (gnu packages python-web) python-requests)))
    (package
      (inherit base)
      (version "2.33.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/34/64/8860370b167a9721e8956ae116825caff829224fbca0ca6e7bf8ddef8430/requests-2.33.0.tar.gz")
         (sha256
          (base32 "0lknkpr4xwdzaci3ppyq8kssb7w2igzciqfhd8w3f67jn3lcbsy7"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-certifi python-charset-normalizer python-idna python-urllib3)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 14.3.3, upstream Guix has 14.2.0
(define-public python-rich
  (let ((base (@ (gnu packages python-xyz) python-rich)))
    (package
      (inherit base)
      (version "14.3.3")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/b3/c6/f3b320c27991c46f43ee9d856302c70dc2d0fb2dba4842ff739d5f46b393/rich-14.3.3.tar.gz")
         (sha256
          (base32 "16v31x9gwhmkbwplwkw19s442cpm2cvw11kwrzc4vxgfwjws1nmq"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-poetry-core)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-markdown-it-py python-pygments)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; missing from upstream Guix — full hand-defined package
(define-public python-ruamel-yaml
  (package
    (name "python-ruamel-yaml")
    (version "0.18.17")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/3a/2b/7a1f1ebcd6b3f14febdc003e658778d81e76b40df2267904ee6b13f0c5c6/ruamel_yaml-0.18.17.tar.gz")
       (sha256
        (base32 "0g4drmyj8ssvk1nk908kzgqyfgcc6jzzmf6xayqs98wk5mpcv4ch"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-setuptools))
    (propagated-inputs
     (list python-ruamel-yaml-clib))
    (home-page "https://pypi.org/project/ruamel-yaml/")
    (synopsis "ruamel-yaml (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{ruamel-yaml} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-ruamel-yaml-clib
  (package
    (name "python-ruamel-yaml-clib")
    (version "0.2.15")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ea/97/60fda20e2fb54b83a61ae14648b0817c8f5d84a3821e40bfbdae1437026a/ruamel_yaml_clib-0.2.15.tar.gz")
       (sha256
        (base32 "000640h0sjzd6id5ag3df254l4c2wja20lbjby498spg8f6crr26"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check))))
    (native-inputs
     (list python-setuptools))
    (home-page "https://pypi.org/project/ruamel-yaml-clib/")
    (synopsis "ruamel-yaml-clib (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{ruamel-yaml-clib} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; pure re-export (1.17.0 from (gnu packages python-build))
(define-public python-six
  (@ (gnu packages python-build) python-six))

;; missing from upstream Guix — full hand-defined package
(define-public python-slack-bolt
  (package
    (name "python-slack-bolt")
    (version "1.27.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/4c/28/50ed0b86e48b48e6ddcc71de93b91c8ac14a55d1249e4bff0586494a2f90/slack_bolt-1.27.0.tar.gz")
       (sha256
        (base32 "1q719hvnakfamp74y6p4357mba4afj1awx65cnjpdqbpw9j1vf9x"))
       ))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (native-inputs
     (list python-setuptools))
    (propagated-inputs
     (list python-slack-sdk))
    (home-page "https://pypi.org/project/slack-bolt/")
    (synopsis "slack-bolt (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{slack-bolt} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; missing from upstream Guix — full hand-defined package
(define-public python-slack-sdk
  (package
    (name "python-slack-sdk")
    (version "3.40.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/3a/18/784859b33a3f9c8cdaa1eda4115eb9fe72a0a37304718887d12991eeb2fd/slack_sdk-3.40.1.tar.gz")
       (sha256
        (base32 "1l1zxh4vygnp6ppdkdl4a4ximxkv96chh4gmynmr1g2iq8xk65d2"))
       ))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check))))
    (native-inputs
     (list python-setuptools))
    (home-page "https://pypi.org/project/slack-sdk/")
    (synopsis "slack-sdk (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{slack-sdk} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

;; pure re-export (1.3.1 from (gnu packages python-xyz))
(define-public python-sniffio
  (@ (gnu packages python-xyz) python-sniffio))

;; mismatch: want 9.1.4, upstream Guix has 9.0.0
(define-public python-tenacity
  (let ((base (@ (gnu packages python-xyz) python-tenacity)))
    (package
      (inherit base)
      (version "9.1.4")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/47/c6/ee486fd809e357697ee8a44d3d69222b344920433d3b6666ccd9b374630c/tenacity-9.1.4.tar.gz")
         (sha256
          (base32 "0fprkhbrh26zm9jxpwmcz5vpr989hd4kpcqs110x0arz4r61vcxd"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools python-setuptools-scm)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 3.3.0, upstream Guix has 2.5.0
(define-public python-termcolor
  (let ((base (@ (gnu packages python-xyz) python-termcolor)))
    (package
      (inherit base)
      (version "3.3.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/46/79/cf31d7a93a8fdc6aa0fbb665be84426a8c5a557d9240b6239e9e11e35fc5/termcolor-3.3.0.tar.gz")
         (sha256
          (base32 "1i91jnbzfymi68rriqdr2psh5kmcq0kbcfm1hflskilfck57321l"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling python-hatch-vcs)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 6.5.5, upstream Guix has 6.4.2
(define-public python-tornado
  (let ((base (@ (gnu packages python-web) python-tornado)))
    (package
      (inherit base)
      (version "6.5.5")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/f8/f1/3173dfa4a18db4a9b03e5d55325559dab51ee653763bb8745a75af491286/tornado-6.5.5.tar.gz")
         (sha256
          (base32 "1s9hilgbj4gr0wprd6vpjqpvgiknxlb595861ksz3mqvm4z8yaqr"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 4.67.3, upstream Guix has 4.67.1
(define-public python-tqdm
  (let ((base (@ (gnu packages python-xyz) python-tqdm)))
    (package
      (inherit base)
      (version "4.67.3")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/09/a9/6ba95a270c6f1fbcd8dac228323f2777d886cb206987444e4bce66338dd4/tqdm-4.67.3.tar.gz")
         (sha256
          (base32 "1fv0p6921rnd3mz1vwwnzmwq2jkpn4y1kknly5ryyi4jz01mz0kx"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools python-setuptools-scm)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; pure re-export (4.15.0 from (gnu packages python-build))
(define-public python-typing-extensions
  (@ (gnu packages python-build) python-typing-extensions))

;; match: 0.4.2 (from (gnu packages python-xyz)); python-* propagated-
;; inputs replaced with channel closure (system-lib inputs preserved).
(define-public python-typing-inspection
  (let ((base (@ (gnu packages python-xyz) python-typing-inspection)))
    (package
      (inherit base)
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-typing-extensions)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 2.6.3, upstream Guix has 2.5.0
(define-public python-urllib3
  (let ((base (@ (gnu packages python-web) python-urllib3)))
    (package
      (inherit base)
      (version "2.6.3")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/c7/24/5f1b3bdffd70275f6661c76461e25f024d5a38a46f04aaca912426a2b1d3/urllib3-2.6.3.tar.gz")
         (sha256
          (base32 "1v9qmlaywwdcj7lymhp0fmq30fsdznaan28m6az7v9a4964bcqhv"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling python-hatch-vcs python-setuptools-scm)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 0.6.0, upstream Guix has 0.2.13
(define-public python-wcwidth
  (let ((base (@ (gnu packages python-xyz) python-wcwidth)))
    (package
      (inherit base)
      (version "0.6.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/35/a2/8e3becb46433538a38726c948d3399905a4c7cabd0df578ede5dc51f0ec2/wcwidth-0.6.0.tar.gz")
         (sha256
          (base32 "0n9i660mqif2w8kn05v4pjmxh20jxg5q90q1gsjs3ybf5lkf9i6d"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-hatchling)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        '()))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))

;; mismatch: want 1.22.0, upstream Guix has 1.18.3
(define-public python-yarl
  (let ((base (@ (gnu packages python-web) python-yarl)))
    (package
      (inherit base)
      (version "1.22.0")
      (source
       (origin
         (method url-fetch)
         (uri "https://files.pythonhosted.org/packages/57/63/0c6ebca57330cd313f6102b16dd57ffaf3ec4c83403dcb45dbd15c6f3ea1/yarl-1.22.0.tar.gz")
         (sha256
          (base32 "0wdg8mkls6yhd8hzxlbqm9vwhxhkdy837zyrifx02i3xaxbqbgxy"))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append python-setuptools python-cython gcc-toolchain python-expandvars)))
      (propagated-inputs
       (append
        ;; Keep non-Python upstream propagated-inputs (libsodium,
        ;; libffi, …); strip their (label _) pairs so the result
        ;; is a flat list of packages that Guix can auto-label.
        (map (lambda (i) (if (pair? i) (cadr i) i))
             (filter (lambda (i)
                       (let ((label (if (pair? i) (car i)
                                        (package-name i))))
                         (not (string-prefix? "python-" label))))
                     (package-propagated-inputs base)))
        (list python-idna python-multidict python-propcache)))
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:tests? was-tests? #f) #f))))))
