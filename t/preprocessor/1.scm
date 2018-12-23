(define (make-if t c a)
  (cons 'if (cons t (cons c (cons a '())))))

(define (make-lambda args body)
  (cons 'lambda (cons args body)))

(define (expand-and exps)
  (if (null? exps)
      #t
      (make-if (car exps)
               (expand-and (cdr exps))
               #f)))

(define (expand-or exps)
  (if (null? exps)
      #f
      (make-if (car exps)
               #t
               (expand-or (cdr exps)))))

(define (expand-let exps)
  ((lambda (args vals body)
     (cons (make-lambda args body) vals))
   (map car (car exps))
   (map cadr (car exps))
   (cdr exps)))

(define (preprocess s)
  ((lambda (loop)
     (if (pair? s)
         (if (symbol? (car s))
             (if (eq? 'and (car s))
                 (loop (expand-and (cdr s)))
                 (if (eq? 'or (car s))
                     (loop (expand-or (cdr s)))
                     (if (eq? 'let (car s))
                         (loop (expand-let (cdr s)))
                         (loop s))))
             (loop s))
         s))
    (lambda (x)
      (if (pair? x)
          (cons (preprocess (car x))
                (preprocess (cdr x)))
          x))))

(preprocess '(and 1 2 3 4))
(preprocess '(or 1 2 3 4))
(preprocess '(and (or x y) (or u v)))
(preprocess '(or (and x y) (and u v)))
(preprocess '(+ 1 (let ((x 3) (y 5)) (* x y))))