(* from_ascii : int -> char *)
let from_ascii = Char.chr

(* to_ascii : char -> int *)
let to_ascii = Char.code

(* ascii_plus : char -> int -> string *)
let ascii_plus c n =
  (to_ascii c) + n
  |> from_ascii
  |> String.make 1

let test1 = ascii_plus 'a' 5 = "f"
let test2 = ascii_plus 'A' 10 = "K"
let test3 = ascii_plus '0' 10 = ":"

(* to_sym : int -> string *)
let to_sym n =
  if n < 0 then (raise Not_found)
  else if n < 10 then string_of_int n
  else if n < 36 then ascii_plus 'a' (n - 10)
  else if n < 62 then ascii_plus 'A' (n - 36)
  else (raise Not_found)

(* returns string which is base m number of a decimal numeral, n *)
(* itoa : int -> int -> string *)
let itoa n m =
  let rec h n' acc =
    if 0 < n'
    then h (n' / m) ((to_sym (n' mod m)) ^ acc)
    else acc
  in h n ""

let test1 = itoa 100 16 = "64"
let test2 = itoa 10 26 = "a"
let test3 = itoa 26 26 = "10"

(* from_sym : char -> int *)
let from_sym c =
  let btw x1 x x2 = x1 <= x && x <= x2 in
  let cd = to_ascii c in
  if btw '0' c '9' then cd - (to_ascii '0')
  else if btw 'a' c 'z' then cd - (to_ascii 'a') + 10
  else if btw 'A' c 'z' then cd - (to_ascii 'A') + 36
  else (raise Not_found)

(* pow : int -> int -> int *)
let rec pow n m =
  if m <= 0 then 1
  else n * (pow n (m - 1))

(* to_clst : string -> char list *)
let rec to_clst s =
  let len = String.length s in
  if len <= 0 then []
  else 
    let hd = String.get s 0 in
    let tl = String.sub s 1 (len - 1) in
    hd :: (to_clst tl)

(* strtol : string -> int -> int *)
let strtol s m =
  let rec h lst x acc = match lst with
    | [] -> acc
    | c :: cs ->
      let acc' = acc + (from_sym c) * (pow m x) in
      h cs (x + 1) acc'
  in
  let rev_clst = List.rev (to_clst s) in
  h rev_clst 0 0

