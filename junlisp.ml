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
	    | Cons of expr_t * expr_t
(*
type value_t = Lambda of string list * expr_t
	     | Var of string
	     | Quote of expr_t
 *)

(* slist_to_string ["a"; "b"; "c"] => "a b c" *)
(* slist_to_string : string list -> string *)
let slist_to_string slst =
  try let h = List.hd slst in
      let r = List.tl slst in
      List.fold_right (fun s acc -> acc ^ " " ^ s) r h
  with _ -> ""

(* print : expr_t -> (string -> string) -> string *)
let rec print e cont = match e with
    Nil -> cont "()"
  | Sym (s) -> cont s
  | Cons (Cons (e1, e2), Nil) ->
     print (Cons (e1, e2))
	   (fun sl -> cont ("(" ^ sl ^ ")"))
  | Cons (Cons (e1, e2), r) ->
     print (Cons (e1, e2))
	   (fun sl -> print r (fun sr -> cont ("(" ^ sl ^ ") " ^ sr)))
  | Cons (l, Nil) ->
     print l (fun sl -> cont sl)
  | Cons (l, r) ->
     print l (fun sl ->
	      print r (fun sr -> cont (sl ^ " " ^ sr)))

let sat b = if b then (Sym "T") else Nil
(* is_allsym : returns true if expr is composed only with sym *)
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
  | Cons (e, Nil) -> [e]
  | Cons (e, r) -> e :: (flatten r)

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
  | Cons (Sym "atom", Cons (r, Nil)) ->
     eval r env (fun e -> cont (sat (e = Nil)))
  | Cons (Sym "eq", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' -> cont (sat (e1' = e2'))))
  | Cons (Sym "car", Cons (e1, Cons (e2, Nil))) -> eval e1 env cont
  | Cons (Sym "cdr", Cons (e1, Cons (e2, Nil))) -> eval e2 env cont
  | Cons (Sym "cons", Cons (e1, Cons (e2, Nil))) ->
     eval e1 env (fun e1' ->
		  eval e2 env (fun e2' -> cont (Cons (e1', e2'))))
  | Cons (Sym "if", Cons (p, Cons (x, Cons (y, Nil)))) ->
     eval p env (fun p' ->
		 if p' = Sym ("T") then cont x else cont y)
  | Cons (Sym "quote", Cons (r, Nil)) -> cont r
  | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym "define", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym (s), r) when List.mem s rwords -> raise (Invalid_use s)
  | Cons (l, Cons (r, Nil)) ->
     eval l env (fun e1 ->
		 begin
		   match e1 with
		   | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) ->
		      let arglst = flatten_sym args in (* should not fail *)
		      eval r env
			   (fun e2 ->
			    let elst = flatten e2 in
			    let env2 = List.fold_right2
					 (fun k e env' -> Env.add env' k e) arglst elst env in
			    eval e env2 cont)
		   | _ -> raise (Invalid_use "application")
		 end)

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

(* split : string -> (string list) list *)
let split str =
  let len = String.length str in
  let maybe_cons s lst = if s = "" then lst else s :: lst in
  (* inner : int -> string -> (string list * int) *)
  let rec inner i tmp =
    if i < len then
      let ni = i + 1 in
      let s = String.sub str i 1 in
      match s with
	"\n" -> (maybe_cons tmp [], ni)
      | " " -> (* ignore space *)
	 let (slst, ptr) = inner ni "" in
	 (maybe_cons tmp slst, ptr)
      | "(" | ")" ->
	 let (slst, ptr) = inner ni "" in
	 (maybe_cons tmp (s :: slst), ptr)
      | _ -> inner ni (tmp ^ s)
    else (maybe_cons tmp [], i)
  in
  (* h : int -> (string list) list *)
  let rec h i =
    if i < len then
      let (line, ptr) = inner i "" in
      line :: (h ptr)
    else []
  in h 0

(* parse *)
let ptr = ref 0
let tarr = ref (Array.make 0 "")

(* symbol := [a-z]+
 * expr := symbol
         | "(" expr* ")" *)

let ahead () = ptr := !ptr + 1
let error msg = failwith msg
let accept p = if p (!tarr.(!ptr)) then (ahead(); true) else false
let expect p s = if accept (p) then () else error s

(* symbol : unit -> expr_t *)
let symbol () =
  let x = !tarr.(!ptr) in
  let _ = expect (fun s -> s <> "(" && s <> ")") (x ^ ": not a symbol") in
  Sym (x)

(* many : (unit -> expr_t) -> expr_t list *)
let rec many p =
  try let e = p () in
      e :: many p
  with _ -> []

(* expr -> unit -> expr_t *)
let rec expr () =
  try
    let s = symbol () in s
  with _ ->
    if (accept (fun s -> s = "(")) then
      let es = many expr in
      let _ = expect (fun s -> s = ")") (!tarr.(!ptr) ^ ": not a )") in
      List.fold_right (fun e t -> Cons (e, t)) es Nil
    else error (!tarr.(!ptr) ^ ": invalid sytax")

(* start : string -> unit *)
let start input =
  (* tokens : (string list) list *)
  let tokens = split input in
  (* h : (string list) list -> expr_t list *)
  let rec h t = match t with
      [] -> []
    | token :: ts ->
       let _ = tarr := (Array.of_list token) in
       let _ = ptr := 0 in
       let exp = expr () in
       exp :: h ts
  in go (h (tokens))

(* test *)
let e1 = start "(define (f x) (atom x))\n(f ())"
