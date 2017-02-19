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

all_codomain :: Sym -> Grammer -> [[Sym]]
all_codomain x = foldl (\l (y, w) -> if x == y then w : l else l) []

append_set :: Eq a => [a] -> [a] -> [a]
append_set [] l2       = l2
append_set (x : xs) l2 = append_set xs (opcons x l2)

canbe_null :: Sym -> Grammer -> Bool
canbe_null x = any (\(y, w) -> x == y && w == [Null])

add_all_fs :: [First_t] -> First_t -> First_t
add_all_fs []               (t, set) = (t, set)
add_all_fs ((_, set') : fs) (t, set) = add_all_fs fs (t, append_set set' set)

update_f :: First_t -> [First_t] -> [First_t]
update_f (t, set) []                = [(t, set)]
update_f (t, set) ((t', set') : fs) = if t == t'
                                      then update_f (t, append_set set' set) fs
                                      else (t', set') : update_f (t, set) fs

exist :: [Sym] -> [First_t] -> Bool
exist t []             = False
exist t ((t', _) : fs) = (t == t') || (exist t fs)

assoc :: [Sym] -> [First_t] -> First_t
assoc t []               = error "not_found"
assoc t ((t', set) : fs) = if t == t' then (t', set) else assoc t fs

has_null :: [Sym] -> Bool
has_null = any (Null==)

fs_rule1 :: FsRule
fs_rule1 _ fs ([Term x], set) = (f, fs)
    where f = ([Term x], [Term x])
fs_rule1 _ fs f               = (f, fs)

fs_rule2 :: FsRule
fs_rule2 g fs ([x], set) = (f, fs)
    where set' = if canbe_null x g then opcons Null set else set
          f = ([x], set')
fs_rule2 _ fs f          = (f, fs)

fs_rule3 :: FsRule
fs_rule3 g fs ([x], set) = (f, fs)
    where cs = all_codomain x g
          cfs = map (\w -> if exist w fs then assoc w fs else first g fs w) cs
          f = add_all_fs cfs ([x], set)
fs_rule3 _ fs f          = (f, fs)

app_rule :: FsRule -> Grammer -> [First_t] -> First_t -> [First_t]
app_rule r g fs f = update_f f' fs2
    where (f', fs2) = r g fs f

map_app_rule :: FsRule -> Grammer -> [First_t] -> [First_t]
map_app_rule r g fs = h fs fs
    where h :: [First_t] -> [First_t] -> [First_t]
          h []       fs' = fs'
          h (f : fs) fs' = h fs (app_rule r g fs' f)

fs_rules :: [FsRule]
fs_rules = [fs_rule1, fs_rule2, fs_rule3, fs_rule3, fs_rule3]

apps :: [FsRule] -> Grammer -> [First_t] -> [First_t]
apps []       g fs = fs
apps (r : rs) g fs = apps rs g (map_app_rule r g fs)

first :: Grammer -> [First_t] -> [Sym] -> First_t
first g fs []             = ([], [])
first g fs (Null : xs)    = (Null : xs, [])
first g fs (Term x : xs)  = (Term x : xs, [Term x])
first g fs (NTerm x : xs) = (NTerm x : xs, [])

make_firsts :: Grammer -> [First_t]
make_firsts g = map (\t -> assoc [t] fs') ts
    where ts' = map fst g
          ts = unduplicate ts'
          fs = map (\t -> ([t], [])) ts
          fs' = apps fs_rules g fs
