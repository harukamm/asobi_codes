open Printf
(*
 * https://ja.wikipedia.org/wiki/純LISP
 * nil, t
 *
 * atom : atom v (eval to t if v = nil, nil otherwise)
 * eq : eq e1 e2 (eval to t if e1 = e2, nil otherwise)
 * car : car (e1. e2) (eval to e1)
 * cdr : cdr (e1. e2) (eval to e2)
 * cons : cons e1 e2 (eval to (e1 . e2))
 *
 * if : if p x y
 * quote : quote x
 * lambda : lambda (x1 x2 .. xn) y
 * define : define (f x1 x2 .. xn) y
 *
 * <Generative grammer>
 * e := nil
      | t
      | "(" if e e e ")"
      | "(" quote e ")"
      | "(" lambda "(" x1 .. xn ")" e ")"
      | "(" define "(" f x1 .. xn ")" e ")"
      | "(" atome e ")"
      | "(" eq e e ")"
      | "(" car e ")"
      | "(" cdr e ")"
      | "(" e e1 .. en ")"
      | pair
   pair := "(" cons e e ")"
         | "(" e . e ")"
   v := e
 * application 
 *)

module Env : sig
  type ('a, 'b) t = Empty
		              | Cons of 'a * 'b * ('a, 'b) t
  val empty : ('a, 'b) t
  val get : ('a, 'b) t -> 'a -> 'b
  val add : ('a, 'b) t -> 'a -> 'b -> ('a, 'b) t
end
  =
  struct
    type ('a, 'b) t = Empty
		                | Cons of 'a * 'b * ('a, 'b) t
    let empty = Empty
    let rec get env key = match env with
        Empty -> raise Not_found
      | Cons (k, v, e) -> if k = key then v else get e key
    let rec add env key valu =
      Cons (key, valu, env)
  end

type expr_t = Nil
	          | Sym of string
	          | Int of int
	          | Cons of expr_t * expr_t

(* to_string : expr_t -> string *)
let rec to_string exp =
  let rec h e = match e with
      Nil -> "()"
    | Sym (s) -> s
    | Int (i) -> string_of_int i
    | Cons ((Cons _) as x, Nil) -> "(" ^ (h x) ^ ")"
    | Cons ((Cons _) as x, r) -> "(" ^ (h x) ^ ") " ^ (h r)
    | Cons (l, Nil) -> h l
    | Cons (l, r) -> (h l) ^ " " ^ (h r)
  in h (Cons (exp, Nil))

(* flatten : expr_t -> expr_t list *)
let rec flatten e = match e with
    Nil -> []
  | Sym s -> [Sym s]
  | Int i -> [Int i]
  | Cons (e, r) -> e :: (flatten r)

(* error *)
exception Eval_error of string
let eval_error msg ?(s = None) e =
  let info = match s with None -> "" | Some t -> ", " ^ t in
  raise (Eval_error (msg ^ ": " ^ (to_string e) ^ info))
let argc_error n = eval_error "Wrong number of arguments" ~s:(Some (string_of_int n))
let var_void_error = eval_error "Symbol's value as variable is void"
let wrong_type_error = eval_error "Wrong type argument"
let invalid_func_error = eval_error "Invalid function"
let const_symbol_error = eval_error "Attempt to set a constant symbol"

let op_table = [("+", (+)); ("-", (-)); ("*", ( * )); ("/", (/)); ("mod", (mod))]
let opsym = List.map (fun (k, _) -> k) op_table
let rwords = ["atom"; "eq"; "car"; "cdr"; "cons"; "if"; "quote"; "lambda"; "defun"; "define"]

let id = fun x -> x
(* eval : expr_t -> (string, expr_t) Env.t -> (expr_t -> expr_t) -> expr_t *)
let rec eval exp env cont = match exp with
    Nil -> cont (Nil)
  | Sym "nil" -> cont (Nil)
  | Sym "t" -> cont (Sym ("t"))
  | Sym (s) ->
     begin
       try cont (Env.get env s)
       with Not_found -> var_void_error (Sym (s))
     end
  | Int (i) -> cont (Int (i))
  | Cons (Sym "if", Cons (p, Cons (x, Cons (y, Nil)))) ->
     eval p env (fun p' ->
		             if p' = Sym ("t") then eval x env cont else eval y env cont)
  | Cons (Sym "quote", Cons (r, Nil)) -> cont r
  | Cons (Sym "`", Cons (r, Nil)) -> cont r
  | Cons (Sym "lambda", _) -> cont exp
  | Cons (Sym "defun", Cons (Sym f, (Cons (args, _)))) -> cont exp
  | Cons (Sym "define", Cons (Sym f, (Cons (e, _)))) -> cont exp
  | Cons (Sym "atom", Cons (r, Nil)) ->
     eval r env (fun e ->
		             match e with
		             | Nil | Sym _ | Int _ -> cont (Sym ("t"))
		             | Cons _ -> cont (Nil))
  | Cons (Sym "eq", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		              eval e2 env (fun e2' ->
			                         match (e1', e2') with
			                         | (Nil, Nil) -> cont (Sym "t")
			                         | (Sym s1, Sym s2) when s1 = s2 -> cont (Sym "t")
			                         | (Int i1, Int i2) when i1 = i2 -> cont (Sym "t")
			                         | _ -> cont (Nil)))
  | Cons (Sym "car", Cons (e, Nil)) ->
     eval e env (fun e' -> match e' with
			                       Nil -> cont (Nil)
			                     | Cons (l, _) -> cont (l)
			                     | v -> wrong_type_error v)
  | Cons (Sym "cdr", Cons (e, Nil)) ->
     eval e env (fun e' -> match e' with
			                       Nil -> cont (Nil)
			                     | Cons (_, r) -> cont (r)
			                     | v -> wrong_type_error v)
  | Cons (Sym "cons", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		              eval e2 env (fun e2' -> cont (Cons (e1', e2'))))
  | Cons (Sym s, r) when List.mem s rwords ->
     let len = List.length (flatten r) in argc_error len (Sym s)
  | Cons (Sym op, r) when List.mem op opsym ->
     let elst' = List.map (fun e -> eval e env id) (flatten r) in
     let len = List.length elst' in
     let _ = if op = "/" && len < 2 then argc_error len (Sym "/") in
     let take_int e = match e with Int (i) -> i | e -> wrong_type_error e in
     if len = 0
     then cont (Int (0))
     else let hd = take_int (List.hd elst') in
	        let tl = List.tl elst' in
	        let f = List.assoc op op_table in
	        let n' = List.fold_left (fun n e -> f n (take_int e)) hd tl in
	        cont (Int (n'))
  | Cons (l, r) ->
     eval l env (fun f ->
		             match f with
		             | Cons (Sym "lambda", Cons (args, Cons (e', Nil))) ->
		                let take_argname e = match e with
			                  Nil -> const_symbol_error Nil
			                | Sym ("t") -> const_symbol_error (Sym ("t"))
		       	          | Sym s -> s
			                | e -> invalid_func_error e in
		                let argnames = List.map take_argname (flatten args) in
		                let elst' = List.map (fun e -> eval e env id) (flatten r) in
		                let env2 =
			                try List.fold_right2
			                      (fun n e env' -> Env.add env' n e) argnames elst' env
			                with _ -> argc_error (List.length elst') f in
			              eval e' env2 cont
		             | _ -> invalid_func_error f)

let genv = ref Env.empty
(* evals : expr_t list -> expr_t list *)
let rec evals exprs  = match exprs with
    [] -> []
  | x :: xs ->
     let x' = eval x !genv id in
     let _ = match x' with
       | Cons (Sym "define", Cons (Sym f, Cons (e, Nil))) ->
	        let e' = eval e !genv id in
	        genv := Env.add !genv f e'
       | Cons (Sym "defun", Cons (Sym f, (Cons (args, e)))) ->
	        let lam = Cons (Sym "lambda", Cons (args, e)) in
	        genv := Env.add !genv f lam
       | _ -> () in
     x' :: evals xs

(* go : expr_t list -> string list *)
let go exprs = List.map to_string (evals exprs)

let ascii code = String.make 1 (Char.chr code)
let asciis st en =
  let rec h i = if en < i then [] else (ascii i) :: h (i + 1) in h st
let num = asciis 48 57

(* token *)
exception Parser_error of string
let error msg = raise (Parser_error msg)
type token = I of int
	         | S of string
	         | L | R
let string_of_token t = match t with
    I (i) -> string_of_int i
  | S (s) -> s
  | L -> "("
  | R -> ")"

(* tokenize : string -> (token list) list *)
let tokenize str =
  let len = String.length str in
  let rec until p i bf =
    if i < len then
      let s = String.sub str i 1 in
      if p s then until p (i + 1) (bf ^ s)
      else (bf, i)
    else (bf, i)
  in
  let skip lst i = until (fun s -> List.mem s lst) i "" in
  (* inner : int -> (token list * int) *)
  let rec inner i =
    if i < len then
      let ni = i + 1 in
      let ns = if ni < len then String.sub str ni 1 else "" in
      let s = String.sub str i 1 in
      let recadd i' t =
	      let (slst, ptr) = inner i' in (t :: slst, ptr) in
      match s with
      | " " | "\t" -> inner ni
      | "(" -> recadd ni L
      | ")" -> recadd ni R
      | "\n" | "\r" -> ([], ni)
      | ";" ->
	       let (_, i') = until (fun s -> s <> "\n") ni "" in ([], i' + 1)
      | "`" -> recadd ni (S ("`"))
      | "-" when List.mem ns num ->
	       let (sint, i') = skip num ni in
	       recadd i' (I (-(int_of_string sint)))
      | _ when List.mem s num ->
	       let (sint, i') = skip num i in
	       recadd i' (I (int_of_string sint))
      | _ ->
	       let spec = [" "; "\t"; "("; ")"; "\n"; "\r"; ";"] in
	       let (sym, i') = until (fun s -> not (List.mem s spec)) i "" in
	       recadd i' (S (sym))
      | _ -> error ("invalid char: " ^ s ^ " at " ^ (string_of_int i))
    else ([], i)
  in
  (* h : int -> (token list) list *)
  let rec h i =
    if i < len then
      let (line, ptr) = inner i in
      if line = [] then h ptr else (line :: (h ptr))
    else []
  in h 0

(* parse *)
let line = ref 0
let ptr = ref 0
let tarr = ref (Array.make 0 L)

(* value := [a-z]+
          | [0-9]+
 * expr := value
         | "(" expr* ")"
         | "`" expr *)

let ahead () = ptr := !ptr + 1
let accept p = if !ptr < Array.length !tarr then
		             if p (!tarr.(!ptr)) then (ahead(); true) else false
	             else false
let expect p s = try let x = !tarr.(!ptr) in if accept p then x else error s
		             with _ -> error s
let add_info msg p l =
  let s = if p < Array.length !tarr
	        then "\"" ^ (string_of_token !tarr.(p)) ^ "\""
	        else (string_of_int p) ^ "-th token" in
  msg ^ " at " ^ s ^
    ", line " ^ (string_of_int l)

(* many : (unit -> 'a) -> 'a list *)
let rec many p =
  try let e = p () in
      e :: many p
  with _ -> []

(* value : unit -> expr_t *)
let value () =
  let x = expect (fun t -> t <> L && t <> R)
		             (add_info "neither a symbol nor int" !ptr !line) in
  match x with
  | S (s) -> if s = "nil" then Nil else Sym (s)
  | I (i) -> Int (i)
  | _ -> error ""

(* expr -> unit -> expr_t *)
let rec expr () =
  try
    begin
      if (accept (fun s -> s = S ("`"))) then
        let e = expr () in
        Cons (Sym ("`"), Cons (e, Nil))
      else value ()
    end
  with _ ->
    let p = !ptr in
    if (accept (fun s -> s = L)) then
      let es = many expr in
      expect (fun s -> s = R) (add_info "expected ')'" !ptr !line);
      List.fold_right (fun e t -> Cons (e, t)) es Nil
    else error (add_info "invalid sytax" p !line)

(* parse : string -> expr_t list *)
let parse input =
  (* tokens : (string list) list *)
  let tokens = tokenize input in
  List.map (fun token ->
	          line := !line + 1;
	          tarr := Array.of_list token;
	          ptr := 0;
	          let e = expr () in
	          if !ptr < Array.length !tarr then
	            error ("cannot parse from " ^ (string_of_token (!tarr.(!ptr))))
	          else e
	         ) tokens

(* string -> expr_t list *)
let start input = let _ = line := 0 in go (parse input)

let e1 = parse "(define (f x) (atom x))\n(f ())"
let e2 = parse "(define (my-cons a d) (lambda (f) (f a d)))\n
		            (define (my-cons a d) (lambda (f) (f a d)))"
let e2 = start "(quote ((1 2) (3 4)))"
let e3 = start "(car (quote ((42 (11 22) 99) (3 7))))"
let e4 = start "((lambda () (+ 1 2)))"
let e5 = start "(defun katsu (e1 e2) (if (eq e1 t) (if (eq e2 t) t nil) nil))
		            (katsu (eq (mod 10 5) 0) (eq (mod 15 5) 0))
		            (katsu (eq (mod 10 5) 1) (eq (mod 15 5) 0))
		            (define FizzBuzz (quote FizzBuzz))
		            (define Buzz (quote Buzz))
		            (define Fizz (quote Fizz))
		            (defun fb (n) (if (eq (mod n 15) 0) FizzBuzz (if (eq (mod n 5) 0) Buzz (if (eq (mod n 3) 0) Fizz n)))) ;fizzbuzz
		            (fb 15) ;FizzBuzz
		            (fb 10) ;Buzz
		            (fb 18) ;Fizz
		            (fb 11) ;11"

let test () =
  let ic = open_in "test.l" in
  try let rec h () =
	      let line = input_line ic in
	      let exp =
	        try parse line
	        with Parser_error msg -> print_endline ("> " ^ line);
				                           raise (Parser_error msg)
	      in
	      let _ = match exp with
	          [] -> ()
	        | x :: _ -> print_endline ("> " ^ line);
		                  print_endline (List.hd (go [x])) in
	      flush stdout;
	      h ()
      in h ()
  with End_of_file -> close_in ic
     | e -> close_in_noerr ic; raise e
