import Prelude hiding (return, (>=))
import Parser hiding (expr, expr')

data Expr = App Expr Expr | I | K | S deriving Show

{-
  isk := "i" | "s" | "k"
  expr := isk | "`" expr expr | expr'
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
isk = (symbol "i" >= const (return I))
      +++
      (symbol "s" >= const (return S))
      +++
      (symbol "k" >= const (return K))

expr :: Parser Expr
expr = expr'
       +++
       isk
       +++
       (symbol "`" >= const
        expr >= \e1 ->
        expr >= \e2 ->
        return (App e1 e2))

expr' :: Parser Expr
expr' = symbol "(" >= const
        expr >= \e ->
        symbol ")" >= const
        (return e)

e1 :: Expr
e1 = fst (head (parse expr "`k``s``si`k```s``sss```s``s`ks`ssi``ss`ki``s`ksk`k``s``si`k```ss``s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``s``sss``s``sss``ss`ki``s`ksk`k``s``si`k```s``ss```ssi``ss`ki``ss`ki``s`ksk`k``s``si`k```s``si``ss``s``sss``ss`ki``ss```ss``ssi``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``ss``ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss```ss`ss``ss`ki``s`ksk`k`k```sii```sii``s``s`kski"))

main = print e1 >>= const
       (print (eval e1))