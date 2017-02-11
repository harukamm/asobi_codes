; env
(define (pair-fst e) (car e))
(define (pair-snd e) (car (cdr e)))
(define (pair-thd e) (car (cdr (cdr e))))
(define (pair-fth e) (car (cdr (cdr (cdr e)))))
(define (make-pair e1 e2) (cons e1 (cons e2 nil)))
(define (get-env env k) (if (eq env nil) nil (if (eq (pair-fst (car env)) k) (pair-snd (car env)) (get-env (cdr env) k))))
(define (add-env env k v) (cons (make-pair k v) env))
(define (adds-env env args vals) (if (eq args nil) env (adds-env (add-env env (car args) (car vals)) (cdr args) (cdr vals))))
(define (append-env env1 env2) (if (eq env1 nil) env2 (append-env (cdr env1) (cons (car env1) env2))))

; env-test
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 4) ; 2
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 0) ; nil
(get-env (add-env (add-env (add-env nil 9 3) 25 5) 4 2) 9) ; 3
(adds-env (add-env (add-env nil `a 1) `b 2) `(c d e) `(5 2 1)) ; ((e 1) (d 2) (c 5) (b 1) (a 1))
(append-env `((i 1) (j 2)) (add-env (add-env nil `t1 10) `t2 10)) ; ((j 2) (i 1) (t2 10) (t1 10))

; operator
(define (lst-add lst) (if (eq lst nil) 0 (+ (car lst) (lst-add (cdr lst)))))
(define (lst-sub lst) (if (eq lst nil) 0 (- (car lst) (lst-sub (cdr lst)))))
(define (lst-times lst) (if (eq lst nil) 1 (* (car lst) (lst-times (cdr lst)))))
(define (lst-div lst) (if (eq lst nil) 1 (if (eq (cdr lst) nil) (car lst) (/ (car lst) (pair-snd lst) (lst-div (cdr (cdr lst)))))))

; operator-test
(lst-add `(5 10 2)) ; 17
(lst-sub `(10 5 5)) ; 0
(lst-times `(10 2 2)) ; 40
(lst-div `(100 50 2)) ; 1

; eval
(define (evals es env) (if (eq es nil) nil (cons (eval (car es) env) (evals (cdr es) env))))
(define (eval e env) (eval-nil e env))
(define (eval-nil e env) (if (eq e nil) nil (eval-t e env)))
(define (eval-t e env) (if (eq e t) t (eval-var e env)))
(define (eval-var e env) (if (atom e) (if (eq (get-env env e) nil) e (get-env env e)) (eval-if e env)))
(define (eval-if e env) (if (eq `if (car e)) (if (eval (pair-snd e) env) (eval (pair-thd e) env) (eval (pair-fth e) env)) (eval-quote e env)))
(define (eval-quote e env) (if (eq `qt (car e)) (pair-snd e) (eval-lambda e env)))
(define (eval-lambda e env) (if (eq `lambda (car e)) e (eval-define e env)))
(define (eval-define e env) (if (eq `define (car e)) e (eval-atom e env)))
(define (eval-atom e env) (if (eq `atom (car e)) (atom (eval (pair-snd e) env)) (eval-eq e env)))
(define (eval-eq e env) (if (eq `eq (car e)) (eq (eval (pair-snd e) env) (eval (pair-thd e) env)) (eval-car e env)))
(define (eval-car e env) (if (eq `car (car e)) (car (eval (pair-snd e) env)) (eval-cdr e env)))
(define (eval-cdr e env) (if (eq `cdr (car e)) (cdr (eval (pair-snd e) env)) (eval-cons e env)))
(define (eval-cons e env) (if (eq `cons (car e)) (cons (eval (pair-snd e) env) (eval (pair-thd e) env)) (eval-let e env)))
(define (eval-let e env) (if (eq `let (car e)) (eval (pair-thd e) (append-env (pair-snd e) env)) (eval-add e env)))
(define (eval-add e env) (if (eq `+ (car e)) (lst-add (evals (cdr e) env)) (eval-sub e env)))
(define (eval-sub e env) (if (eq `- (car e)) (if (eq (cdr (cdr e)) nil) (- (eval (pair-snd e) env)) (lst-sub (evals (cdr e) env))) (eval-times e env)))
(define (eval-times e env) (if (eq `* (car e)) (lst-times (evals (cdr e) env)) (eval-div e env)))
(define (eval-div e env) (if (eq `/ (car e)) (lst-div (evals (cdr e) env)) (eval-app e env)))
(define (eval-app e env) (if (eq `lambda (car (eval (car e) env))) (eval (pair-thd (eval (car e) env)) (adds-env env (pair-snd (eval (car e) env)) (evals (cdr e) env))) nil))

; eval-test
(eval `nil nil) ; nil
(eval `t nil) ; t
(eval `tt (add-env nil `tt 10)) ; 10
(eval `(if t 1 2) nil) ; 1
(eval `(qt hoge) nil) ; hoge
(eval `(lambda (x) x) nil) ; (lambda (x) x)
(eval `(define (f x y) nil) nil) ; (define (f x y) nil)
(eval `(atom t) nil) ; t
(eval `(eq 1 1) nil) ; t
(eval `(eq t1 t2) (add-env (add-env nil `t1 10) `t2 10)) ; t
(eval `(car (qt (5 1))) nil) ; 5
(eval `(cdr (qt (5 1))) nil) ; (1)
(eval `(cons 1 (qt (1 2))) nil) ; (1 1 2)
(eval `(let ((i 1) (j 1)) (eq i j)) nil) ; t
(eval `(+ 5 3 1) nil) ; 9
(eval `(- (+ 5 3 2)) nil) ; -10
(eval `(+ 1 (+ 2 (+ 3 4))) nil) ; 10
(eval `(* t1 t2) (add-env (add-env nil `t1 -1) `t2 -1)) ; 1
(eval `(f 1) (add-env nil `f (lambda (x) x))) ; 1
(eval `(f 1) (add-env nil `f (lambda (x) (eq x 1)))) ; 1
