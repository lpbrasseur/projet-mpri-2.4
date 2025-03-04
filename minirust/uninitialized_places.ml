(* You should read and understand active_borrows.ml *fully*, before filling the holes
  in this file. The analysis in this file follows the same structure. *)

open Type
open Minimir

type analysis_results = label -> PlaceSet.t

let go mir : analysis_results =
  (* The set of all places appearing in the MIR code. We are not interesting in initializedness for places
    which are not member of this set. *)
  let all_places =
    let acc =
      Hashtbl.fold
        (fun l _ acc -> PlaceSet.add (PlLocal l) acc)
        mir.mlocals PlaceSet.empty
    in
    Array.fold_left
      (fun acc (i, _) ->
        match i with
        | Ideinit _ | Iif _ | Igoto _ | Ireturn -> acc
        | Icall (_, _, pl, _) -> PlaceSet.add pl acc
        | Iassign (pl, rv, _) -> (
            let acc = PlaceSet.add pl acc in
            match rv with
            | RVplace pl | RVborrow (_, pl) -> PlaceSet.add pl acc
            | RVbinop _ | RVunop _ | RVmake _ | RVunit | RVconst _ -> acc))
      acc mir.minstrs
  in

  (* The set of subplaces of a given place. *)
  let subplaces = Hashtbl.create 7 in
  let () =
    PlaceSet.iter
      (fun pl ->
        let pls = PlaceSet.filter (fun pl_sub -> is_subplace pl_sub pl) all_places in
        Hashtbl.add subplaces pl pls)
      all_places
  in

  (* Effect of initializing a place [pl] on the abstract state [state]: [pl] and all its subplaces
    become initialized. Hence, given that the state is the set of uninitialized places, we remove
    the subplaces [pl] from the abstract state. *)
  let initialize pl state = PlaceSet.diff state (Hashtbl.find subplaces pl) in

  (* This is the dual: we are consuming or deinitiailizing place [pl], so all its subplaces
    become uninitialized, so they are added to [state]. *)
  let deinitialize pl state = PlaceSet.union state (Hashtbl.find subplaces pl) in

  (* Effect of using (copying or moving) a place [pl] on the abstract state [state]. *)
  let move_or_copy pl state =
    if typ_is_copy (typ_of_place mir pl) then state else deinitialize pl state
  in

  (* These modules are parameters of the [Fix.DataFlow.ForIntSegment] functor below. *)
  let module Instrs = struct let n = Array.length mir.minstrs end in
  let module Prop = struct
    type property = PlaceSet.t

    let leq_join p q = if PlaceSet.subset p q then q else PlaceSet.union p q
  end in
  let module Graph = struct
    type variable = int
    type property = PlaceSet.t

    (* Data flow analysis functions for uninitialized places *)

    (* Entry. We have to initialize only parameters of the function *)
    let foreach_root go =
      go mir.mentry
        (Hashtbl.fold
           (fun loc _ uset ->
             match loc with Lparam _ -> initialize (PlLocal loc) uset | _ -> uset)
           mir.mlocals all_places)

    (* Then we have to init/deinit the correct places for each instruction. Special care should be used for right values *)
    let foreach_successor lbl state go =
      match fst mir.minstrs.(lbl) with
      | Iassign (pl, RVplace pl', next) ->
          state |> move_or_copy pl' |> initialize pl |> go next
      | Iassign (pl, RVbinop (_, l1, l2), next) ->
          state |> move_or_copy (PlLocal l2) |> move_or_copy (PlLocal l1) |> initialize pl
          |> go next
      | Iassign (pl, RVunop (_, l), next) ->
          state |> move_or_copy (PlLocal l) |> initialize pl |> go next
      | Iassign (pl, RVmake (_, ll), next) ->
          let state = List.fold_left (fun s l -> move_or_copy (PlLocal l) s) state ll in
          state |> initialize pl |> go next
      | Iassign (pl, _, next) -> state |> initialize pl |> go next
      | Ideinit (l, next) -> state |> deinitialize (PlLocal l) |> go next
      | Igoto next -> go next state
      | Iif (_, lbl1, lbl2) ->
          go lbl1 state;
          go lbl2 state
      | Ireturn -> ()
      | Icall (_, ll, pl, next) ->
          let state = List.fold_left (fun s l -> move_or_copy (PlLocal l) s) state ll in
          state |> initialize pl |> go next
  end in
  let module Fix = Fix.DataFlow.ForIntSegment (Instrs) (Prop) (Graph) in
  fun i -> Option.value (Fix.solution i) ~default:PlaceSet.empty
