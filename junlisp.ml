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

let id x = x

(* print : expr_t -> (string -> string) -> string *)
let rec print e cont = match e with
    Nil -> cont "Nil"
  | Sym (s) -> cont s
  | Cons (l, r) ->
     print l (fun sl ->
	      print r (fun sr -> cont ("(" ^ sl ^ " " ^ sr ^ ")")))

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
  | Cons (Sym "quote", r) -> cont r
  | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym "define", Cons (Sym _, Cons (e, Nil))) -> cont exp
  | Cons (Sym "define", Cons (Cons (Sym _, args), Cons (e, Nil))) when is_allsym args -> cont exp
  | Cons (Sym (s), r) when List.mem s rwords -> raise (Invalid_use s)
  | Cons (l, r) ->
     eval l env (fun e1 ->
		 begin
		   match e1 with
		   | Cons (Sym "lambda", Cons (args, Cons (e, Nil))) ->
		      let argslst = flatten_sym args in (* should not fail *)
		      eval r env
			   (fun e2 ->
			    let elst = flatten e2 in
			    (* throws Invalid_argument *)
			    let env2 = List.fold_right2
					 (fun a e env' -> Env.add env' a e) argslst elst env in
			    eval e env2 cont)
		   | _ -> raise (Invalid_use "application")
		 end)

(* loop : expr_t list -> (string, expr_t) Env.t -> (string -> 'a) -> 'a *)
let rec loop exprs env cont = match exprs with
    [] -> cont ""
  | x :: xs ->
     eval x env (fun ve ->
		 let sline = print ve id in
		 let cont' = (fun s -> cont (sline ^ "; " ^ s)) in
		 match ve with
		 | Cons (Sym "define", Cons (Sym f, Cons (e, Nil))) ->
		    let env2 = Env.add env f (Cons (e, Nil)) in
		    loop xs env2 cont'
		 | Cons (Sym "define", Cons (Cons (Sym f, args), Cons (e, Nil))) ->
		    let env2 = Env.add env f (Cons (Sym "lambda", Cons (args, Cons (e, Nil)))) in
		    loop xs env2 cont'
		 | _ -> loop xs env cont')

(* go : expr_t list -> unit *)
let go program = loop program Env.empty print_endline
