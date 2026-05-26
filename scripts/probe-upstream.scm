;;; probe-upstream.scm — read tab-separated "pypi-name TAB version" pairs
;;; from stdin, emit a Scheme alist mapping each to its status against
;;; upstream Guix.  Status is one of: match, mismatch, missing.
;;;
;;; Usage:
;;;   guix repl scripts/probe-upstream.scm < /tmp/want.tsv \
;;;     > .upstream/upstream-map.scm

(use-modules (gnu packages)
             (guix packages)
             (guix utils)
             (ice-9 rdelim))

(define (pypi->guix name)
  (string-append "python-" name))

(define (file->module path)
  "Convert e.g. \"gnu/packages/python-web.scm\" to (gnu packages python-web)."
  (let* ((no-ext (substring path 0 (- (string-length path) 4)))
         (parts (string-split no-ext #\/)))
    (map string->symbol parts)))

(define (lookup guix-name)
  "Return (pkg module) of the first matching upstream package, or #f."
  (let ((found (find-packages-by-name guix-name)))
    (if (null? found)
        #f
        (let* ((pkg (car found))
               (loc (package-location pkg)))
          (list pkg (file->module (location-file loc)))))))

(display "(define upstream-map '(\n")
(let loop ((line (read-line)))
  (unless (eof-object? line)
    (unless (or (string-null? line)
                (char=? (string-ref line 0) #\#))
      (let* ((parts (string-split line #\tab))
             (pypi-name (car parts))
             (want (cadr parts))
             (guix-name (pypi->guix pypi-name))
             (info (lookup guix-name)))
        (cond
         ((not info)
          (format #t "  (~s missing ~s #f)~%" guix-name want))
         (else
          (let* ((pkg (car info))
                 (mod (cadr info))
                 (have (package-version pkg)))
            (if (string=? want have)
                (format #t "  (~s match ~s ~s)~%" guix-name have mod)
                (format #t "  (~s mismatch ~s ~s) ; want ~a~%"
                        guix-name have mod want)))))))
    (loop (read-line))))
(display "))\n")
