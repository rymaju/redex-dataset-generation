#lang racket


(require redex)


;; A modified Perl inspired RegExp to fit the syntax of Kushman et al.
;; E.x. Modified [^ RE ...] -> ~(RE)
;; Base Regex BNF from
;; https://aclanthology.org/N13-1103.pdf
;; and CMPT 384 Lecture Notes Robert D. Cameron November 29 - December 1, 1999
(define-language K13-Regex
  (re ::=
      re-quantifiable
      (* re-quantifiable) ;; 0-inf occurences of re
      (+ re-quantifiable) ;; 1-inf occurences of re
      (minrange re-quantifiable natural)
      (repeat re-quantifiable natural))
  (re-quantifiable ::=
                   atom
                   (anychar)
                   (and re re re ...)
                   (or re re re ...)
                   (not re))
  (atom ::= variable-not-otherwise-mentioned))



(define (k13regex->regex-str re)
  (match re
    [x #:when (symbol? x) (symbol->string x)]
    [`(and ,re* ...) (string-append "(" (string-join (map k13regex->regex-str re*) " & ") ")")]
    [`(or ,re* ...) (string-append "(" (string-join (map k13regex->regex-str re*) " | ") ")")]
    [`(not ,re) (string-append "~(" (k13regex->regex-str re) ")")]
    [`(* ,re) (string-append (k13regex->regex-str re) "*")]
    [`(+ ,re) (string-append (k13regex->regex-str re) "+")]
    [`(anychar) "[A-Za-z]"]
    [`(minrange ,re ,n) (string-append (k13regex->regex-str re) "{" (number->string n) ",}")]
    [`(repeat ,re ,n) (string-append (k13regex->regex-str re) "{" (number->string n) "}")]
    [`(range ,re ,n ,k) (string-append (k13regex->regex-str re) "{" (number->string n) "," (number->string k) "}")]))

(define (describe-k13regex-line re)
  (string-append "lines with " (describe-k13regex re)))

(define (describe-k13regex re)
  (match re
    [x #:when (symbol? x)
       (let ((s (symbol->string x)))
         (if (< 1 (string-length s))
             (string-append "letters '" s "'")
             (string-append "letter '" s "'")))]
    [`(not (* ,re)) (string-append "zero or more of " (describe-k13regex re))]
    [`(not (+ ,re)) (string-append "one or more of " (describe-k13regex re))]
    [`(and ,re* ...) (string-append "" (string-join (map describe-k13regex re*) " and ") "")]
    [`(or ,re* ...) (string-append "either " (string-join (map describe-k13regex re*) " or "))]
    [`(not ,re) (string-append "not " (describe-k13regex re))]
    [`(* ,re) (string-append "zero or more " (describe-k13regex re))]
    [`(+ ,re) (string-append "at least one " (describe-k13regex re))]
    [`(anychar) "any letter"]
    [`(minrange ,re ,n) (string-append  (describe-k13regex re) " repeated at least " (number->string n) " times")]
    [`(repeat ,re ,n) (string-append (describe-k13regex re) " repeated exactly " (number->string n) " times")]
    [`(range ,re ,n ,k) (string-append (describe-k13regex re) " repeated " (number->string n) " to " (number->string k) " times")]))


    
;; make-examples : Nat -> (Streamof PropositionalLogicExpr)
(define (make-examples amt)
  (let go ([acc (set)])
    (define new-term (generate-term K13-Regex re 3))
    (cond [(>= (set-count acc) amt) '()]
          [(set-member? acc new-term) (go acc)]
          [else (stream-cons new-term (go (set-add acc new-term)))])))


(define tgt (open-output-file "tgt.txt" #:exists 'truncate/replace))
(define src (open-output-file "src.txt" #:exists 'truncate/replace))
(define ds (open-output-file "ds.json" #:exists 'truncate))
(require json)
(for ((e (in-stream (make-examples 100000))))
  (displayln (k13regex->regex-str e) tgt)
  (displayln (describe-k13regex-line e) src)
  (write-json (hash 'translation (hash 'en (describe-k13regex-line e) 'regex (k13regex->regex-str e))) ds)
  (displayln "" ds))

(close-output-port tgt)
(close-output-port src)
(close-output-port ds)


  