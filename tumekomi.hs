-- Hajimete no Haskell
-- 2016-10-29

sum1 :: Num a => [a] -> a
sum1 [] = 0
sum1 (x : xs) = x + sum1 xs

last' :: [a] -> a
last' xs = head $ reverse xs

last'' :: [a] -> a
last'' xs = xs !! (length xs - 1)

main = do
  let i = sum1 [1..5]
  print i
  let n = a `div` length xs
         where a = 10
               xs = [1, 2, 3, 4, 5]
  print n
  let lst = [5, 6, 7, 8, 9]
  print (last' lst)
  print (last' lst)
