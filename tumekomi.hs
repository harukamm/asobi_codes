-- Hajimete no Haskell
-- 2016-10-29

sum1 :: Num a => [a] -> a
sum1 [] = 0
sum1 (x : xs) = x + sum1 xs

last' :: [a] -> a
last' xs = head $ reverse xs

last'' :: [a] -> a
last'' xs = xs !! (length xs - 1)

init' :: [a] -> [a]
init' xs = reverse $ tail $ reverse xs

init'' :: [a] -> [a]
init'' xs = take (length xs - 1) xs

head' :: [a] -> a
head' (x : xs) = x

length' :: [a] -> Int
length' (x : xs) = 1 + length' xs

zip' :: [a] -> [b] -> [(a, b)]
zip' [] [] = []
zip' (a : as) (b : bs) = (a, b) : zip' as bs

-- halve must not receive any odd-length-list.
-- halve2 :: [a] -> ([a], [a])
-- halve2 xs = splitAt (div xs 2) xs

halve' :: Int -> [a] -> ([a], [a])
halve' half [] = ([], [])
halve' half (x1 : x2 : xs) = if length xs2 + 1 == half then (x1 : xs1, x2 : xs2)
                             else if length xs2 == half then (x1 : x2 : xs1, xs2)
                             else (xs1, x1 : x2 : xs2)
         where (xs1, xs2) = halve' half xs

halve :: [a] -> ([a], [a])
halve xs = halve' (div (length xs) 2) xs

safetail :: [a] -> [a]
safetail [] = []
safetail (x : xs) = xs

safetail' :: [a] -> [a]
safetail' xs = if null xs then [] else tail xs

main = do
  let i = sum1 [1..5]
  print i
  let n = a `div` length xs
         where a = 10
               xs = [1, 2, 3, 4, 5]
  print n
  let lst = [5, 6, 7, 8, 9]
  let lst' = ['5', '6', '7', '8', '9']
  print $ last' lst
  print $ last' lst
  print $ init' lst
  print $ init'' lst
  print $ zip' lst lst'
  print $ halve [1..6]
  -- print $ halve [1..5] -- pattern match error
