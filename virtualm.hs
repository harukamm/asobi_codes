import Prelude hiding ((>=), until)
import Data.Char

-- type declation is invalid.
data Parser a = P (String -> [(a, String)])

parse :: Parser a -> String -> [(a, String)]
parse (P p) = \inp -> p inp

instance Monad Parser where
  return v = P (\inp -> [(v, inp)])
  p >>= f = P (\inp -> case (parse p inp) of
                      [] -> []
                      [(v, inp)] -> parse (f v) inp)

-- 1.
data Nat = Zero | Succ Nat

add :: Nat -> Nat -> Nat
add Zero n = n
add (Succ m) n = Succ (add m n)

mult :: Nat -> Nat -> Nat
mult Zero n = Zero
mult (Succ m) n = add n (mult m n)

-- 2.
data Tree = Leaf Int | Node Tree Int Tree

occurs :: Int -> Tree -> Bool
occurs n (Leaf m) = n == m
occurs n (Node l m r)
  | n == m      = True
  | n < m       = occurs n l
  | otherwise   = occurs n r

-- if n == m then True else if n < m then occurs n l else occurs n r
-- if cmp == EQ then True else if cmp == LT then (occurs n l) else (occurs n r) where cmp = compare n m
-- (doesn't need m after calclating cmp.)

{-
data Ordering = LT | EQ | GT
compare :: Ord a => a -> a -> Ordering
compare a b = if a < b then LT
              else if a == b then EQ else GT
-}

-- 3.
cnt_leaf :: Tree -> Int
cnt_leaf (Leaf _) = 1
cnt_leaf (Node l _ r) = (cnt_leaf l) + (cnt_leaf r)

is_balanced :: Tree -> Tree -> Bool
is_balanced tr1 tr2 = abs (diff) <= 1
    where diff = (cnt_leaf tr1) - (cnt_leaf tr2)

-- 4.
balance :: [Int] -> Tree
balance (x : xs) = Node (balance xs1) x (balance xs2)
  where mid = length xs `div` 2
        (xs1, xs2) = splitAt mid xs

-- 5.
data Prop = Const Bool
          | Var Char
          | Not Prop
          | And Prop Prop
          | Or Prop Prop
          | Imply Prop Prop
          | Eq Prop Prop

type Assoc k v = [(k, v)]

find :: Eq k => k -> Assoc k v -> v
find k t = head [v | (k', v) <- t, k == k']
-- if k == t then v else (find k ts)

type Subst = Assoc Char Bool

eval :: Subst -> Prop -> Bool
eval _ (Const b) = b
eval t (Var x) = find x t
eval t (Not p) = not $ eval t p
eval t (And p1 p2) = (eval t p1) && (eval t p2)
eval t (Or p1 p2) = (eval t p1) || (eval t p2)
eval t (Imply p1 p2) = (eval t p1) <= (eval t p2)
eval t (Eq p1 p2) = eval t p1 == eval t p2

vars :: Prop -> [Char]
vars (Const _) = []
vars (Var x) = [x]
vars (Not p) = vars p
vars (And p1 p2) = vars p1 ++ vars p2
vars (Or p1 p2) = vars p1 ++ vars p2
vars (Imply p1 p2) = vars p1 ++ vars p2
vars (Eq p1 p2) = vars p1 ++ vars p2

bools :: Int -> [[Bool]]
bools 0 = [[]]
bools n = map (True:) bss ++ map (False:) bss
    where bss = bools (n - 1)

rmdups :: Eq a => [a] -> [a]
rmdups [] = []
rmdups (x : xs) = maybe_ins x (rmdups xs)
    where maybe_ins a lst = if elem a lst then lst else (a : lst)

substs :: Prop -> [Subst]
substs p = map (zip vs) (bools $ length vs)
    where vs = rmdups (vars p)

isTaut :: Prop -> Bool
isTaut p = and [eval s p | s <- substs p]

-- 6.

-- 7.
-- kasou mashine
data Expr = Val Int
          | Add Expr Expr
          | Mult Expr Expr

type Cont = [Op]
data Op = EVAL Expr | ADD Int | MULT Int
{-
eval :: Expr -> Cont -> Int
eval (Val n) c = exec c n
eval (Add e1 e2) c = eval e1 (EVAL e2 : c)
eval (Mult e1 e2) c = eval ...

exec :: Cont -> Int -> Int
exec [] n = n
exec (EVAL e : c) n = eval e ...
exec (ADD i : c) n = exec c (i + n)
exec (MULT i : c) n = exec c (i * n)
-}
-- 8.

main = do print "hoge"
