(* 'Binary tree' *)
(* 2016-10-23 *)

type 'a tree_t = Empty
               | Node of 'a tree_t * 'a * 'a tree_t

type order = Desc (* right-tree < val < left-tree *)
	   | Asc  (* left-tree < val < right-tree *)


