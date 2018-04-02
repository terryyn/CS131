(define(null-ld? obj)
  (if (not(pair? obj))
      #f
      (eq? (car obj) (cdr obj)))) 

(define(ld? obj)
  (cond
   [(not (pair? obj)) #f]
   [(eq? (car obj) (cdr obj)) #t]
   [(not (pair? (car obj))) #f];base case for recursion --> car obj ==()
   [else (ld? (cons (cdr(car obj))(cdr obj)))]))  ;keep getting cdr of car obj until it is the same as cdr obj

(define(cons-ld obj listdiff)
  (cons (cons obj (car listdiff)) (cdr listdiff)))


(define(car-ld listdiff)
  (cond
   [(not (ld? listdiff))"error"]
   [(null-ld? listdiff) "error"]
   [else (car (car listdiff))]))

(define(cdr-ld listdiff)
  (cond
   [(not(ld? listdiff))"error"]
   [(null-ld? listdiff) "error"]
   [else(cons (cdr (car listdiff)) (cdr listdiff))]))

(define ld(lambda obj(cons obj '())))

(define (length-ld obj)
  (define (length listdiff result)
    (cond
     [(not(ld? listdiff)) "error"]
     [(null-ld? listdiff) result]
     [else (length (cdr-ld listdiff) (+ 1 result))])) ;create a new function for tail recursion optimization
  (length obj 0))
  
(define(cons-ld-temp obj listdiff)
  (cons (append-ld-helper obj (car listdiff)) (cdr listdiff)))  
(define (append-ld-helper a b)
  (cond
   [(equal? b '()) a]
   [(equal? a '()) b]
   [else (cons (car a) (append-ld-helper (cdr a) b))]))
   ;these are needed because otherwise the append-ld will hava one list->diff be a list of elements instead of elements themselves 
(define (append-ld listdiff . tail)
  (define (append-helper listdiffs result)
    (cond
     [(not(ld? (car listdiffs))) "error"]
     [else (if(null? (cdr listdiffs))
	      (cons-ld-temp result (car listdiffs))
	      (append-helper (cdr listdiffs) (append (ld->list (car listdiffs)) result)))])) ;here have to use append instead of cons 
  (cond
   [(null? tail) listdiff]
   [else (append-helper (cons listdiff tail) '())]))

(define (ld-tail listdiff k)
  (cond
   [(< k 0) "error"]
   [(> k (length-ld listdiff)) "error"]
   [(= k 0) listdiff]
   [(not (ld? listdiff)) "error"]
   [else (ld-tail (cdr-ld listdiff) (- k 1))]))

(define (ld->list listdiff)
  (define (create-tail a result)
    (if (null-ld? a)
        result
        (create-tail (cdr-ld a) (cons  (car-ld a) result))))
  (if(not(ld? listdiff))
     "error"
     (reverse(create-tail listdiff '()))))  ;reverse is necessary !!

(define(list->ld list)
  (if (not(list? list)) "error"
      ((cons list '() ))))

(define (map-listdiff proc listdiff)
  (cond
   [(null? listdiff) "error"]
   [(null-ld? listdiff) listdiff]
   [else (cons-ld (apply proc (cons (car-ld listdiff) '())) (map-listdiff proc (cdr-ld listdiff)))]
   ))

(define(map-ld-helper result proc listdiffs)
  (cond
   [(not (ld? (car listdiffs))) "error"]
   [(null? (cdr listdiffs)) (cons (map-listdiff proc (car listdiffs)) result)]
   [else (map-ld-helper (cons (map-listdiff proc (car listdiffs)) result) proc (cdr listdiffs))]))

(define(map-ld  proc . listdiffs)
  (cond
   [(null? listdiffs) "error"]
   [else (cons (map-ld-helper '() proc listdiffs) '())]))

(define (expr2ld-helper expr)
  (if (pair? expr)
      (cons (expr2ld-helper (car expr)) (expr2ld-helper (cdr expr)))  ;go recursion until reach the individual symbol
      (cond
       [(equal? expr 'null?) 'null-ld?]
       [(equal? expr 'list?) 'ld?]
       [(equal? expr 'cons) 'cons-ld]
       [(equal? expr 'car) 'car-ld]
       [(equal? expr 'cdr) 'cdr-ld]
       [(equal? expr 'append) 'append-ld]
       [(equal? expr 'list) 'ld]
       [(equal? expr 'length) 'length-ld]
       [(equal? expr 'list-tail) 'ld-tail]
       [(equal? expr 'map) 'map-ld]
       [else expr])))

(define (expr2ld expr)
  (if (null? (cdr expr))
      (cons (expr2ld-helper (car expr)) '())  ;if not cons '() the last one will be without the ()
      (cons (expr2ld-helper(car expr)) (expr2ld (cdr expr)))))
