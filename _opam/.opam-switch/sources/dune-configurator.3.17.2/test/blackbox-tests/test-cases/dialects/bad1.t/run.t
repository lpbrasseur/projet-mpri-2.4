Duplicate dialect

  $ dune build
  File "dune-project", lines 9-11, characters 1-74:
   9 |  (name d)
  10 |  (implementation (extension foo2))
  11 |  (interface (extension bar2)))
  Error: dialect "d" is already defined
  [1]
