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

let sat b = if b then (Sym "T") else Nil
(* is_allsym : returns true if expr is composed only with sym *)
(* this function is used when checking type of agrs for define/lambda *)
let rec is_allsym e = match e with
    Sym _ -> true
  | Cons (Sym _, Nil) -> true
  | Cons (Sym _, r) -> is_allsym r
  | _ -> false

(* flatten_sym : expr_t -> string list *)
let rec flatten_sym e = match e with
    Nil -> []
  | Sym s -> [s]
  | Cons (Sym s, r) -> s :: (flatten_sym r)
  | _ -> failwith "cannot flatten"

(* flatten : expr_t -> expr_t list *)
let rec flatten e = match e with
    Nil -> [Nil]
  | Sym s -> [Sym s]
  | Int i -> [Int i]
  | Cons (e, Nil) -> [e]
  | Cons (e, r) -> e :: (flatten r)

let op_table = [("+", (+)); ("-", (-)); ("*", ( * )); ("/", (/)); ("%", (mod))]
let opsym = List.map (fun (k, _) -> k) op_table
let rwords = ["atom"; "eq"; "car"; "cdr"; "cons"; "if"; "quote"; "lambda"; "define"]

exception Invalid_use of string
(* eval : expr_t -> (string, expr_t) Env.t -> (expr_t -> 'a) -> 'a *)
let rec eval exp env cont = match exp with
    Nil -> cont Nil
  | Sym ("T") -> cont (Sym ("T"))
  | Sym (s) ->
     begin
       try cont (Env.get env s)
       with Not_found -> raise (Invalid_use "variable")
     end
  | Int (i) -> cont (Int i)
  | Cons (Sym "atom", Cons (r, Nil)) ->
     eval r env (fun e -> cont (sat (e = Nil)))
  | Cons (Sym "eq", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' -> cont (sat (e1' = e2'))))
  | Cons (Sym "car", Cons (e1, Cons (e2, Nil))) -> eval e1 env cont
  | Cons (Sym "cdr", Cons (e1, Cons (e2, Nil))) -> eval e2 env cont
  | Cons (e1, Cons (Sym ".", Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' -> cont (Cons (e1', e2'))))
  | Cons (Sym "-", Cons (e, Nil)) ->
     eval e env (fun e' ->
		 match e' with
		   Int (i) -> cont (Int (- i))
		 | _ -> failwith ((to_string e') ^ " cant be minus"))
  | Cons (Sym op, Cons (e1, Cons (e2, Nil))) when List.mem op opsym ->
     let f = List.assoc op op_table in
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' ->
			       let msg = " is not an integer" in
			       match (e1', e2') with
				 (Int (i1), Int (i2)) -> cont (Int (f i1 i2))
			       | (Int _, _) -> failwith ((to_string e2') ^ msg)
			       | _ -> failwith ((to_string e1') ^ msg)))
  | Cons (Sym "if", Cons (p, Cons (x, Cons (y, Nil)))) ->
     eval p env (fun p' ->
		 if p' = Sym ("T") then cont x else cont y)
  | Cons (Sym "quote", Cons (r, Nil)) -> cont r
  | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym "define", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym (s), r) when List.mem s (opsym @ rwords) -> raise (Invalid_use s)
  | Cons (l, r) ->
     eval l env (fun e1 ->
		   match e1 with
		   | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) ->
		      let arglst = flatten_sym args in (* should not fail *)
		      let elst = flatten r in (* call by name *)
		      let env2 =
			try
			  List.fold_right2
			    (fun k e env' -> Env.add env' k e) arglst elst env
			with _ -> raise (Invalid_use "insufficient args") in
			eval e env2 cont
		   | _ -> raise (Invalid_use "application"))

(* loop : expr_t list -> (string, expr_t) Env.t -> (expr_t list -> 'a) -> 'a *)
let rec loop exprs env cont = match exprs with
    [] -> cont []
  | x :: xs ->
     eval x env (fun v ->
		 let cont' = (fun es -> cont (v :: es)) in
		 match v with
		 | Cons (Sym "define", Cons (Sym f, Cons (e, Nil))) ->
		    let env2 = Env.add env f (Cons (e, Nil)) in
		    loop xs env2 cont'
		 | Cons (Sym "define", Cons (Cons (Sym f, args), Cons (e, Nil))) ->
		    let env2 = Env.add env f (Cons (Sym "lambda", Cons (args, Cons (e, Nil)))) in
		    loop xs env2 cont'
		 | _ -> loop xs env cont')

(* go : expr_t list -> *)
let go program =
  loop program Env.empty (List.map to_string)

(* tokenize : string -> (string list) list *)
let tokenize str =
  let len = String.length str in
  let rec skip p i bf =
    if i < len then
      let s = String.sub str i 1 in
      if p s then skip p (i + 1) (bf ^ s)
      else (bf, i)
    else (bf, i)
  in
  (* inner : int -> (string list * int) *)
  let rec inner i =
    if i < len then
      let s = String.sub str i 1 in
      let ni = i + 1 in
      match s with
      | " " | "\t" -> inner ni
      | "\n" | "\r" ->
	 let (_, i') = skip (fun s -> List.mem s ["\n"; "\r"]) ni "" in ([], i')
      | "(" | ")" ->
	 let (slst, ptr) = inner ni in (s :: slst, ptr)
      | _ ->
	 let special = [" "; "\t"; "\n"; "\r"; "("; ")"] in
	 let (sym, i') = skip (fun s -> not (List.mem s special)) i "" in
	 let (slst, ptr) = inner i' in
	 (sym :: slst, ptr)
    else ([], i)
  in
  (* h : int -> (string list) list *)
  let rec h i =
    if i < len then
      let (line, ptr) = inner i in
      line :: (h ptr)
    else []
  in h 0

(* parse *)
let line = ref 0
let ptr = ref 0
let tarr = ref (Array.make 0 "")

(* symbol := [a-z]+
 * expr := symbol
         | "(" expr* ")" *)

let ahead () = ptr := !ptr + 1
let error msg = failwith msg
let accept p = if !ptr < Array.length !tarr then
		 if p (!tarr.(!ptr)) then (ahead(); true) else false
	       else false
let expect p s = if accept p then () else error s
let add_info msg p l =
  let s = if p < Array.length !tarr then "\"" ^ !tarr.(p) ^ "\""
	  else (string_of_int p) ^ "-th token" in
  msg ^ " at " ^ s ^
    ", line " ^ (string_of_int l)

(* value : unit -> expr_t *)
let value () =
  let x = !tarr.(!ptr) in
  let _ = expect (fun s -> s <> "(" && s <> ")")
		 (x ^ ": neither symbol nor int") in
  try Int (int_of_string x)
  with Failure "int_of_string" -> Sym (x)

(* many : (unit -> expr_t) -> expr_t list *)
let rec many p =
  try let e = p () in
      e :: many p
  with _ -> []

(* expr -> unit -> expr_t *)
let rec expr () =
  try
    value ()
  with _ ->
    let p = !ptr in
    if (accept (fun s -> s = "(")) then
      let es = many expr in
      expect (fun s -> s = ")") (add_info "expected ')'" !ptr !line);
      List.fold_right (fun e t -> Cons (e, t)) es Nil
    else error (add_info "invalid sytax" p !line)

(* parse : string -> expr_t *)
let parse input =
  (* tokens : (string list) list *)
  let tokens = tokenize input in
  List.map (fun token ->
	    line := !line + 1;
	    tarr := Array.of_list token;
	    ptr := 0;
	    expr ()) tokens

let start input =
  let _ = line := 1 in go (parse input)

(* test *)
let e1 = parse "(define (f x) (atom x))\n(f ())"
let e2 = start "(define (my-cons a d) (lambda (f) (f a d)))\n
		(define (my-car ad) (ad (lambda (a d) a)))\n
		(define (my-cdr ad) (ad (lambda (a d) d)))\n
		(define (f x y) (+ x y))\n(f 1 2)"

