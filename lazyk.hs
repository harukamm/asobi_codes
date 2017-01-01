-- LazyK interpreter
data Expr = App Expr Expr | I | K | S deriving Show

-- interpreter
apply :: Expr -> Expr -> Expr
apply I x = x
apply (App K x) y = x
apply (App (App S x) y) z = apply (apply x z) (apply y z)
apply f x = App f x

eval :: Expr -> Expr
eval (App x y) = apply (eval x) (eval y)
eval x = x

{- 1. expr := 'i' | 's' | 'k' | '`' expr expr -}
expr :: String -> [(Expr, String)]
expr ('`' : s1) = case (expr s1) of
                   [] -> []
                   [(e1, s1)] ->
                       case (expr s1) of
                         [] -> []
                         [(e2, s2)] -> [(App e1 e2, s2)]
expr ('i' : s) = [(I, s)]
expr ('s' : s) = [(S, s)]
expr ('k' : s) = [(K, s)]
expr _         = []

{- 2. isk := 'I' | 'S' | 'K'
      expr' := isk | expr' isk | '(' expr' ')' -}
many :: (String -> [(Expr, String)]) -> String -> [([Expr], String)]
many p s = case (p s) of
             [] -> [([], s)]
             [(e, ss)] ->
                      case (many p ss) of
                        [] -> [([e], ss)]
                        [(es, s')] -> [(e : es, s')]

expr_h' :: String -> [(Expr, String)]
expr_h' ('(' : s) = case (expr' s) of
                      [(e, ')' : ss)] -> [(e, ss)]
                      _ -> []
expr_h' ('I' : s) = [(I, s)]
expr_h' ('S' : s) = [(S, s)]
expr_h' ('K' : s) = [(K, s)]
expr_h' _         = []

expr' :: String -> [(Expr, String)]
expr' s = case (many expr_h' s) of
            [(e : elst, ss)] -> [(exp, ss)]
                where exp = foldl (\t -> \ex -> App t ex) e elst
            _ -> []
{- expr_h' と expr' の定義を一つにまとめると、左結合性が保たれず、
   結合性がごっちゃになるのでだめ。例えば、SII が S(II) になっちゃう -}

-- iriguchi
lazyk1 :: String -> Expr
lazyk1 s = case (expr s) of
             [] -> error ""
             [(e, [])] -> e
             [(e, s)] -> error s

lazyk2 :: String -> Expr
lazyk2 s = case (expr' s) of
            [] -> error ""
            [(e, [])] -> e
            [(e, s)] -> error s

hw :: String
hw = "`k``s``si`k```s``sss```s``s`ks`ssi``ss`ki``s`ksk`k``s``si`k```ss``s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``s``sss``s``sss``ss`ki``s`ksk`k``s``si`k```s``ss```ssi``ss`ki``ss`ki``s`ksk`k``s``si`k```s``si``ss``s``sss``ss`ki``ss```ss``ssi``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``ss``ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss```ss`ss``ss`ki``s`ksk`k`k```sii```sii``s``s`kski"

hw_expr :: Expr
hw_expr = lazyk1 hw

hw_expr' :: Expr
hw_expr' = eval hw_expr

ch256 :: String
ch256 = "SII(SII(S(S(KS)K)I))"

ch256_expr :: Expr
ch256_expr = lazyk2 ch256

ch256_expr' :: Expr
ch256_expr' = eval ch256_expr

main = print ch256_expr >>= const (print ch256_expr')