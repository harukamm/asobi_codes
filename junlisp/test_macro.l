; env
(define (pair-fst e) (car e))
(define (pair-snd e) (car (cdr e)))
(define (pair-thd e) (car (cdr (cdr e))))
(define (pair-fth e) (car (cdr (cdr (cdr e)))))
(define (make-pair e1 e2) (cons e1 (cons e2 nil)))
(define (get-env env k) (if (eq env nil) nil (if (eq (pair-fst (car env)) k) (pair-snd (car env)) (get-env (cdr env) k))))
(define (add-env env k v) (cons (make-pair k v) env))

; env-test
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 4) ; 2
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 0) ; nil
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 9) ; 3
