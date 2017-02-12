import LL

g1 :: Grammer
g1 = [(NTerm "E",  [NTerm "T", NTerm "E'"]),
      (NTerm "E'", [Term "+", NTerm "T", NTerm "E'"]),
      (NTerm "E'", [Null]),
      (NTerm "T",  [NTerm "F", NTerm "T'"]),
      (NTerm "T'", [Term "*", NTerm "F", NTerm "T'"]),
      (NTerm "T'", [Null]),
      (NTerm "F",  [Term "(", NTerm "E", Term ")"]),
      (NTerm "F",  [Term "id"])]

main = return ()