When a variable is repeated, an error message is displayed:

  $ dune build
  File "dune-workspace", lines 6-7, characters 3-41:
  6 |    (VARIABLE value1)
  7 |    (VARIABLE value2))))
  Error: Variable VARIABLE is specified several times
  [1]
