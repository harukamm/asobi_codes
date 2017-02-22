-- https://ja.wikipedia.org/wiki/LL法
-- https://www.jambe.co.nz/UNI/FirstAndFollowSets.html
module LL where

data Sym = Term String | NTerm String | Null | EOF deriving (Show, Eq)

type Prod = (Sym, [Sym])
type Grammer = [Prod]
type First_t = ([Sym], [Sym])
type FsRule = Grammer -> [First_t] -> First_t -> (First_t, [First_t])
type Follow_t = ([Sym], [Sym])
type FoRule = Grammer -> [Follow_t] -> Follow_t -> (Follow_t, [Follow_t])

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

has_null :: [Sym] -> Bool
has_null = any (Null==)

remove_all :: Sym -> [Sym] -> [Sym]
remove_all x []       = []
remove_all x (y : ys) = if x == y then remove_all x ys else y : (remove_all x ys)

is_whole_term :: [Sym] -> Bool
is_whole_term []            = True
is_whole_term (Term _ : xs) = is_whole_term xs
is_whole_term (_ : xs)      = False

-- ===========================
-- First Sets
-- ===========================
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

fs_rule4 :: FsRule
fs_rule4 g fs ([], set)     = (([], set), fs)
fs_rule4 g fs (x : xs, set) = if not (has_null setx) then ((x : xs, setx), fs)
                              else if xsfs_null
                                   then ((x : xs, opcons Null set), fs)
                                   else ((x : xs, set), fs')
    where (_, setx) = if exist [x] fs then assoc [x] fs else first g fs [x]
          xs_fs = map (\w -> if exist [w] fs then assoc [w] fs else first g fs [w]) xs
          xsfs_null = foldl (\b (_, set) -> (has_null set) && b) True xs_fs
          fs' = update_f ([x], append_set (remove_all Null set) setx) fs

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
first g fs (NTerm x : xs) = fst (fs_rule4 g fs (NTerm x : xs, []))

make_firsts :: Grammer -> [First_t]
make_firsts g = map (\t -> assoc [t] fs') ts
    where ts' = map fst g
          ts = unduplicate ts'
          fs = map (\t -> ([t], [])) ts
          fs' = apps fs_rules g fs

-- ===========================
-- Follow Sets
-- ===========================
take_first :: Grammer -> [Sym] -> First_t
take_first g t = if exist t fs then assoc t fs else f
    where fs = make_firsts g
          f = first g fs t

fo_rule1 :: FoRule
fo_rule1 ((NTerm x, _) : g) fos ([NTerm y], set) =
    if x == y then (([NTerm y], opcons EOF set), fos)
    else (([NTerm y], set), fos)
fo_rule1 g fos f                                 = (f, fos)

fo_rule2 :: FoRule
fo_rule2 g fos ([x], set) = (([x], set), fos'')
    where cs = all_codomain x g
          fos' = foldl
                 (\l w -> case (reverse w) of
                            (Term b) : (NTerm lb) : res ->
                                update_f ([NTerm lb], [Term b]) l
                            (NTerm b) : (NTerm lb) : res ->
                                update_f ([NTerm lb], setb) l
                                    where fb = take_first g [NTerm b]
                                          setb = remove_all Null (snd fb)
                            _ -> l) fos cs
          fos'' = foldl
                  (\l w -> case w of
                             (Term lb) : (Term b) : res ->
                                 update_f ([Term lb], [Term b]) l
                             _ -> l) fos' cs
fo_rule2 g fos f          = (f, fos)

fo_rule3 :: FoRule
fo_rule3 g fos ([x], set) = (([x], set), fos')
    where cs = all_codomain x g
          fos' = foldl (\l w -> case (reverse w) of
                                  (NTerm lb) : res ->
                                      update_f ([NTerm lb], set) l
                                  _ -> l) fos cs
fo_rule3 g fos f          = (f, fos)

fo_rule4 :: FoRule
fo_rule4 g fos ([x], set) = (([x], set), fos')
    where cs = all_codomain x g
          fos' = foldl
                 (\l w -> case (reverse w) of
                            (NTerm b) : (NTerm lb) : res ->
                                if has_null (snd (take_first g [NTerm b]))
                                then update_f ([NTerm lb], set) l
                                else l
                            (Term b) : (NTerm lb) : res ->
                                update_f ([NTerm lb], [Term b]) l
                            _ -> l) fos cs

fo_rules :: [FoRule]
fo_rules = [fo_rule1, fo_rule2, fo_rule3, fo_rule3, fo_rule4, fo_rule3, fo_rule4]

make_follows :: Grammer -> [Follow_t]
make_follows g = fos' --map (\t -> assoc [t] fos') ts
    where ts' = map fst g
          ts = unduplicate ts'
          fos = map (\t -> ([t], [])) ts
          fos' = apps fo_rules g fos