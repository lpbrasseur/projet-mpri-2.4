# 2 "minirust/lexer.mll"
 
  open Lexing
  open Ast_types
  open Parser

  let id_or_keyword =
    let h = Hashtbl.create 17 in
    List.iter (fun (s,k) -> Hashtbl.add h s k)
      ["if", IF; "else", ELSE;
       "while", WHILE; "loop", LOOP; "break", BREAK; "return", RETURN;
       "true", CONSTANT (Cbool true); "false", CONSTANT (Cbool false);
       "let", LET; "fn", FN; "mut", MUT;
       "struct", STRUCT; "where", WHERE;
       "i32", I32; "bool", BOOL;
      ];
    fun s ->
      try Hashtbl.find h s with Not_found -> IDENT s

  let newline lexbuf =
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <-
      { pos with pos_lnum = pos.pos_lnum + 1; pos_bol = pos.pos_cnum }

# 26 "minirust/lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\220\255\222\255\000\000\061\000\136\000\028\000\232\255\
    \233\255\234\255\235\255\236\255\237\255\238\255\239\255\002\000\
    \003\000\031\000\032\000\056\000\248\255\152\000\250\255\033\000\
    \252\255\194\000\002\000\255\255\228\255\223\255\002\000\224\255\
    \231\255\245\255\244\255\242\255\240\255\230\255\045\000\103\000\
    \227\255\013\001\054\000\054\000\042\000\052\000\077\000\095\000\
    \157\000\131\000\089\000\089\000\081\000\159\000\004\000\137\000\
    \097\000\095\000\097\000\107\000\168\000\117\000\225\255\210\000\
    \251\255\252\255\253\255\169\000\165\000\255\255\254\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\035\000\035\000\034\000\035\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\014\000\
    \012\000\026\000\009\000\008\000\255\255\006\000\255\255\004\000\
    \255\255\002\000\001\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\029\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\004\000\004\000\255\255\255\255";
  Lexing.lex_default =
   "\001\000\000\000\000\000\255\255\255\255\255\255\255\255\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \255\255\255\255\255\255\255\255\000\000\255\255\000\000\255\255\
    \000\000\255\255\255\255\000\000\000\000\000\000\030\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\000\000\064\000\
    \000\000\000\000\000\000\255\255\255\255\000\000\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\026\000\027\000\026\000\031\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \026\000\017\000\026\000\003\000\055\000\020\000\019\000\004\000\
    \014\000\013\000\022\000\024\000\009\000\023\000\010\000\021\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\008\000\007\000\016\000\018\000\015\000\036\000\
    \035\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\042\000\034\000\033\000\032\000\028\000\
    \039\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\012\000\006\000\011\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \037\000\040\000\043\000\044\000\045\000\046\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\029\000\047\000\048\000\049\000\050\000\030\000\
    \051\000\052\000\053\000\054\000\056\000\057\000\058\000\059\000\
    \060\000\061\000\062\000\070\000\069\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\066\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\038\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\068\000\000\000\000\000\000\000\
    \002\000\067\000\031\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\000\000\000\000\000\000\
    \000\000\025\000\000\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \000\000\000\000\000\000\000\000\041\000\000\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\065\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\026\000\030\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\026\000\000\000\054\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\015\000\
    \016\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\003\000\017\000\018\000\019\000\023\000\
    \038\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \006\000\039\000\042\000\043\000\044\000\045\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\021\000\046\000\047\000\048\000\049\000\021\000\
    \050\000\051\000\052\000\053\000\055\000\056\000\057\000\058\000\
    \059\000\060\000\061\000\067\000\068\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\063\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\005\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\063\000\255\255\255\255\255\255\
    \000\000\063\000\030\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\255\255\255\255\255\255\
    \255\255\025\000\255\255\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \255\255\255\255\255\255\255\255\041\000\255\255\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\063\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec token lexbuf =
   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 33 "minirust/lexer.mll"
                                 ( newline lexbuf; token lexbuf )
# 213 "minirust/lexer.ml"

  | 1 ->
# 34 "minirust/lexer.mll"
                                 ( token lexbuf )
# 218 "minirust/lexer.ml"

  | 2 ->
let
# 35 "minirust/lexer.mll"
             id
# 224 "minirust/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 35 "minirust/lexer.mll"
                                 ( id_or_keyword id )
# 228 "minirust/lexer.ml"

  | 3 ->
# 36 "minirust/lexer.mll"
                                 ( PLUS )
# 233 "minirust/lexer.ml"

  | 4 ->
# 37 "minirust/lexer.mll"
                                 ( MINUS )
# 238 "minirust/lexer.ml"

  | 5 ->
# 38 "minirust/lexer.mll"
                                 ( STAR )
# 243 "minirust/lexer.ml"

  | 6 ->
# 39 "minirust/lexer.mll"
                                 ( DIV )
# 248 "minirust/lexer.ml"

  | 7 ->
# 40 "minirust/lexer.mll"
                                 ( PERCENT )
# 253 "minirust/lexer.ml"

  | 8 ->
# 41 "minirust/lexer.mll"
                                 ( AMP )
# 258 "minirust/lexer.ml"

  | 9 ->
# 42 "minirust/lexer.mll"
                                 ( EQ )
# 263 "minirust/lexer.ml"

  | 10 ->
# 43 "minirust/lexer.mll"
                                 ( EQEQ )
# 268 "minirust/lexer.ml"

  | 11 ->
# 44 "minirust/lexer.mll"
                                 ( NEQ )
# 273 "minirust/lexer.ml"

  | 12 ->
# 45 "minirust/lexer.mll"
                                 ( LT )
# 278 "minirust/lexer.ml"

  | 13 ->
# 46 "minirust/lexer.mll"
                                 ( LE )
# 283 "minirust/lexer.ml"

  | 14 ->
# 47 "minirust/lexer.mll"
                                 ( GT )
# 288 "minirust/lexer.ml"

  | 15 ->
# 48 "minirust/lexer.mll"
                                 ( GE )
# 293 "minirust/lexer.ml"

  | 16 ->
# 49 "minirust/lexer.mll"
                                 ( LPAREN )
# 298 "minirust/lexer.ml"

  | 17 ->
# 50 "minirust/lexer.mll"
                                 ( RPAREN )
# 303 "minirust/lexer.ml"

  | 18 ->
# 51 "minirust/lexer.mll"
                                 ( LBRA )
# 308 "minirust/lexer.ml"

  | 19 ->
# 52 "minirust/lexer.mll"
                                 ( RBRA )
# 313 "minirust/lexer.ml"

  | 20 ->
# 53 "minirust/lexer.mll"
                                 ( DOT )
# 318 "minirust/lexer.ml"

  | 21 ->
# 54 "minirust/lexer.mll"
                                 ( COMMA )
# 323 "minirust/lexer.ml"

  | 22 ->
# 55 "minirust/lexer.mll"
                                 ( COLON )
# 328 "minirust/lexer.ml"

  | 23 ->
# 56 "minirust/lexer.mll"
                                 ( SEMICOLON )
# 333 "minirust/lexer.ml"

  | 24 ->
# 57 "minirust/lexer.mll"
                                 ( AMPAMP )
# 338 "minirust/lexer.ml"

  | 25 ->
# 58 "minirust/lexer.mll"
                                 ( BARBAR )
# 343 "minirust/lexer.ml"

  | 26 ->
# 59 "minirust/lexer.mll"
                                 ( NOT )
# 348 "minirust/lexer.ml"

  | 27 ->
# 60 "minirust/lexer.mll"
                                 ( ARROW )
# 353 "minirust/lexer.ml"

  | 28 ->
let
# 61 "minirust/lexer.mll"
                       s
# 359 "minirust/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 61 "minirust/lexer.mll"
                                 ( CONSTANT (Ci32 s) )
# 363 "minirust/lexer.ml"

  | 29 ->
let
# 62 "minirust/lexer.mll"
                 id
# 369 "minirust/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 62 "minirust/lexer.mll"
                                 ( LIFETIME id )
# 373 "minirust/lexer.ml"

  | 30 ->
# 63 "minirust/lexer.mll"
                                 ( DERIVECOPY )
# 378 "minirust/lexer.ml"

  | 31 ->
# 64 "minirust/lexer.mll"
                                 ( newline lexbuf; token lexbuf )
# 383 "minirust/lexer.ml"

  | 32 ->
# 65 "minirust/lexer.mll"
                                 ( comment lexbuf.lex_curr_p lexbuf; token lexbuf )
# 388 "minirust/lexer.ml"

  | 33 ->
# 66 "minirust/lexer.mll"
                                 ( EOF )
# 393 "minirust/lexer.ml"

  | 34 ->
# 68 "minirust/lexer.mll"
    ( Error.error (lexbuf.lex_start_p, lexbuf.lex_curr_p) "Integers should be suffixed with 'i32' in MiniRust." )
# 398 "minirust/lexer.ml"

  | 35 ->
# 70 "minirust/lexer.mll"
    ( Error.error (lexbuf.lex_start_p, lexbuf.lex_curr_p) "Lexing error." )
# 403 "minirust/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment start lexbuf =
   __ocaml_lex_comment_rec start lexbuf 63
and __ocaml_lex_comment_rec start lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 73 "minirust/lexer.mll"
         ( () )
# 415 "minirust/lexer.ml"

  | 1 ->
# 74 "minirust/lexer.mll"
         ( comment start lexbuf; comment start lexbuf )
# 420 "minirust/lexer.ml"

  | 2 ->
# 75 "minirust/lexer.mll"
         ( newline lexbuf; comment start lexbuf )
# 425 "minirust/lexer.ml"

  | 3 ->
# 76 "minirust/lexer.mll"
         ( Error.error (start, lexbuf.lex_start_p) "Unterminated comment." )
# 430 "minirust/lexer.ml"

  | 4 ->
# 77 "minirust/lexer.mll"
         ( comment start lexbuf )
# 435 "minirust/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec start lexbuf __ocaml_lex_state

;;

