#lang at-exp racket


(require redex)


;; A modified Perl inspired RegExp to fit the syntax of Kushman et al.
;; E.x. Modified [^ RE ...] -> ~(RE)
;; Base Regex BNF from
;; https://aclanthology.org/N13-1103.pdf
;; and CMPT 384 Lecture Notes Robert D. Cameron November 29 - December 1, 1999
(define-language K13-Regex
  ;; Top Level Expression `re`
  (re ::=
      (repeat-capturing-group re+)
      (min-range-capturing-group re+)
      (min-max-range-capturing-group re+)
      (* re+)
      (+ re+)
      (and re+ re+)
      (or re+ re+)
      (not re+)
      re+)
  ;; "Quantifiable" Regex
  (re+ ::=
       atom
       (group re))
  ;; Terminals
  (atom ::=
        <vowel>
        <digit>
        <uppercase-letter>
        <lowercase-letter>
        <string-literal> ; "word", "dog", "cat"
        <any-character>))

;https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt
(require (prefix-in ra: data/ralist))
(define WORDS (apply ra:list (file->lines "google-10000-english-no-swears.txt")))
(define (random-word)
  (ra:list-ref WORDS (random (ra:length WORDS))))
(define (random-nat [min 1])
  (random min (+ 7 min)))
(define (->regex re)
  (match re
    ['<vowel> "[AEIOUaeiou]"]
    ['<digit> "[0-9]"]
    ['<uppercase-letter> "[A-Z]"]
    ['<lowercase-letter> "[a-z]"]
    ['<string-literal> (random-word)]
    ['<any-character> "."]
    [`(repeat-capturing-group ,re+)
     (string-append (->regex re+) "{" (~a (random-nat)) "}")]
    [`(min-range-capturing-group ,re+)
     (string-append (->regex re+) "{" (~a (random-nat)) ",}")]
    [`(min-max-range-capturing-group ,re+)
     (define n (random-nat [min 1]))
     (string-append (->regex re+) "{" (~a n) ","(~a (random-nat (add1 n)))"}")]

    ;; "Quantifiable" Regex
    [`(group ,re) (string-append "(" (->regex re) ")")]
    [`(and ,re1 ,re2) (string-append (->regex re1) "&" (->regex re2))]
    [`(or ,re1 ,re2) (string-append (->regex re1) "|" (->regex re2))]
    [`(not ,re) (string-append "~"(->regex re))]
    [`(* ,re) (string-append (->regex re) "*")]
    [`(+ ,re) (string-append (->regex re) "+")]))

(define (choose ls)
  (list-ref ls (random (length ls))))
(define (->en re)
  (match re
    ['<vowel> "a vowel"]
    ['<digit> "a digit"]
    ['<uppercase-letter> "an uppercase letter"]
    ['<lowercase-letter> "a lowercase letter"]
    ['<string-literal> (string-append "the word '" (random-word) "'")]
    ['<any-character> "any character"]
    [`(repeat-capturing-group ,re+)
     (string-append  (->en re+) ", exactly " (~a (random-nat)) " times")]
    [`(min-range-capturing-group ,re+)
     (string-append (->en re+) " at least " (~a (random-nat)) " times")]
    [`(min-max-range-capturing-group ,re+)
     (define n (random-nat [min 1]))
     (string-append (->en re+) ", between " (~a n) " and "(~a (random-nat (add1 n)))" times")]
    ;; "Quantifiable" Regex
    [`(group ,re) (string-append "" (->en re) "")]
    [`(and ,re1 ,re2) (string-append (->en re1) " and " (->en re2))]
    [`(or ,re1 ,re2) (string-append (->en re1) " or " (->en re2))]
    [`(not ,re) (string-append "not " (->en re))]
    [`(* ,re) (string-append (->en re) ", zero or more times")]
    [`(+ ,re) (string-append (->en re) ", at least once")]))




;; make-examples : Nat -> (Streamof PropositionalLogicExpr)
(define (make-examples amt)
  (for/stream ([i (in-range amt)])
    (generate-term K13-Regex re 3)))
  #;(let go ([acc (set)])
    (define new-term (generate-term K13-Regex re 3))
    (cond [(>= (set-count acc) amt) '()]
          ;[(set-member? acc new-term) (go acc)]
          [else (stream-cons new-term (go acc))]))

(require "benchmark-datasets/zip.rkt")
(define (write-text-files [n 10] [src-port (current-output-port)] [targ-port (current-output-port)] [seed 42])
  (random-seed seed)
  (define examples (stream->list (make-examples n)))
  (random-seed seed)
  (for ([e (in-list examples)])
    (displayln (->regex e) targ-port))
  (random-seed seed)
  (for ([e (in-list examples)])
    (displayln (->en e) src-port)))


(define (write-dataset)
  (define tgt (open-output-file "targ.txt" #:exists 'truncate/replace))
  (define src (open-output-file "src.txt" #:exists 'truncate/replace))
  (write-text-files 10000 src tgt)
  (close-output-port tgt)
  (close-output-port src)

  (write-translation-json  "src.txt" "targ.txt" "ds.json")
  )

(module+ main
  (time (write-dataset)))
