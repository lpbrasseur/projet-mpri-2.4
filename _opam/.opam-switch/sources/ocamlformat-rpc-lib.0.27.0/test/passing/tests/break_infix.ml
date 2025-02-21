let _ =
  get_succs parent |> Sequence.of_list
  |> Sequence.filter ~f:(fun n -> not (equal node n))
  |> Sequence.Generator.of_sequence

let git_clone ~branch ~remote ~output_dir =
  run_and_log
    Cmd.(
      v "git" % "clone" % "--depth" % "1" % "--branch" % branch % remote
      % p output_dir)

let all_6_2char_hex a b c d e f =
  is_2char_hex a
  && is_2char_hex b
  && is_2char_hex c
  && is_2char_hex d
  && is_2char_hex e
  && is_2char_hex f

let pf0 =
  let open Utils.Parallel_folders in
  open_ construct
  |+ misc_stats_folder header
  |+ elapsed_wall_over_blocks_folder header block_count
  |+ elapsed_cpu_over_blocks_folder header block_count
  |+ Span_folder.create header.initial_stats.timestamp_wall block_count
  |+ cpu_usage_folder header block_count
  |+ ( pack_folder
     && foooooooooooooooooooo
     && foooooooooooooooooooo
     && foooooooooooooooooooo )
  |+ tree_folder
     @ foooooooooooooooooooo
     @ foooooooooooooooooooo
     @ foooooooooooooooooooo
  |+ index_folder + foooooooooooooooooooo + foooooooooooooooooooo
     + foooooooooooooooooooo
  |+ gc_folder * foooooooooooooooooooo * foooooooooooooooooooo
     * foooooooooooooooooooo
  |+ disk_folder
  |> seal

 let cmd =
   root
   ^ "_build"
     / "default"
     / Fmt.str "%s serve %d %d &" Sys.argv.(0) i id.id

let _ =
  (a b c) :: (fooo fooooooooo fooo) :: (x y zzzzzzz)
  :: ("aaa" ^ "bbb" ^ "cccccc" ^ "dddddddddd" ^ "eeeeeeeeeeeeee" ^ "ffffffffffffff")
  :: foooooo :: [ffffffffff; ooooooooo]

let _ =
  fooooooooo
  @@ fooooooooooooooo
  @@
  (fun x ->
     foooooooooooooo $ fooooooooooooooooooooo)
  @@
  (fun x ->
     fooooooooooooooo
     $ fooooooooooooooooo
     $ fooooooooooooooooo
     $ fooooooooooooo
     $ (fooo @@ foooooooooooooooooo)
     $ fooooooooooooo
     $ foooooooooooooooooooo )

let _ =
  a
  + b * c
  + d

let _ =
  a
  + b * c
  + d
  + b * c
  + d
  + b * c
  + d
  + b * c
  + d
  + b * c
  + b * c
  + b * c

(* Break infix if followed by let or letop *)

let term =
  Term.ret
  @@ let+ config = Common.config_term
     and+ mode =
       Arg.(
         value
         & pos 0 (some (enum modes)) None
         & info [] ~docv:"ACTION"
             ~doc:
               (Printf.sprintf "The cache-daemon action to perform (%s)"
                  (Arg.doc_alts_enum modes) ))
     in
     (config, mode)

let term =
  Term.ret
  @@
  let config = Common.config_term
  and mode =
    Arg.(
      value
      & pos 0 (some (enum modes)) None
      & info [] ~docv:"ACTION"
          ~doc:
            (Printf.sprintf "The cache-daemon action to perform (%s)"
               (Arg.doc_alts_enum modes) ))
  in
  (config, mode)
