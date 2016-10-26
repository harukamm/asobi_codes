(* 'Binary tree' *)
(* 2016-10-23 *)

type 'a tree_t = Empty
               | Node of 'a tree_t * 'a * 'a tree_t

let tree1 = Node (Empty, "a", Empty)
let tree2 = Node (tree1, "b", Node (Empty, "c", Empty))
let tree3 = Node (tree2, "b", Empty)
let tree4 = Node (Node (Empty, "f", Empty), "f", Node (Empty, "f", Empty))
let tree5 = Node (tree4, "k", Node (Empty, "k", Empty))

(* kuso *)
(* check_bst : 'a tree -> bool *)
let check_bst tree =
  let rec getlst tr =
    match tr with (* flatten *)
      Empty -> []
    | Node (l, v, r) ->
       let (lstl, lstr) = (getlst l, getlst r) in
       if lstl = [] then v :: lstr
       else List.append lstl (v :: lstr)
  in
  let lst = getlst tree in
  let sorted1 = List.sort (fun a b -> if a < b then -1 else 1) lst in
  let sorted2 = List.sort (fun _ _ -> 1) sorted1 in (* List.rev *)
  lst = sorted1 || lst = sorted2

let test1 = check_bst tree1 = true
let test2 = check_bst tree2 = true
let test3 = check_bst tree3 = false
let test4 = check_bst tree4 = true (* not correct *)
let test5 = check_bst tree5 = true (* not correct *)

type order = Desc1 (* max (r) <= v < min (l) *)
           | Desc2 (* max (r) < v <= min (l) *)
           | Asc1  (* max (l) <= v < min (r) *)
           | Asc2  (* max (l) < v <= min (r) *)

let less = fun x y -> x < y
let eqless = fun x y -> x <= y

(* fumei *)
(* check_bst2 : 'a tree_t -> bool *)
let check_bst2 tree =
  (* calc : ('a option * 'a option) -> int ->
            ('a option * 'a option) option -> order -> ('a option * 'a option) *)
  let calc l v r o = match (o, l, r) with
    | (Desc1, (min_l, _), (_, max_r))
    | (Desc2, (min_l, _), (_, max_r)) ->
       let (op1, op2) = if o = Desc1 then (eqless, less) else (less, eqless) in
       begin
	 match (min_l, max_r) with
	   (None, None) -> (Some v, Some v)
	 | (None, Some (maxr)) when op1 maxr v -> (Some maxr, Some v)
	 | (Some (minl), None) when op2 v minl -> (Some v, Some minl)
	 | (Some (minl), Some (maxr)) when op1 maxr v && op2 v minl -> (Some maxr, Some minl)
	 | _ -> raise Not_found
       end
    | (Asc1,  (_, max_l), (min_r, _))
    | (Asc2,  (_, max_l), (min_r, _)) ->
       let (op1, op2) = if o = Asc1 then (eqless, less) else (less, eqless) in
       begin
	 match (max_l, min_r) with
	   (None, None) -> (Some v, Some v)
	 | (None, Some (minr)) when op2 v minr -> (Some v, Some minr)
	 | (Some (maxl), None) when op1 maxl v -> (Some maxl, Some v)
	 | (Some (maxl), Some (minr)) when op1 maxl v && op2 v minr -> (Some maxl, Some minr)
	 | _ -> raise Not_found
       end
  in
  (* inner : 'a tree_t -> Desc -> ('a option * 'a option) *)
  let rec inner tr order =
    match tr with
      Empty -> (None, None)
    | Node (l, v, r) -> calc (inner l order) v (inner r order) order
  in
  let try1 f =
    try let _ = f () in true
    with Not_found -> false   (* not bst. *)
  in
  try1 (fun () -> inner tree Desc1)
  || try1 (fun () -> inner tree Asc1)
  || try1 (fun () -> inner tree Desc2)
  || try1 (fun () -> inner tree Asc2)

let test1 = check_bst2 tree1 = true
let test2 = check_bst2 tree2 = true
let test3 = check_bst2 tree3 = false
let test4 = check_bst2 tree4 = false
let test5 = check_bst2 tree5 = false
