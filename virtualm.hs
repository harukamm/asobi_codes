import Prelude hiding ((>=), until)
import Data.Char
import Control.Applicative hiding (Const, many)
import Control.Monad (liftM, ap)

data Parser a = P (String -> [(a, String)])

parse :: Parser a -> String -> [(a, String)]
parse (P p) = \inp -> p inp

instance Functor Parser where
  -- fmap :: (a -> b) -> f a -> f b
  fmap f p = P $ \inp -> case (parse p inp) of
                      [] -> []
                      [(v, rest)] -> [(f v, rest)]

instance Applicative Parser where
  -- pure :: a -> f a
  pure v = P $ \inp -> [(v, inp)]
  -- (<*>) :: f (a -> b) -> f a -> f b
  p1 <*> p2 = P $ \inp -> case (parse p1 inp) of
                      [] -> []
                      [(f, rest)] -> parse (fmap f p2) rest

instance Monad Parser where
  return v = P $ \inp -> [(v, inp)]
  p >>= f = P $ \inp -> case (parse p inp) of
                      [] -> []
                      [(v, inp)] -> parse (f v) inp

(+++) :: Parser a -> Parser a -> Parser a
p1 +++ p2 = P $ \inp -> case (parse p1 inp) of
                      [] -> parse p2 inp
                      [(v, rest)] -> [(v, rest)]

failure :: Parser a
failure = P $ \inp -> []

item :: Parser Char
item = P $ \inp -> case inp of
                [] -> []
                x : xs -> [(x, xs)]

sat :: (Char -> Bool) -> Parser Char
sat p = do x <- item
           if p x then return x else failure

upper :: Parser Char
upper = sat isUpper

char :: Char -> Parser Char
char x = sat (==x)

string :: String -> Parser String
string [] = return []
string (x : xs) = do x <- char x
                     xs <- string xs
                     return (x : xs)

many :: Parser a -> Parser [a]
many p = many1 p +++ return []
many1 :: Parser a -> Parser [a]
many1 p = do v <- p
             vs <- many p
             return (v : vs)

space :: Parser ()
space = do many $ sat isSpace
           return ()

token :: Parser a -> Parser a
token p = do space
             v <- p
             space
             return v

symbol :: String -> Parser String
symbol xs = token (string xs)

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
balance (x : []) = Leaf x
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
  deriving (Show)

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
rmdups (x : xs) = filter (/= x) (rmdups xs)

substs :: Prop -> [Subst]
substs p = map (zip vs) (bools $ length vs)
    where vs = rmdups (vars p)

isTaut :: Prop -> Bool
isTaut p = and [eval s p | s <- substs p]

-- 6.
-- == Prop Parser =====================
{-
  equ := impl '<->' equ | impl
  impl := andor '->' impl | anor
  andor := andor '&&' nots
         | andor '||' nots
         | nots
  nots := 'not' factor | factor
  factor := '(' equ ')' | cvar
  cvar := 'True' | 'False' | 'A' ... 'Z'
-}
equ :: Parser Prop
equ = do l <- impl
         (do symbol "<->"
             r <- equ
             return $ Eq l r) +++ return l

impl :: Parser Prop
impl = do l <- andor
          (do symbol "->"
              r <- impl
              return $ Imply l r) +++ return l
{-
andor :: Parser Prop
andor = do l <- nots
           ((do rs <- many (do symbol "&&"
                               nots)
                rs' <- many (do symbol "||"
                                nots)
                return $ foldl Or (foldl And l rs) rs')
            +++
            (do rs <- many (do symbol "||"
                               nots)
                rs' <- many (do symbol "&&"
                                nots)
                return $ foldl And (foldl Or l rs) rs')  
            +++ (return l))
-}
andor :: Parser Prop
andor = do l <- nots
           (do tms <- many (do sym <- (symbol "&&" +++ symbol "||")
                               t <- nots
                               return (sym, t))
               return (foldl (\tms' (sym, t) -> if sym == "&&" then And tms' t else Or tms' t) l tms))
-- fixlleft
{-
andor :: Parser Prop
andor = do l <- nots
           ((do symbol "&&"
                r <- andor
                return $ And l r)
            +++
            (do symbol "||"
                r <- andor
                return $ Or l r)
            +++
            return l)
-}
nots :: Parser Prop
nots = factor +++
       do symbol "not"
          f <- factor
          return $ Not f
factor :: Parser Prop
factor = cvar +++
         do symbol "("
            e <- equ
            symbol ")"
            return e
cvar :: Parser Prop
cvar = (symbol "True" >>= const (return $ Const True))
       +++
       (symbol "False" >>= const (return $ Const False))
       +++
       (token (sat isUpper) >>= \v -> return $ Var v)
proper :: String -> String 
proper = \inp -> case (parse equ inp) of
                        [] -> "error"
                        [(v, x : xs)] -> show v ++ " cannot parse: " ++ (x : xs)
                        [(v, [])] -> show v
-- ====================================
-- 7.
-- kasou mashine
data Expr = Val Int
          | Add Expr Expr
          | Mult Expr Expr

type Cont = [Op]
data Op = EVALA Expr | EVALM Expr | ADD Int | MULT Int

evalvm :: Expr -> Cont -> Int
evalvm (Val n) c = execvm c n
evalvm (Add e1 e2) c = evalvm e1 (EVALA e2 : c)
evalvm (Mult e1 e2) c = evalvm e1 (EVALM e2 : c)

execvm :: Cont -> Int -> Int
execvm [] n = n
execvm (EVALA e : c) n = evalvm e (ADD n : c)
execvm (EVALM e : c) n = evalvm e (MULT n : c)
execvm (ADD i : c) n = execvm c (i + n)
execvm (MULT i : c) n = execvm c (i * n)

valuevm :: Expr -> Int
valuevm es = evalvm es []

ex1 :: Expr
ex1 = Add (Add (Val 1) (Mult (Val 2) (Val 2))) (Mult (Val 5) (Val 2))

-- 8.
{-
instance Functor [] where
  fmap = map

instance Applicative [] where
  pure x = [x]
  fs <*> xs = [f x | f <- fs, x <- xs]

instance Monad [] where
  --return = \a -> [a]
  xs >>= f = [x' | x <- xs, x' <- f x]
-}
main = do print (proper "A -> B <-> C") -- (A && B) || C
          print (proper "A && B || C && B || A") -- ((((A & B) || C) && B) || A)
          print $ valuevm ex1
