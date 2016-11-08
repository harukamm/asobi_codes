-- 'Chapter8: Parser'
-- 20116-11-03
import Prelude hiding (return, (>=), until)
import Data.Char

type Parser a = String -> [(a, String)]

return :: a -> Parser a
return v = \inp -> [(v, inp)]

failure :: Parser a
failure = \inp -> []

item :: Parser Char
item = \inp -> case inp of
                [] -> []
                x : xs -> [(x, xs)]

parse :: Parser a -> String -> [(a, String)]
parse p = \inp -> p inp

(>=) :: Parser a -> (a -> Parser b) -> Parser b 
p >= f = \inp -> case (parse p inp) of
                  [] -> []
                  [(v, rest)] -> (f v) rest

(+++) :: Parser a -> Parser a -> Parser a
p1 +++ p2 = \inp -> case (parse p1 inp) of
                   [] -> parse p2 inp
                   [(v, rest)] -> [(v, rest)]

sat :: (Char -> Bool) -> Parser Char
sat p = item >= \x -> if p x then return x else failure

digit :: Parser Char
digit = sat isDigit

lower :: Parser Char
lower = sat isLower

upper :: Parser Char
upper = sat isUpper

letter :: Parser Char
letter = sat isAlpha

alphanum :: Parser Char
alphanum = sat isAlphaNum

char :: Char -> Parser Char
char x = sat (==x)

string :: String -> Parser String
string [] = return []
string (x : xs) = char x >= \x ->
                  (string xs) >= \xs ->
                  return (x : xs)

string2 :: String -> Parser String
string2 [] = return []
string2 (x : xs) = char x >= const
                   (string2 xs) >= const
                   return (x : xs)

many :: Parser a -> Parser [a]
many p = many1 p +++ return []
many1 :: Parser a -> Parser [a]
many1 p = p >= \v ->
          many p >= \vs ->
          return (v : vs)

ident :: Parser String
ident = lower >= \x ->
        many alphanum >= \xs ->
        return (x : xs)

nat :: Parser Int
nat = many1 digit >= \xs ->
      return (read xs)

space :: Parser ()
space = many (sat isSpace) >= const
        (return ())

token :: Parser a -> Parser a
token p = space >= const
          p >= \v ->
          space >= const
          (return v)

identifier :: Parser String
identifier = token ident

natural :: Parser Int
natural = token nat

symbol :: String -> Parser String
symbol xs = token (string xs)

expr :: Parser Int
expr = term >= \t ->
       (symbol "+" >= const
        expr >= \e ->
        return (t + e)) +++ return t
term :: Parser Int
term = factor >= \f ->
       (symbol "*" >= const
        term >= \t ->
        return (f * t)) +++ return f
factor :: Parser Int
factor = (symbol "(" >= const
          expr >= \e ->
          symbol ")" >= const
          (return e)) +++ natural

eval :: String -> Int
eval xs = case parse expr xs of
            [(n, [])] -> n
            [(n, out)] -> error ("unused input " ++ out)
            [] -> error ("invalid input")

-- === exercise 8.10 ==================
-- 1
int :: Parser Int
int = (symbol "-" >= const
       natural >= \n -> return (-n)) +++ natural

-- 2
until :: Char -> Parser Char
until c = \inp -> case inp of
                    [] -> []
                    x : xs -> if x == c then [(c, xs)] else until c xs

comment :: Parser ()
comment = symbol "--" >= const
          (until '\n') >= const
          (return ())

comment' :: Parser ()
comment' = symbol "--" >= const
           (many (sat (/= '\n'))) >= const
           (char '\n') >= const
           (return ())
-- 3, 4, 5
-- 8
expr8 :: Parser Int
expr8 = (expr8 >= \e ->
         symbol "-" >= const
         factor8 >= \n ->
         (return (e - n))) +++ factor8

factor8 :: Parser Int
factor8 = natural +++
          (symbol "(" >= const
           expr8 >= \e ->
           symbol ")" >= const
           (return e))

expr8' :: Parser Int
expr8' = factor8' >= \n ->
          (many (symbol "-" >= const
                 factor8') >= \ns ->
           return (foldl (-) n ns))

factor8' :: Parser Int
factor8' = natural +++
           (symbol "(" >= const
            expr8' >= \e ->
            symbol ")" >= const
            (return e))

-- 6, 7
expr7' :: Parser Int
expr7' = term7 >= \t ->
            many (symbol "-" >= const
                  term7) >= \ns ->
           return (foldl (-) t ns)

expr7 :: Parser Int
expr7 = expr7'
        +++
        term7 >= \t ->
          ((symbol "+") >= const
            expr7 >= \e ->
            return (t + e))
          +++ (return t)

term7' :: Parser Int
term7' = power7 >= \p ->
         many (symbol "/" >= const
               power7) >= \ns ->
         return (foldl div p ns)

term7 :: Parser Int
term7 = term7'
        +++
        power7 >= \p ->
          ((symbol "*") >= const
            term7 >= \t ->
            return (p * t))
          +++ (return p)

power7 :: Parser Int
power7 = factor7 >= \f ->
          ((symbol "^") >= const
           power7 >= \p ->
           (return (f ^ p))) +++ return f

factor7 :: Parser Int
factor7 = natural +++
          ((symbol "(") >= const
            expr7 >= \e ->
            (symbol ")") >= const
            (return e))

-- === example ========================
exa :: Parser (Char, Char)
exa = item >= \x ->
          item >= const 
          item >= \y -> return (x, y)

p1 :: Parser [Int]
p1 = symbol "[" >= const
     natural >= \n ->
     many (symbol "," >= const
           natural) >= \ns ->
     symbol "]" >= const
     (return (n : ns))

main = do
  print "hogehoge"
  print $ parse (item +++ return 'd') "abc"
  print $ parse digit "123"
  print $ parse (string "a") "abcd"
  print $ (many digit) "123abc"
  print $ parse ident "abc def"
  print $ parse nat "123abc"
  print $ parse space " abc"
  print $ parse p1 " [ 1, 2,3, 7]"
  print $ eval "2  * 3 + 4"
  print $ parse comment' "-- xs \nxs"
  print $ parse expr8' "(2 - 3 - 1) - 5"
  print $ parse expr7 "1 + 5 ^ 2 * 1 + 10 / 5 * 2"
  print $ parse expr7 "1 * 2 / 2 / 1"
  print $ parse expr7 "10 / 2 * 5 ^ 2 + 1 - 1 -1"
  print $ parse expr7 "1+2"
