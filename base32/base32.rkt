#lang racket/base

(provide base32-encode-stream
         base32-decode-stream
         base32-encode
         base32-decode)

(define ranges '([#"AZ" 0] [#"27" 26]))

(define-values (base32-digit digit-base32)
  (let ([bd (make-vector 256 #f)] [db (make-vector 32 #f)])
    (for ([r ranges] #:when #t
          [i (in-range (bytes-ref (car r) 0) (add1 (bytes-ref (car r) 1)))]
          [n (in-naturals (cadr r))])
      (vector-set! bd i n)
      (vector-set! db n i))
    (values (vector->immutable-vector bd) (vector->immutable-vector db))))

(define =byte (bytes-ref #"=" 0))
(define ones
  (vector->immutable-vector
   (list->vector (for/list ([i (in-range 9)]) (sub1 (arithmetic-shift 1 i))))))

(define (base32-decode-stream in out)
  (let loop ([data 0] [bits 0])
    (if (>= bits 8)
      (let ([bits (- bits 8)])
        (write-byte (arithmetic-shift data (- bits)) out)
        (loop (bitwise-and data (vector-ref ones bits)) bits))
      (let ([c (read-byte in)])
        (unless (or (eof-object? c) (eq? c =byte))
          (let ([v (vector-ref base32-digit c)])
            (if v
              (loop (+ (arithmetic-shift data 5) v) (+ bits 5))
              (loop data bits))))))))

(define (base32-encode-stream in out [linesep #"\n"])
  (let loop ([data 0] [bits 0] [width 0])
    (define (write-char)
      (write-byte (vector-ref digit-base32 (arithmetic-shift data (- 5 bits)))
                  out)
      (let ([width (modulo (add1 width) 72)])
        (when (zero? width) (display linesep out))
        width))
    (if (>= bits 5)
      (let ([bits (- bits 5)])
        (loop (bitwise-and data (vector-ref ones bits)) bits (write-char)))
      (let ([c (read-byte in)])
        (if (eof-object? c)
          ;; flush extra bits
          (begin
            (let ([width (if (> bits 0) (write-char) width)])
              (when (> width 0)
                (for ([i (in-range (modulo (- width) 4))])
                  (write-byte =byte out))
                (display linesep out))))
          (loop (+ (arithmetic-shift data 8) c) (+ bits 8) width))))))

(define (base32-decode src)
  (let ([s (open-output-bytes)])
    (base32-decode-stream (open-input-bytes src) s)
    (get-output-bytes s)))

(define (base32-encode src [linesep #"\r\n"])
  (let ([s (open-output-bytes)])
    (base32-encode-stream (open-input-bytes src) s linesep)
    (get-output-bytes s)))
