-- "Lazy Evaluation"
-- 2016.12.06
import Prelude hiding (repeat, take, replicate)

-- 1
{--
  1 + (2 * 3)
      ^^^^^^^
  (1 + 2) * (2 + 3)
  ^^^^^^^   ^^^^^^^
  fst (1 + 2, 2 + 3)
  app. cannot reduce 1+2 since fst is a function.
  (\x -> 1 + x) (2 * 3)
  app.          ^^^^^^^
--}

-- 2
{--
  fst (1 + 2, 2 + 3)
--}

-- 3
{--
  mult = \x -> \y -> x * y
  mult 3 4
       = (\x -> \y -> x * y) 3 4
       = (\y -> 3 * y) 4
       = 3 * 4
       = 12
--}

-- 4
fibs :: [Integer]
fibs = 0 : 1 : fibs' 0 1
  where fibs' :: Integer -> Integer -> [Integer]
        fibs' a b = (a + b) : ((fibs' b) $ (a + b))
-- 5
fib :: Int -> Integer
fib n = fibs !! n

-- First Fibonacci number that is larger than 1000.
val :: Integer
val = head [x | x <- fibs, 1000 < x]

-- 6
{--
repeat :: a -> [a]
repeat x = xs where xs = x : xs

take :: Int -> [a] -> [a]
take _ [] = []
take n (x : xs) = if n == 0 then [] else x : take (n - 1) xs

replicate :: Int -> a -> [a]
replicate n = take n . repeat
--}

data Tree a = Leaf | Node (Tree a) a (Tree a) deriving Show

repeat :: a -> Tree a
repeat x = Node (repeat x) x (repeat x)

take :: Int -> Tree a -> Tree a
take _ Leaf = Leaf
take n (Node l v r) = if n == 0 then Leaf else Node ((take $ (n - 1)) l) v ((take $ (n - 1)) r)

replicate :: Int -> a -> Tree a
replicate n = take n . repeat  

tree1 :: Tree Char
tree1 = replicate 2 ':' 

main = print tree1 >>= const
       (print $ val)
