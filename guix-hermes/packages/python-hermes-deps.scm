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
;;;   guix shell python python-packaging -- \
;;;     python3 scripts/regen-deps.py --extras=messaging
;;;
;;; Source of truth: .upstream/uv.lock at upstream tag v2026.5.16.
;;; Closure: 58 Python packages (core + extras: messaging).
;;;
;;; Phase 2 limits (cleaned up in Phase 3):
;;;   - synopsis / description / home-page are placeholders
;;;   - license defaults to MIT (Expat); per-package overrides come later
;;;   - tests disabled; native-inputs to be added as build failures surface
;;;
;;; Code:

(define-module (guix-hermes packages python-hermes-deps)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system pyproject))

(define-public python-aiohappyeyeballs
  (package
    (name "python-aiohappyeyeballs")
    (version "2.6.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/26/30/f84a107a9c4331c14b2b586036f40965c128aa4fee4dda5d3d51cb14ad54/aiohappyeyeballs-2.6.1.tar.gz")
       (sha256
        (base32 "0n1mjip846fprc34ik6if9m8xisva2m0ygyzvz53r013648x1yf3"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/aiohappyeyeballs/")
    (synopsis "aiohappyeyeballs (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{aiohappyeyeballs} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-aiohttp
  (package
    (name "python-aiohttp")
    (version "3.13.4")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/45/4a/064321452809dae953c1ed6e017504e72551a26b6f5708a5a80e4bf556ff/aiohttp-3.13.4.tar.gz")
       (sha256
        (base32 "0f5xmrm1nk19k37lwcf0g8zmhw75w5lr1m5m5868k1v0qq4nsynr"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-aiohappyeyeballs python-aiosignal python-attrs python-frozenlist python-multidict python-propcache python-yarl))
    (home-page "https://pypi.org/project/aiohttp/")
    (synopsis "aiohttp (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{aiohttp} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-aiosignal
  (package
    (name "python-aiosignal")
    (version "1.4.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/61/62/06741b579156360248d1ec624842ad0edf697050bbaf7c3e46394e106ad1/aiosignal-1.4.0.tar.gz")
       (sha256
        (base32 "1isin9bp256scp59lbr35h48nw5p5i84b6f9kh1c50w08vcyqzpl"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-frozenlist python-typing-extensions))
    (home-page "https://pypi.org/project/aiosignal/")
    (synopsis "aiosignal (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{aiosignal} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-annotated-types
  (package
    (name "python-annotated-types")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ee/67/531ea369ba64dcff5ec9c3402f9f51bf748cec26dde048a2f973a4eea7f5/annotated_types-0.7.0.tar.gz")
       (sha256
        (base32 "12ff8j1l0hrmfa8dfa1pyaka5a8sbyq8b76bzj6bq21sll4prw5g"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/annotated-types/")
    (synopsis "annotated-types (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{annotated-types} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-anyio
  (package
    (name "python-anyio")
    (version "4.12.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/96/f0/5eb65b2bb0d09ac6776f2eb54adee6abe8228ea05b20a5ad0e4945de8aac/anyio-4.12.1.tar.gz")
       (sha256
        (base32 "00ypzqzllinhj2x3ai5x5bvkdb0109nw59rdjdfg1lw59hxcrks1"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-idna python-typing-extensions))
    (home-page "https://pypi.org/project/anyio/")
    (synopsis "anyio (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{anyio} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-attrs
  (package
    (name "python-attrs")
    (version "25.4.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/6b/5c/685e6633917e101e5dcb62b9dd76946cbb57c26e133bae9e0cd36033c0a9/attrs-25.4.0.tar.gz")
       (sha256
        (base32 "04byqlshrdvxb4xqaplxwhmf9rhvmiamvcs87brrx1ghhydrdm8n"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/attrs/")
    (synopsis "attrs (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{attrs} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-brotlicffi
  (package
    (name "python-brotlicffi")
    (version "1.2.0.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/8a/b6/017dc5f852ed9b8735af77774509271acbf1de02d238377667145fcee01d/brotlicffi-1.2.0.1.tar.gz")
       (sha256
        (base32 "0732blw0kh284l67jssw98kylxr3i5ddk9hlck87lc3qc9cmq3f2"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-cffi))
    (home-page "https://pypi.org/project/brotlicffi/")
    (synopsis "brotlicffi (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{brotlicffi} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-certifi
  (package
    (name "python-certifi")
    (version "2026.2.25")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/af/2d/7bf41579a8986e348fa033a31cdd0e4121114f6bce2457e8876010b092dd/certifi-2026.2.25.tar.gz")
       (sha256
        (base32 "19zv1glf5im976d340xx2hxx8b6iq99r25kj6i6q3skqxrfap1z8"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/certifi/")
    (synopsis "certifi (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{certifi} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-cffi
  (package
    (name "python-cffi")
    (version "2.0.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz")
       (sha256
        (base32 "0aambnn8q1jcyshfs002lapi90nypn6h9bh1c3iry4r1j28bbla4"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-pycparser))
    (home-page "https://pypi.org/project/cffi/")
    (synopsis "cffi (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{cffi} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-charset-normalizer
  (package
    (name "python-charset-normalizer")
    (version "3.4.4")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/13/69/33ddede1939fdd074bce5434295f38fae7136463422fe4fd3e0e89b98062/charset_normalizer-3.4.4.tar.gz")
       (sha256
        (base32 "06p20hsbfmg9pdc307ffnb7nwfmlwyw06dp4423z4d8w262pjlwl"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/charset-normalizer/")
    (synopsis "charset-normalizer (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{charset-normalizer} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-croniter
  (package
    (name "python-croniter")
    (version "6.0.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ad/2f/44d1ae153a0e27be56be43465e5cb39b9650c781e001e7864389deb25090/croniter-6.0.0.tar.gz")
       (sha256
        (base32 "0xsm4m44f89r8z4irn799w4z3cchfyqc5qpchfli8qcm2frh9i9p"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-python-dateutil python-pytz))
    (home-page "https://pypi.org/project/croniter/")
    (synopsis "croniter (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{croniter} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-cryptography
  (package
    (name "python-cryptography")
    (version "46.0.7")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/47/93/ac8f3d5ff04d54bc814e961a43ae5b0b146154c89c61b47bb07557679b18/cryptography-46.0.7.tar.gz")
       (sha256
        (base32 "19as4hn49jmwzwnqb0b42j2gx8lnkcij7q1q1nnzs2ryby6ddkz4"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-cffi))
    (home-page "https://pypi.org/project/cryptography/")
    (synopsis "cryptography (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{cryptography} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-discord-py
  (package
    (name "python-discord-py")
    (version "2.7.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ef/57/9a2d9abdabdc9db8ef28ce0cf4129669e1c8717ba28d607b5ba357c4de3b/discord_py-2.7.1.tar.gz")
       (sha256
        (base32 "1nj929j1351if3bbchgvr715vljhnpb9v2hlk15jw59manjfdm94"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-aiohttp))
    (home-page "https://pypi.org/project/discord-py/")
    (synopsis "discord-py (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{discord-py} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-distro
  (package
    (name "python-distro")
    (version "1.9.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/fc/f8/98eea607f65de6527f8a2e8885fc8015d3e6f5775df186e443e0964a11c3/distro-1.9.0.tar.gz")
       (sha256
        (base32 "1vfvkgfvrjpxpb48pf8rs2l5wfxij0plmffnw5p123wlv1ppr9rg"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/distro/")
    (synopsis "distro (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{distro} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-fire
  (package
    (name "python-fire")
    (version "0.7.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/c0/00/f8d10588d2019d6d6452653def1ee807353b21983db48550318424b5ff18/fire-0.7.1.tar.gz")
       (sha256
        (base32 "1gww18kqdi9pp0r4zsl95a5wgn64vj8d041k6kxripinqw2qy81v"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-termcolor))
    (home-page "https://pypi.org/project/fire/")
    (synopsis "fire (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{fire} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-frozenlist
  (package
    (name "python-frozenlist")
    (version "1.8.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/2d/f5/c831fac6cc817d26fd54c7eaccd04ef7e0288806943f7cc5bbf69f3ac1f0/frozenlist-1.8.0.tar.gz")
       (sha256
        (base32 "1b9ikbaj0c5z96fkyq1q3xpsa08hlkbq2w7w936zchnqv2g85piy"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/frozenlist/")
    (synopsis "frozenlist (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{frozenlist} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-h11
  (package
    (name "python-h11")
    (version "0.16.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/01/ee/02a2c011bdab74c6fb3c75474d40b3052059d95df7e73351460c8588d963/h11-0.16.0.tar.gz")
       (sha256
        (base32 "1wazxq4b4jg5001h5ypvz9pvrg80pagyd1aqm962wya5rxbbjdaf"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/h11/")
    (synopsis "h11 (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{h11} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-httpcore
  (package
    (name "python-httpcore")
    (version "1.0.9")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/06/94/82699a10bca87a5556c9c59b5963f2d039dbd239f25bc2a63907a05a14cb/httpcore-1.0.9.tar.gz")
       (sha256
        (base32 "1s3nw7vgy2phqfi1avr7lbgw6cga8ndrlfbzh1fsplizylx4cd3f"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-certifi python-h11))
    (home-page "https://pypi.org/project/httpcore/")
    (synopsis "httpcore (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{httpcore} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-httpx
  (package
    (name "python-httpx")
    (version "0.28.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/b1/df/48c586a5fe32a0f01324ee087459e112ebb7224f646c0b5023f5e79e9956/httpx-0.28.1.tar.gz")
       (sha256
        (base32 "1z227qz8wlj248ww59bh8hvhl9zjdzq9gxang1b5pwxh2rgqrsbm"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-anyio python-certifi python-httpcore python-idna))
    (home-page "https://pypi.org/project/httpx/")
    (synopsis "httpx (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{httpx} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-idna
  (package
    (name "python-idna")
    (version "3.11")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/6f/6d/0703ccc57f3a7233505399edb88de3cbd678da106337b9fcde432b65ed60/idna-3.11.tar.gz")
       (sha256
        (base32 "00lrcbd0l69r7yjn9px74d88r3jdcmrsmhijn0ghrv84kk6aypbr"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/idna/")
    (synopsis "idna (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{idna} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-jinja2
  (package
    (name "python-jinja2")
    (version "3.1.6")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz")
       (sha256
        (base32 "0vbdyr1vx0w1hgxs149lr0gq5njndpp9lzjqb8kz2d8dk42zndq1"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-markupsafe))
    (home-page "https://pypi.org/project/jinja2/")
    (synopsis "jinja2 (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{jinja2} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-jiter
  (package
    (name "python-jiter")
    (version "0.13.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/0d/5e/4ec91646aee381d01cdb9974e30882c9cd3b8c5d1079d6b5ff4af522439a/jiter-0.13.0.tar.gz")
       (sha256
        (base32 "1x0lmqnk9vz7349gsrckpr3akq2cw48aaaarpk0zybby5jf9z0zj"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/jiter/")
    (synopsis "jiter (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{jiter} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-markdown-it-py
  (package
    (name "python-markdown-it-py")
    (version "4.0.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/5b/f5/4ec618ed16cc4f8fb3b701563655a69816155e79e24a17b651541804721d/markdown_it_py-4.0.0.tar.gz")
       (sha256
        (base32 "1wxr3kd9q02rmidyng0k4knf0x5x8plr9c8pf402r4sgld52n2nb"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-mdurl))
    (home-page "https://pypi.org/project/markdown-it-py/")
    (synopsis "markdown-it-py (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{markdown-it-py} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-markupsafe
  (package
    (name "python-markupsafe")
    (version "3.0.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/7e/99/7690b6d4034fffd95959cbe0c02de8deb3098cc577c67bb6a24fe5d7caa7/markupsafe-3.0.3.tar.gz")
       (sha256
        (base32 "160npsg7jh6mbiwy23xm9aqcxgcn0wl33hgx42rmfr2biy09a9kj"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/markupsafe/")
    (synopsis "markupsafe (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{markupsafe} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-mdurl
  (package
    (name "python-mdurl")
    (version "0.1.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz")
       (sha256
        (base32 "1fn1hy35h9grggwqax90zcb52inlfxrxsm27vlqqz8zfyllkshdv"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/mdurl/")
    (synopsis "mdurl (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{mdurl} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-multidict
  (package
    (name "python-multidict")
    (version "6.7.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/1a/c2/c2d94cbe6ac1753f3fc980da97b3d930efe1da3af3c9f5125354436c073d/multidict-6.7.1.tar.gz")
       (sha256
        (base32 "0gb2mhmp30jgs2d8rw9lpambclrc2x4n0svpwnim6776pshm4rpc"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/multidict/")
    (synopsis "multidict (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{multidict} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-openai
  (package
    (name "python-openai")
    (version "2.24.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/55/13/17e87641b89b74552ed408a92b231283786523edddc95f3545809fab673c/openai-2.24.0.tar.gz")
       (sha256
        (base32 "0wx6k6zy49grqpwsyd57c58nk7bvwqinlwf47frirl6v83snjmqy"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-anyio python-distro python-httpx python-jiter python-pydantic python-sniffio python-tqdm python-typing-extensions))
    (home-page "https://pypi.org/project/openai/")
    (synopsis "openai (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{openai} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-prompt-toolkit
  (package
    (name "python-prompt-toolkit")
    (version "3.0.52")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/a1/96/06e01a7b38dce6fe1db213e061a4602dd6032a8a97ef6c1a862537732421/prompt_toolkit-3.0.52.tar.gz")
       (sha256
        (base32 "0mg83cmh8h6qxlbjwbxh918kgw9nwzdivpl5vqhp73lwja9f3k98"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-wcwidth))
    (home-page "https://pypi.org/project/prompt-toolkit/")
    (synopsis "prompt-toolkit (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{prompt-toolkit} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-propcache
  (package
    (name "python-propcache")
    (version "0.4.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/9e/da/e9fc233cf63743258bff22b3dfa7ea5baef7b5bc324af47a0ad89b8ffc6f/propcache-0.4.1.tar.gz")
       (sha256
        (base32 "0gbwr4il9v049wvspi3wal73f85ykbsfqdszami07s1pqsl0g0gl"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/propcache/")
    (synopsis "propcache (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{propcache} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-psutil
  (package
    (name "python-psutil")
    (version "7.2.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz")
       (sha256
        (base32 "0wlkyn4bpd40dnhxdf1v56y3vhzmlpdciwa7sm7k9bq6skwgaih7"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/psutil/")
    (synopsis "psutil (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{psutil} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pycparser
  (package
    (name "python-pycparser")
    (version "3.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/1b/7d/92392ff7815c21062bea51aa7b87d45576f649f16458d78b7cf94b9ab2e6/pycparser-3.0.tar.gz")
       (sha256
        (base32 "0abbzkywvi84jlx69pl90i6lxscz3hlf2drwmh15jjih2z94j3v0"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pycparser/")
    (synopsis "pycparser (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pycparser} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pydantic
  (package
    (name "python-pydantic")
    (version "2.12.5")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/69/44/36f1a6e523abc58ae5f928898e4aca2e0ea509b5aa6f6f392a5d882be928/pydantic-2.12.5.tar.gz")
       (sha256
        (base32 "0jdvmqkdwzjb76vbs0z961fyrin0x1f6dfzbkxd0h3swqwj10dad"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-annotated-types python-pydantic-core python-typing-extensions python-typing-inspection))
    (home-page "https://pypi.org/project/pydantic/")
    (synopsis "pydantic (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pydantic} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pydantic-core
  (package
    (name "python-pydantic-core")
    (version "2.41.5")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/71/70/23b021c950c2addd24ec408e9ab05d59b035b39d97cdc1130e1bce647bb6/pydantic_core-2.41.5.tar.gz")
       (sha256
        (base32 "0vj72r481py6r5mlna185g3ppw1jri964q77spzp7lval4gabnh8"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-typing-extensions))
    (home-page "https://pypi.org/project/pydantic-core/")
    (synopsis "pydantic-core (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pydantic-core} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pygments
  (package
    (name "python-pygments")
    (version "2.19.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/b0/77/a5b8c569bf593b0140bde72ea885a803b82086995367bf2037de0159d924/pygments-2.19.2.tar.gz")
       (sha256
        (base32 "11xqsnnh0iip4vh2lfbh5xa46dy47d9vqw39ad98jzzcgi3v4v33"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pygments/")
    (synopsis "pygments (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pygments} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pyjwt
  (package
    (name "python-pyjwt")
    (version "2.12.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/c2/27/a3b6e5bf6ff856d2509292e95c8f57f0df7017cf5394921fc4e4ef40308a/pyjwt-2.12.1.tar.gz")
       (sha256
        (base32 "0av70ddpd7bhpy014rwf491b5gl4bzc3swfv0b808746vwm7ljn7"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pyjwt/")
    (synopsis "pyjwt (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pyjwt} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pypng
  (package
    (name "python-pypng")
    (version "0.20220715.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/93/cd/112f092ec27cca83e0516de0a3368dbd9128c187fb6b52aaaa7cde39c96d/pypng-0.20220715.0.tar.gz")
       (sha256
        (base32 "1hg24zja235bkbny82hx7sy7qlzfbabxph2lvqaq61vgm4xl773k"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pypng/")
    (synopsis "pypng (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pypng} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-python-dateutil
  (package
    (name "python-python-dateutil")
    (version "2.9.0.post0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz")
       (sha256
        (base32 "1lqak92ka6p96wjbf3zr9691gm7b01g7s8c8af3wvqd7ilh59p9p"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-six))
    (home-page "https://pypi.org/project/python-dateutil/")
    (synopsis "python-dateutil (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-dateutil} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-python-dotenv
  (package
    (name "python-python-dotenv")
    (version "1.2.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/f0/26/19cadc79a718c5edbec86fd4919a6b6d3f681039a2f6d66d14be94e75fb9/python_dotenv-1.2.1.tar.gz")
       (sha256
        (base32 "1mkalcdfq3i65mnsyfng9vyz155akh5fdw2ajmk0vaqngs4pwrj2"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/python-dotenv/")
    (synopsis "python-dotenv (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-dotenv} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-python-telegram-bot
  (package
    (name "python-python-telegram-bot")
    (version "22.6")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/cd/9b/8df90c85404166a6631e857027866263adb27440d8af1dbeffbdc4f0166c/python_telegram_bot-22.6.tar.gz")
       (sha256
        (base32 "0hip24nvzhgl3nlr4swnarwz6887098pjs18ar203zwd1z0qrbjh"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-httpx))
    (home-page "https://pypi.org/project/python-telegram-bot/")
    (synopsis "python-telegram-bot (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{python-telegram-bot} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pytz
  (package
    (name "python-pytz")
    (version "2025.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/f8/bf/abbd3cdfb8fbc7fb3d4d38d320f2441b1e7cbe29be4f23797b4a2b5d8aac/pytz-2025.2.tar.gz")
       (sha256
        (base32 "1hw1drs4cdc1cp3j92dk93h46dj5zg3hj66n3b10k8j9pcyrw2rn"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pytz/")
    (synopsis "pytz (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pytz} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-pyyaml
  (package
    (name "python-pyyaml")
    (version "6.0.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz")
       (sha256
        (base32 "03qrhk1vz2g12xgy9mdr4p3ibvxprch710gq9kxj5pr16hvj6rnp"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/pyyaml/")
    (synopsis "pyyaml (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{pyyaml} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-qrcode
  (package
    (name "python-qrcode")
    (version "7.4.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/30/35/ad6d4c5a547fe9a5baf85a9edbafff93fc6394b014fab30595877305fa59/qrcode-7.4.2.tar.gz")
       (sha256
        (base32 "0iaq1yrrbb0l1z4kfa881ra6v7i38w3v55inv7djgq97912nkncx"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-pypng python-typing-extensions))
    (home-page "https://pypi.org/project/qrcode/")
    (synopsis "qrcode (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{qrcode} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-requests
  (package
    (name "python-requests")
    (version "2.33.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/34/64/8860370b167a9721e8956ae116825caff829224fbca0ca6e7bf8ddef8430/requests-2.33.0.tar.gz")
       (sha256
        (base32 "0lknkpr4xwdzaci3ppyq8kssb7w2igzciqfhd8w3f67jn3lcbsy7"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-certifi python-charset-normalizer python-idna python-urllib3))
    (home-page "https://pypi.org/project/requests/")
    (synopsis "requests (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{requests} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-rich
  (package
    (name "python-rich")
    (version "14.3.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/b3/c6/f3b320c27991c46f43ee9d856302c70dc2d0fb2dba4842ff739d5f46b393/rich-14.3.3.tar.gz")
       (sha256
        (base32 "16v31x9gwhmkbwplwkw19s442cpm2cvw11kwrzc4vxgfwjws1nmq"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-markdown-it-py python-pygments))
    (home-page "https://pypi.org/project/rich/")
    (synopsis "rich (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{rich} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-ruamel-yaml
  (package
    (name "python-ruamel-yaml")
    (version "0.18.17")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/3a/2b/7a1f1ebcd6b3f14febdc003e658778d81e76b40df2267904ee6b13f0c5c6/ruamel_yaml-0.18.17.tar.gz")
       (sha256
        (base32 "0g4drmyj8ssvk1nk908kzgqyfgcc6jzzmf6xayqs98wk5mpcv4ch"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-ruamel-yaml-clib))
    (home-page "https://pypi.org/project/ruamel-yaml/")
    (synopsis "ruamel-yaml (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{ruamel-yaml} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-ruamel-yaml-clib
  (package
    (name "python-ruamel-yaml-clib")
    (version "0.2.15")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/ea/97/60fda20e2fb54b83a61ae14648b0817c8f5d84a3821e40bfbdae1437026a/ruamel_yaml_clib-0.2.15.tar.gz")
       (sha256
        (base32 "000640h0sjzd6id5ag3df254l4c2wja20lbjby498spg8f6crr26"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/ruamel-yaml-clib/")
    (synopsis "ruamel-yaml-clib (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{ruamel-yaml-clib} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-six
  (package
    (name "python-six")
    (version "1.17.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz")
       (sha256
        (base32 "109ajcsfhrz33lbwbb337w34crc3lb9rjnxrcpnbczlf8rfk6w7z"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/six/")
    (synopsis "six (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{six} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-slack-bolt
  (package
    (name "python-slack-bolt")
    (version "1.27.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/4c/28/50ed0b86e48b48e6ddcc71de93b91c8ac14a55d1249e4bff0586494a2f90/slack_bolt-1.27.0.tar.gz")
       (sha256
        (base32 "1q719hvnakfamp74y6p4357mba4afj1awx65cnjpdqbpw9j1vf9x"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-slack-sdk))
    (home-page "https://pypi.org/project/slack-bolt/")
    (synopsis "slack-bolt (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{slack-bolt} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-slack-sdk
  (package
    (name "python-slack-sdk")
    (version "3.40.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/3a/18/784859b33a3f9c8cdaa1eda4115eb9fe72a0a37304718887d12991eeb2fd/slack_sdk-3.40.1.tar.gz")
       (sha256
        (base32 "1l1zxh4vygnp6ppdkdl4a4ximxkv96chh4gmynmr1g2iq8xk65d2"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/slack-sdk/")
    (synopsis "slack-sdk (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{slack-sdk} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-sniffio
  (package
    (name "python-sniffio")
    (version "1.3.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/a2/87/a6771e1546d97e7e041b6ae58d80074f81b7d5121207425c964ddf5cfdbd/sniffio-1.3.1.tar.gz")
       (sha256
        (base32 "1p496yran6zwg47m7w26r8y89nrsbkrrbf4119slj3qaczf4wcpl"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/sniffio/")
    (synopsis "sniffio (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{sniffio} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-tenacity
  (package
    (name "python-tenacity")
    (version "9.1.4")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/47/c6/ee486fd809e357697ee8a44d3d69222b344920433d3b6666ccd9b374630c/tenacity-9.1.4.tar.gz")
       (sha256
        (base32 "0fprkhbrh26zm9jxpwmcz5vpr989hd4kpcqs110x0arz4r61vcxd"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/tenacity/")
    (synopsis "tenacity (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{tenacity} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-termcolor
  (package
    (name "python-termcolor")
    (version "3.3.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/46/79/cf31d7a93a8fdc6aa0fbb665be84426a8c5a557d9240b6239e9e11e35fc5/termcolor-3.3.0.tar.gz")
       (sha256
        (base32 "1i91jnbzfymi68rriqdr2psh5kmcq0kbcfm1hflskilfck57321l"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/termcolor/")
    (synopsis "termcolor (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{termcolor} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-tqdm
  (package
    (name "python-tqdm")
    (version "4.67.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/09/a9/6ba95a270c6f1fbcd8dac228323f2777d886cb206987444e4bce66338dd4/tqdm-4.67.3.tar.gz")
       (sha256
        (base32 "1fv0p6921rnd3mz1vwwnzmwq2jkpn4y1kknly5ryyi4jz01mz0kx"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/tqdm/")
    (synopsis "tqdm (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{tqdm} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-typing-extensions
  (package
    (name "python-typing-extensions")
    (version "4.15.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz")
       (sha256
        (base32 "0rhlhs28jndgp9fghdhidn6g7xiwx8vvihxbxhlgl4ncfg8lishc"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/typing-extensions/")
    (synopsis "typing-extensions (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{typing-extensions} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-typing-inspection
  (package
    (name "python-typing-inspection")
    (version "0.4.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/55/e3/70399cb7dd41c10ac53367ae42139cf4b1ca5f36bb3dc6c9d33acdb43655/typing_inspection-0.4.2.tar.gz")
       (sha256
        (base32 "0r7lhwp6kia7hnmkb9zs065r4r2l571qdlw3f005hnbwlr41qmms"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-typing-extensions))
    (home-page "https://pypi.org/project/typing-inspection/")
    (synopsis "typing-inspection (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{typing-inspection} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-urllib3
  (package
    (name "python-urllib3")
    (version "2.6.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/c7/24/5f1b3bdffd70275f6661c76461e25f024d5a38a46f04aaca912426a2b1d3/urllib3-2.6.3.tar.gz")
       (sha256
        (base32 "1v9qmlaywwdcj7lymhp0fmq30fsdznaan28m6az7v9a4964bcqhv"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/urllib3/")
    (synopsis "urllib3 (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{urllib3} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-wcwidth
  (package
    (name "python-wcwidth")
    (version "0.6.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/35/a2/8e3becb46433538a38726c948d3399905a4c7cabd0df578ede5dc51f0ec2/wcwidth-0.6.0.tar.gz")
       (sha256
        (base32 "0n9i660mqif2w8kn05v4pjmxh20jxg5q90q1gsjs3ybf5lkf9i6d"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (home-page "https://pypi.org/project/wcwidth/")
    (synopsis "wcwidth (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{wcwidth} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))

(define-public python-yarl
  (package
    (name "python-yarl")
    (version "1.22.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://files.pythonhosted.org/packages/57/63/0c6ebca57330cd313f6102b16dd57ffaf3ec4c83403dcb45dbd15c6f3ea1/yarl-1.22.0.tar.gz")
       (sha256
        (base32 "0wdg8mkls6yhd8hzxlbqm9vwhxhkdy837zyrifx02i3xaxbqbgxy"))))
    (build-system pyproject-build-system)
    (arguments (list #:tests? #f))
    (propagated-inputs
     (list python-idna python-multidict python-propcache))
    (home-page "https://pypi.org/project/yarl/")
    (synopsis "yarl (auto-generated; see Phase 3)")
    (description "Auto-generated package definition for @code{yarl} from upstream @file{uv.lock}.  Synopsis, description and license will be filled in during Phase 3.")
    (license license:expat)))
