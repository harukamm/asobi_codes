import Prelude hiding (return, (>=))
import Parser hiding (expr, expr')

data Expr = App Expr Expr | I | K | S deriving Show

{-
  isk := "I" | "S" | "K"
  expr := isk | expr isk | expr'
  expr' := "(" expr ")"
-}

i :: a -> a
i = \x -> x

k :: a -> b -> a
k = \x -> \y -> x

s :: (a -> b -> c) -> (a -> b) -> a -> c
s = \x -> \y -> \z -> (x z) (y z)

apply :: Expr -> Expr -> Expr
apply I x = x
apply (App K x) y = x
apply (App (App S x) y) z = apply (apply x z) (apply y z)
apply f x = App f x

eval :: Expr -> Expr
eval (App x y) = apply (eval x) (eval y)
eval x = x

isk :: Parser Expr
isk = (symbol "I" >= const (return I))
      +++
      (symbol "S" >= const (return S))
      +++
      (symbol "K" >= const (return K))

expr :: Parser Expr
expr = expr'
       +++
       isk >= (\t ->
       (many (isk +++ expr') >= \es ->
        return (foldl App t es))
       +++ (return t))

expr' :: Parser Expr
expr' = symbol "(" >= const
        expr >= \e ->
        symbol ")" >= const
        (return e)

e1 :: Expr
e1 = fst (head (parse expr "(S K) K K S (K I)"))

main = print e1 >>= const
       -- => App (App (App (App (App S K) K) K) S) (App K I)
       (print (eval e1))
       -- => S