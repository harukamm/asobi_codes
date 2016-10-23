(* 'Binary tree' *)
(* 2016-10-23 *)

type 'a tree_t = Empty
               | Node of 'a tree_t * 'a * 'a tree_t

type order = Desc (* r < v < l *)
	   | Asc  (* l < v < r *)
type pos = Left
	 | Right

let tree1 = Node (Empty, "a", Empty)
let tree2 = Node (tree1, "b", Node (Empty, "c", Empty))
let tree3 = Node (tree2, "b", Empty)

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
  let sorted2 = List.sort (fun _ _ -> -1) sorted1 in (* List.rev *)
  lst = sorted1 || lst = sorted2

let test1 = check_bst tree1 = true
let test2 = check_bst tree2 = true
let test3 = check_bst tree3 = false

