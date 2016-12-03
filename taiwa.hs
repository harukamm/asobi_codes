import Parser(expr)
import Prelude hiding (getLine, putStr, putStrLn) --(return, (>=), until)
import Data.Char

{-
type IO = World -> World
type IO a = World -> (a, World)

getChar :: IO Char
putChar :: Char -> IO ()

return :: a -> IO a
return v = \world -> (v, world)

(>=) :: IO a -> (a -> IO b) -> IO b
f >= g = \world -> case f world of
                    (v, world') -> g v world'
-}

import System.IO hiding (getLine, putStr) 

getCh :: IO Char
getCh  = do hSetEcho stdin False
            c <- getChar
            hSetEcho stdin True
            return c

echo :: IO ()
echo = getChar >>= \c ->
       (putChar '\n') >>= const 
       (putChar c) >>= const
       (putChar '\n')

getLine :: IO String
getLine = getChar >>= \x ->
          if x == '\n' then return []
          else (getLine >>= \xs ->
                return $ x : xs)

putStr :: String -> IO ()
putStr [] = return ()
putStr (x : xs) = putChar x >>= const (putStr xs) 

beep :: IO ()
beep = putStr "\BEL"

cls :: IO ()
cls = putStr "\ESC[2J"

-- postion
type Pos = (Int, Int)

goto :: Pos -> IO ()
goto (x, y) = putStr ("\ESC[" ++ show y ++ ";" ++ show x ++ "H")

writeat :: Pos -> String -> IO ()
writeat p xs = goto p >>= const
               (putStr xs)
--

seqn :: [IO a] -> IO ()
seqn [] = return ()
seqn (a : as) = a >>= const (seqn as)

-- ======================
-- dentaku
-- ======================

box :: [String]
box = ["+---------------+",
       "|               |",
       "+---+---+---+---+",
       "| q | c | d | = |",
       "+---+---+---+---+",
       "| 1 | 2 | 3 | + |",
       "+---+---+---+---+",
       "| 4 | 5 | 6 | - |",
       "+---+---+---+---+",
       "| 7 | 8 | 9 | * |",
       "+---+---+---+---+",
       "| 0 | ( | ) | / |",
       "+---+---+---+---+"]

buttons :: [Char]
buttons = "qcd=123+456-789*0()/" ++ "QCD \ESC\BS\DEL\n"

showbox :: IO ()
showbox = seqn [writeat (1, y) xs | (y, xs) <- zip [1..13] box ]

display :: String -> IO ()
display xs = writeat (3, 2) "             " >>= const
             (writeat (3, 2) (reverse $ take 13 $ reverse xs))

calc :: String -> IO ()
calc xs = display xs >>= const
          getCh >>= \c ->
          (if elem c buttons then process c xs
           else (beep >>= const (calc xs)))

-- actions
process :: Char -> String -> IO ()
process c xs 
  | elem c "qQ\ESC" = quit
  | elem c "dD\BS\DEL" = delete xs
  | elem c "=\n" = eval xs
  | elem c "cC" = clear
  | otherwise = press c xs

quit :: IO ()
quit = goto (1, 14)

delete :: String -> IO ()
delete "" = calc ""
delete xs = calc (init xs)

eval :: String -> IO ()
eval xs = case (Parser.expr xs) of
            [(n, "")] -> calc (show n)
            _ -> (beep >>= const (calc xs))

clear :: IO ()
clear = calc ""

press :: Char -> String -> IO ()
press c xs = calc (xs ++ [c])

run :: IO ()
run = cls >>= (const showbox) >>= const clear

main = do
  hSetBuffering stdout NoBuffering
  run
--  print $ Parser.expr "3 +2*2^2"
