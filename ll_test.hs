import LL

ns1 :: [Int]
ns1 = [1, 5, 3, 10, -1]

ns2 :: [Int]
ns2 = [2, 2, 2, 2]

g1 :: Grammer
g1 = [(NTerm "E",  [NTerm "T", NTerm "E'"]),
      (NTerm "E'", [Term "+", NTerm "T", NTerm "E'"]),
      (NTerm "E'", [Null]),
      (NTerm "T",  [NTerm "F", NTerm "T'"]),
      (NTerm "T'", [Term "*", NTerm "F", NTerm "T'"]),
      (NTerm "T'", [Null]),
      (NTerm "F",  [Term "(", NTerm "E", Term ")"]),
      (NTerm "F",  [Term "id"])]

main = do print (opcons 1 ns1)
          print (opcons 2 ns2)
          print (unduplicate ns2)
          print (append_set [1, 5, 7] [3, 5, 7, 9])