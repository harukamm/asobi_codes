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
      | "(" car pair ")"
      | "(" cdr pair ")"
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
	    | T
	    | Var of string
	    | If of expr_t * expr_t * expr_t
	    | Quote of expr_t
	    | Lambda of string list * expr_t
	    | Define of string * string list * expr_t
	    | Atom of expr_t
	    | Eq of expr_t * expr_t
	    | Car of expr_t
	    | Cdr of expr_t
	    | Cons of expr_t * expr_t
	    | App of expr_t * expr_t list

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
  | T -> cont "T"
  | Var (s) -> cont s
  | If (p, x, y) ->
     print p (fun sp ->
	      print x (fun sx ->
		       print y (fun sy -> cont ("(if " ^ sp ^ " " ^ sx ^ " " ^ sy ^ ")"))))
  | Quote (e) -> print e (fun se -> cont ("(quote " ^ se ^ ")"))
  | Lambda (args, e) ->
     print e (fun se -> cont ("(lambda (" ^ (slist_to_string args) ^ ") " ^ se ^ ")"))
  | Define (f, args, e) ->
     print e (fun se -> cont ("(define (" ^ f ^ " " ^ (slist_to_string args) ^ ") " ^ se ^ ")"))
  | Atom (e) ->
     print e (fun se -> cont ("(atom " ^ se))
  | Eq (e1, e2) ->
     print e1 (fun se1 ->
	       print e2 (fun se2 -> cont ("(eq " ^ se1 ^ " " ^ se2 ^ ")")))
  | Car (e) ->
     print e (fun se -> cont ("(car " ^ se ^ ")"))
  | Cdr (e) ->
     print e (fun se -> cont ("(cdr " ^ se ^ ")"))
  | Cons (e1, e2) ->
     print e1 (fun se1 ->
	       print e2 (fun se2 -> cont ("(" ^ se1 ^ " . " ^ se2 ^ ")")))
  | App (e, es) ->
     let slst_es = List.map (fun e -> print e id) es in (* print type wo sokubaku. *)
     print e (fun se -> cont ("(" ^ se ^ " " ^ (slist_to_string slst_es)))

(* eval : expr_t -> (string, expr_t) Env.t -> (expr_t -> 'a) -> 'a *)
let rec eval exp env cont = match exp with
    Nil -> cont Nil
  | T -> cont T
  | Var (s) -> cont (Env.get env s)
  | If (p, x, y) ->
     eval p env (fun vp ->
		 if vp = T then eval x env cont else eval y env cont)
  | Quote (e) -> cont e
  | Lambda (args, e) -> cont (Lambda (args, e))
  | Define (f, args, e) -> cont (Define (f, args, e))
  | Atom (e) ->
     eval e env (fun ve -> if ve = Nil then cont T else cont Nil)
  | Eq (e1, e2) ->
     eval e1 env (fun ve1 ->
		  eval e2 env (fun ve2 -> cont (if ve1 = ve2 then T else Nil)))
  | Car (e) ->
     eval e env (fun ve ->
		 begin
		   match ve with
		     Cons (e1, e2) -> cont e1
		   | _ -> failwith "Not pair for car"
		 end)
  | Cdr (e) ->
     eval e env (fun ve ->
		 begin
		   match ve with
		     Cons (e1, e2) -> cont e2
		   | _ -> failwith "Not pair for cdr"
		 end)
  | Cons (e1, e2) ->
     eval e1 env (fun ve1 ->
		  eval e2 env (fun ve2 -> cont (Cons (ve1, ve2))))
  | App (f, es) ->
     eval f env (fun vf ->
		 begin
     		   match vf with
		     Lambda (args, e) ->
		     let env2 = List.fold_right2 (fun a e env' -> Env.add env' a e) args es env in
		     eval e env2 cont
		   | _ -> failwith "cannot apply for not-function"
		 end)

(* loop : expr_t list -> (string, expr_t) Env.t -> (string -> 'a) -> 'a *)
let rec loop exprs env cont = match exprs with
    [] -> cont ""
  | x :: xs ->
     eval x env (fun ve ->
		 let sline = print ve id in
		 begin
		   match ve with
		     Define (f, args, e) ->
		     let env2 = Env.add env f (Lambda (args, e)) in
		     loop xs env2 (fun s -> cont (sline ^ "; " ^ s))
		   | _ -> loop xs env (fun s -> cont (sline ^ "; " ^ s))
		 end)

let go program = loop program Env.empty print_endline

let e1 = [Define ("my-cons", ["a"; "d"], Lambda (["f"], App (Var "f", [Var "a"; Var "d"])))]
