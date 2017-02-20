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

g2 :: Grammer
g2 = [(NTerm "E", [NTerm "E", Term "+", NTerm "B"]),
      (NTerm "E", [NTerm "B"]),
      (NTerm "B", [Term "1"])]

fs_g1 :: [First_t]
fs_g1 = make_firsts g1

fs_g2 :: [First_t]
fs_g2 = make_firsts g2

fo_g1 :: [Follow_t]
fo_g1 = make_follows g1

fo_g2 :: [Follow_t]
fo_g2 = make_follows g2

main = do print (opcons 1 ns1)
          print (opcons 2 ns2)
          print (unduplicate ns2)
          print (append_set [1, 5, 7] [3, 5, 7, 9])
          print (canbe_null (NTerm "E'") g1)
          print (canbe_null (NTerm "E") g1)
          print fs_g1
          print fs_g2
          print fo_g1
          print fo_g2
