-- LazyK interpreter
data Expr = App Expr Expr | I | K | S | Succ | Nat Int deriving Show

-- interpreter
p :: Expr -> String
p I           = "i"
p S           = "s"
p K           = "k"
p (App e1 e2) = "`" ++ p e1 ++ p e2
p (Nat n)     = show n
p Succ        = "suc "

apply :: Expr -> Expr -> Expr
apply I x = x
apply (App K x) y = x
apply (App (App S x) y) z = apply (apply x z) (apply y z)
apply Succ (Nat i) = Nat (i + 1)
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

iriguchi :: (String -> [(a, String)]) -> String -> a
iriguchi p s = case (p s) of
                 [] -> error "failed"
                 [(e, [])] -> e
                 [(e, s)] -> error ("cannot parse:" ++ s)

lazyk1 :: String -> Expr
lazyk1 = iriguchi expr

lazyk2 :: String -> Expr
lazyk2 = iriguchi expr'

hw :: String
hw = "`k``s``si`k```s``sss```s``s`ks`ssi``ss`ki``s`ksk`k``s``si`k```ss``s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``s``sss``s``sss``ss`ki``s`ksk`k``s``si`k```s``ss```ssi``ss`ki``ss`ki``s`ksk`k``s``si`k```s``si``ss``s``sss``ss`ki``ss```ss``ssi``ss`ki``s`ksk`k``s``si`k```ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss``ss``ss``ss``s``sss``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```s``si``ss``ss`ki```ss`s``sss``ss`ki``s`ksk`k``s``si`k```s``ss`ki``ss```ss`ss``ss`ki``s`ksk`k``s``si`k```ss```ss`ss``ss`ki``s`ksk`k`k```sii```sii``s``s`kski"

hw_expr :: Expr
hw_expr = lazyk1 hw

hw_expr' :: Expr
hw_expr' = eval hw_expr

--  H   e    l    l    o    ,   W   o    r    l    d    !   \n
--  72  101  108  108  111  44  87  111  114  108  100  33  10

ch256 :: String
ch256 = "SII(SII(S(S(KS)K)I))"

ch256_expr :: Expr
ch256_expr = lazyk2 ch256

ch256_expr' :: Expr
ch256_expr' = eval ch256_expr

-- 参考 wada314.jp/tcf/unlambda/function.html
data Lam = FUN Char Lam | APP Lam Lam | CONST Char | UNLAM Expr deriving (Show)

{- lamb := "^" c lam | "`" lam lam | $ c -}
lamb :: String -> [(Lam, String)]
lamb ('^' : c : s)  = case (lamb s) of
                        [] -> []
                        [(e, ss)] -> [(FUN c e, ss)]
lamb ('`' : s)      = case (lamb s) of
                        [] -> []
                        [(e1, s1)] ->
                            case (lamb s1) of
                              [] -> []
                              [(e2, s2)] -> [(APP e1 e2, s2)]
lamb ('$' : c : s) = [(CONST c, s)]
lamb ('i' : s)     = [(UNLAM I, s)]
lamb ('s' : s)     = [(UNLAM S, s)]
lamb ('k' : s)     = [(UNLAM K, s)]
lamb _             = []

lambda :: String -> Lam
lambda = iriguchi lamb

conv :: Lam -> Lam
conv (FUN f (CONST f'))
     | f == f'          = UNLAM I
     | otherwise        = APP (UNLAM K) (CONST f')
conv (FUN c1 (APP x y)) = APP (APP (UNLAM S) x') y'
    where x'            = conv (FUN c1 x)
          y'            = conv (FUN c1 y)
conv (FUN f (FUN g x))  = conv (FUN f (conv (FUN g x)))
conv (FUN f (UNLAM e))  = APP (UNLAM K) (UNLAM e)
conv t                  = t

toUnlam :: Lam -> Expr
toUnlam t = case (conv t) of
              APP t1 t2 -> apply (toUnlam t1) (toUnlam t2)
              UNLAM e -> e

lamToSK :: String -> Expr
lamToSK = toUnlam . lambda

t1 :: Expr
t1 = lamToSK "^x`$xi" --``si`ki

zero :: Lam
zero = lambda "^s^z$z"

zero' :: Expr
zero' = toUnlam zero

sucn :: Lam
sucn = lambda "^n^s^z`$s``$n$s$z"

sucn' :: Expr
sucn' = toUnlam sucn

one :: Expr
one = apply sucn' zero'

makeN :: Int -> Expr
makeN n = if n <= 0 then zero' else apply sucn' (makeN (n - 1))

chToInt :: Expr -> Int
chToInt ch = case (apply (apply ch Succ) (Nat 0)) of
               Nat n -> n
               _ -> error "arg is not ch"

yconv :: Expr
yconv = lamToSK "^g`^X`$g`$X$X^Y`$g`$Y$Y"

main = print (chToInt (makeN 5))
