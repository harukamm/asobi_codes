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

let sat b = if b then (Sym "t") else Nil
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
  | Sym ("t") -> cont (Sym ("t"))
  | Sym (s) ->
     begin
       try cont (Env.get env s)
       with Not_found -> raise (Invalid_use (s ^ " is not defined"))
     end
  | Int (i) -> cont (Int i)
  | Cons (Sym "atom", Cons (r, Nil)) ->
     eval r env (fun e -> cont (sat (e = Nil)))
  | Cons (Sym "eq", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' -> eval e2 env (fun e2' -> cont (sat (e1' = e2'))))
  | Cons (Sym "car", Cons (e1, e2)) -> eval e1 env cont
  | Cons (Sym "cdr", Cons (e1, e2)) -> eval e2 env cont
  | Cons (Sym "cons", Cons (e1, e2)) ->
     eval e1 env (fun e1' -> eval e2 env (fun e2' -> cont (Cons (e1', e2'))))
  | Cons (Sym op, Cons (e1, Cons (e2, Nil))) when List.mem op opsym ->
     let f = List.assoc op op_table in
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' ->
			       let msg = " is not an integer" in
			       match (e1', e2') with
				 (Int (i1), Int (i2)) -> cont (Int (f i1 i2))
			       | (Int _, _) -> failwith ((to_string e2) ^ msg)
			       | _ -> failwith ((to_string e1) ^ msg)))
  | Cons (Sym "-", Cons (e, Nil)) ->
     eval e env (fun e' ->
		 match e' with
		   Int (i) -> cont (Int (- i))
		 | _ -> failwith ((to_string e') ^ " cant be minus"))
  | Cons (Sym "if", Cons (p, Cons (x, Cons (y, Nil)))) ->
     eval p env (fun p' ->
		 if p' = Sym ("t") then eval x env cont else eval y env cont)
  | Cons (Sym "quote", Cons (r, Nil)) -> cont r
  | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym "define", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym s, e) when List.mem s (opsym @ rwords) -> raise (Invalid_use s)
  | Cons (l, Nil) -> eval l env (fun e' -> cont (Cons (e', Nil)))
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
     try
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
     with Invalid_use msg ->
       raise (Invalid_use ("error: " ^ msg ^ "\ncannot eval: " ^ (to_string x)))

(* go : expr_t list -> *)
let go program =
  loop program Env.empty (List.map to_string)

let ascii code = String.make 1 (Char.chr code)
let asciis st en =
  let rec h i = if en < i then [] else (ascii i) :: h (i + 1) in h st
let num = asciis 48 57
let alpha = asciis 97 122
let ident = "-" :: (num @ alpha)

(* token *)
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
  let rec skip lst i bf =
    if i < len then
      let s = String.sub str i 1 in
      if (List.mem s lst) then skip lst (i + 1) (bf ^ s)
      else (bf, i)
    else (bf, i)
  in
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
      | "\n" | "\r" | ";" -> ([], ni)
      | "-" when List.mem ns num ->
	 let (sint, i') = skip num ni "" in
	 recadd i' (I (-(int_of_string sint)))
      | _ when List.mem s opsym ->
	 recadd ni (S (s))
      | _ when List.mem s num ->
	 let (sint, i') = skip num i "" in
	 recadd i' (I (int_of_string sint))
      | _ when List.mem s alpha ->
	 let (sym, i') = skip ident i "" in
	 recadd i' (S (sym))
      | _ -> failwith ("invalid char: " ^ s ^ " at " ^ (string_of_int i))
    else ([], i)
  in
  (* h : int -> (token list) list *)
  let rec h i =
    let (_, i') = skip [" "; "\t"; "\n"; "\r"; ";"] i "" in
    if i' < len then
      let (line, ptr) = inner i' in
      line :: (h ptr)
    else []
  in h 0

(* parse *)
let line = ref 0
let ptr = ref 0
let tarr = ref (Array.make 0 L)

(* value := [a-z]+
          | [0-9]+
 * expr := value
         | "(" expr* ")" *)
let ahead () = ptr := !ptr + 1
let error msg = failwith msg
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
  try value ()
  with _ ->
    let p = !ptr in
    if (accept (fun s -> s = L)) then
      let es = many expr in
      expect (fun s -> s = R) (add_info "expected ')'" !ptr !line);
      List.fold_right (fun e t -> Cons (e, t)) es Nil
    else error (add_info "invalid sytax" p !line)

(* parse : string -> expr_t *)
let parse input =
  line := 0;
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

let start input = go (parse input)

(* test *)
let e1 = parse "(define (f x) (atom x))\n(f ())"
let e2 = start "(define (my-cons a d) (lambda (f) (f a d)))\n
		(define (my-car ad) (ad (lambda (a d) a)))\n
		(define (my-cdr ad) (ad (lambda (a d) d)))\n
		(define (f x y) (+ x y))\n(f 1 2)"

