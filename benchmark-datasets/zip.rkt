#lang racket
(provide write-translation-json)
(require json racket/file)

;; Zips all src and targ txt files into Huggingface compatible translation JSON files
;; Data from https://github.com/nicholaslocascio/deep-regex/blob/master/datasets/

(define FOLDERS '("KB13" "NL-RX-Synth" "NL-RX-Turk"))
(module+ main
  (for ([folder (in-list FOLDERS)])
    (write-translation-json (build-path folder "src.txt")
                            (build-path folder "targ.txt")
                            (build-path folder "ds.json"))))

;; write-translation-json : PathString PathString PathString -> ()
;; Zip src.txt and targ.txt into a translation JSON dataset for Huggingface
;; Warning: reads entire file buffer into memory
;; (probably fine at this scale though, use read-line on ports for streaming later if needed)
(define (write-translation-json src-path targ-path out-json-path)
  (with-output-to-file out-json-path #:exists 'truncate/replace
  (λ ()
    (for ([src-line (in-list (file->lines src-path))]
          [targ-line (in-list (file->lines targ-path))])
      (write-json (hash 'translation (hash 'en src-line 'regex targ-line)))
      (newline)))))
