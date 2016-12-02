type storage_t = {
  setItem : string -> string -> unit;
  getItem : string -> string;
  damp : unit -> unit;
}

(* localstorage : storage_t *)
let localstorage
  = (fun () ->
     let storage = ref [] in
     let setItem key value =
       storage := (key, value) :: (!storage) in
     let getItem key =
       List.assoc key (!storage) in
     let damp () =
       List.iter (fun (k, v) ->
		 print_endline ("key: " ^ k ^ ", value: " ^ v)) (!storage) in
     {setItem=setItem; getItem=getItem; damp=damp}) ();;

localstorage.setItem "foo" "bar";;
localstorage.setItem "huga" "hoge";;
localstorage.getItem "foo";;
localstorage.getItem "huga";;
localstorage.damp();;
