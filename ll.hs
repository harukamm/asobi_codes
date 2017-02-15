module LL where

data Sym = Term String | NTerm String | Null | EOF deriving (Show, Eq)

type Prod = (Sym, [Sym])
type Grammer = [Prod]
type First_t = ([Sym], [Sym])
type FsRule = Grammer -> [First_t] -> First_t -> (First_t, [First_t])
type Follow_t = ([Sym], [Sym])

opcons :: Eq a => a -> [a] -> [a]
opcons x xs = if any (x==) xs then xs else x : xs

unduplicate :: Eq a => [a] -> [a]
unduplicate []       = []
unduplicate (x : xs) = opcons x (unduplicate xs)

append_set :: Eq a => [a] -> [a] -> [a]
append_set [] l2       = l2
append_set (x : xs) l2 = append_set xs (opcons x l2)

add_all_fs :: [First_t] -> First_t -> First_t
add_all_fs []               (t, set) = (t, set)
add_all_fs ((_, set') : fs) (t, set) = add_all_fs fs (t, append_set set' set)

update_f :: First_t -> [First_t] -> [First_t]
update_f (t, set) []                = [(t, set)]
update_f (t, set) ((t', set') : fs) = if t == t'
                                      then update_f (t, append_set set' set) fs
                                      else (t', set') : update_f (t, set) fs