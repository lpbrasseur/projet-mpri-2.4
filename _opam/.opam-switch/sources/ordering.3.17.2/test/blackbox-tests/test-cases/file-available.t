Test action %{file-available:<path>} where '<path>' is any path to a file 
within the workspace.

Populate the current workspace with some files and test if they are available.

  $ mkdir bin
  $ touch bin/foo.ml
  $ touch bar.ml

  $ cat > dune-project <<EOF
  > (lang dune 3.0)
  > EOF

  $ cat > dune <<EOF
  > (rule
  >  (alias runtest0)
  >  (action 
  >   (progn
  >    (echo "dune-project available: %{file-available:dune-project}\n")
  >    (echo "bin/foo.ml available: %{file-available:bin/foo.ml}\n")
  >    (echo "bar.ml available: %{file-available:bar.ml}\n"))))
  > EOF

  $ dune build @runtest0
  dune-project available: true
  bin/foo.ml available: true
  bar.ml available: true

Test to see that some files that do not exist are not available.

  $ cat > dune <<EOF
  > (rule
  >  (alias runtest1)
  >  (action
  >   (progn
  >   (echo "baz.ml available: %{file-available:baz.ml}\n")
  >   (echo "bin/test.ml available: %{file-available:bin/test.ml}\n"))))
  > EOF

  $ dune build @runtest1
  baz.ml available: false
  bin/test.ml available: false

Test that files generated by rules are recognized as available.

  $ cat > dune <<EOF
  > (rule
  >  (with-stdout-to gen.txt (echo "generated file text")))
  > (rule
  >  (write-file gen1.txt "another generated file")) 
  > (rule
  >  (alias runtest2)
  >  (action
  >   (progn
  >    (echo "gen.txt available: %{file-available:gen.txt}\n")
  >    (echo "gen1.txt available: %{file-available:gen1.txt}\n"))))
  > EOF

  $ dune build @runtest2
  gen.txt available: true
  gen1.txt available: true

Check that %{file-available:<path>} can be successfully used to enable a given
rule. Similar to macro %{read:...} a sub-directory must be used to avoid a
circular dependency due to how fields of "enabled_if" are evaluated.

  $ mkdir x
  $ touch x/file_that_is_available.txt

  $ cat > dune <<EOF
  > (rule
  >  (alias runtest3)
  >  (enabled_if %{file-available:x/file_that_is_available.txt})
  >  (action
  >   (echo "rule successfully enabled")))
  > EOF

  $ dune build @runtest3
  rule successfully enabled

Check that a file path can be used which is also the target of another rule.

  $ rm -f dune
  $ cat > dune <<EOF
  > (rule
  >  (alias runtest4)
  >  (action
  >   (echo "target output.txt available: %{file-available:output.txt}")))
  > (rule
  >  (target output.txt)
  >  (action
  >   (write-file output.txt "file text")))
  > EOF

  $ dune build @runtest4
  target output.txt available: true
