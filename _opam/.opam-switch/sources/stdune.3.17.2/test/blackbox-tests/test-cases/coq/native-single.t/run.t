  $ dune build --profile=release --display short --debug-dependency-path @all
  Warning: Coq Language Versions lower than 0.8 have been deprecated in Dune
  3.8 and will be removed in an upcoming Dune version.
  Hint: To disable this warning, add the following to your dune-project file:
  (warnings (deprecated_coq_lang_lt_08 disabled))
        coqdep .basic.theory.d
          coqc Nbasic_foo.{cmi,cmxs},foo.{glob,vo}
          coqc Nbasic_bar.{cmi,cmxs},bar.{glob,vo}

  $ dune build --profile=release --debug-dependency-path @default
  Warning: Coq Language Versions lower than 0.8 have been deprecated in Dune
  3.8 and will be removed in an upcoming Dune version.
  Hint: To disable this warning, add the following to your dune-project file:
  (warnings (deprecated_coq_lang_lt_08 disabled))
  lib: [
    "_build/install/default/lib/base/META"
    "_build/install/default/lib/base/dune-package"
    "_build/install/default/lib/base/opam"
  ]
  lib_root: [
    "_build/install/default/lib/coq/user-contrib/basic/.coq-native/Nbasic_bar.cmi" {"coq/user-contrib/basic/.coq-native/Nbasic_bar.cmi"}
    "_build/install/default/lib/coq/user-contrib/basic/.coq-native/Nbasic_bar.cmxs" {"coq/user-contrib/basic/.coq-native/Nbasic_bar.cmxs"}
    "_build/install/default/lib/coq/user-contrib/basic/.coq-native/Nbasic_foo.cmi" {"coq/user-contrib/basic/.coq-native/Nbasic_foo.cmi"}
    "_build/install/default/lib/coq/user-contrib/basic/.coq-native/Nbasic_foo.cmxs" {"coq/user-contrib/basic/.coq-native/Nbasic_foo.cmxs"}
    "_build/install/default/lib/coq/user-contrib/basic/bar.glob" {"coq/user-contrib/basic/bar.glob"}
    "_build/install/default/lib/coq/user-contrib/basic/bar.v" {"coq/user-contrib/basic/bar.v"}
    "_build/install/default/lib/coq/user-contrib/basic/bar.vo" {"coq/user-contrib/basic/bar.vo"}
    "_build/install/default/lib/coq/user-contrib/basic/foo.glob" {"coq/user-contrib/basic/foo.glob"}
    "_build/install/default/lib/coq/user-contrib/basic/foo.v" {"coq/user-contrib/basic/foo.v"}
    "_build/install/default/lib/coq/user-contrib/basic/foo.vo" {"coq/user-contrib/basic/foo.vo"}
  ]
