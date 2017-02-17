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

app_rule :: FsRule -> Grammer -> [First_t] -> First_t -> [First_t]
app_rule r g fs f = update_f f' fs2
    where (f', fs2) = r g fs f

map_app_rule :: FsRule -> Grammer -> [First_t] -> [First_t]
map_app_rule r g fs = h fs fs
    where h :: [First_t] -> [First_t] -> [First_t]
          h []       fs' = fs'
          h (f : fs) fs' = h fs (app_rule r g fs' f)

fs_rules :: [FsRule]
fs_rules = [fs_rule1, fs_rule2]

apps :: [FsRule] -> Grammer -> [First_t] -> [First_t]
apps []       g fs = fs
apps (r : rs) g fs = apps rs g (map_app_rule r g fs)

make_firsts :: Grammer -> [First_t]
make_firsts g = map (\t -> assoc [t] fs') ts
    where ts' = map fst g
          ts = unduplicate ts'
          fs = map (\t -> ([t], [])) ts
          fs' = apps fs_rules g fs
