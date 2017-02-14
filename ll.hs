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