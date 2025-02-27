(* Once you are done writing the code, remove this directive,
   whose purpose is to disable several warnings. *)
[@@@warning "-26-27"]

open Type
open Minimir
open Active_borrows

(* This function computes the set of alive lifetimes at every program point. *)
let compute_lft_sets mir : lifetime -> PpSet.t =
  (* The [outlives] variable contains all the outlives relations between the
    lifetime variables of the function. *)
  let outlives = ref LMap.empty in

  (* Helper functions to add outlives constraints. *)
  let add_outlives (l1, l2) = outlives := add_outlives_edge l1 l2 !outlives in
  let unify_lft l1 l2 =
    add_outlives (l1, l2);
    add_outlives (l2, l1)
  in

  (* First, we add in [outlives] the constraints implied by the type of locals. *)
  Hashtbl.iter
    (fun _ typ -> outlives := outlives_union !outlives (implied_outlives typ))
    mir.mlocals;

  (* Then, we add the outlives relations needed for the instructions to be safe. *)

  (* TODO: generate these constraints by
       - unifying types that need be equal (note that MiniRust does not support subtyping, that is,
         if a variable x: &'a i32 is used as type &'b i32, then this requires that lifetimes 'a and
         'b are equal),
       - adding constraints required by function calls,
       - generating constraints corresponding to reborrows. More precisely, if we create a borrow
         of a place that dereferences  borrows, then the lifetime of the borrow we
         create should be shorter than the lifetimes of the borrows the place dereference.
         For example, if x: &'a &'b i32, and we create a borrow y = &**x of type &'c i32,
         then 'c should be shorter than 'a and 'b.

    SUGGESTION: use functions [typ_of_place], [fields_types_fresh] and [fn_prototype_fresh].
  *)

  (* function that recursively generates all constraints on the lifetimes. f could be outlives or unify. the two following fonctions are just a specification of f *)
  let rec constraint_from_typ f t1 t2 =
    match t1, t2 with
    | Tstruct (_, llft1), Tstruct (_, llft2) -> List.iter2 f llft1 llft2
    | Tborrow (lft1, _, st1), Tborrow (lft2, _, st2) ->
        f lft1 lft2;
        constraint_from_typ f st1 st2
    | _, _ -> ()
  in
  let unify_from_typ = constraint_from_typ unify_lft in
  let add_outlives_from_typ = constraint_from_typ (fun x y -> add_outlives (x, y)) in

  (* helper function for the right value borrow case *)
  let rec add_outlives_borrow_from_deref pl typ =
    add_outlives_from_typ (typ_of_place mir pl) typ;
    match pl with
    | PlLocal l -> ()
    | PlDeref pl' | PlField (pl', _) -> add_outlives_borrow_from_deref pl' typ
  in

  (* the we have to add lifetime constraints for some assignations (where the r-value has some lifetimes) and for function call *)
  Array.iteri
    (fun lbl (instr, _) ->
      match instr with
      | Iassign (pl, RVplace pl', _) ->
          unify_from_typ (typ_of_place mir pl) (typ_of_place mir pl')
      | Iassign (pl, RVborrow (_, pl'), _) ->
          (match typ_of_place mir pl with
          | Tborrow (_, _, typ) -> unify_from_typ typ (typ_of_place mir pl')
          | _ -> assert false);
          add_outlives_borrow_from_deref pl' (typ_of_place mir pl)
      | Iassign (pl, RVmake (str, ll), _) ->
          let typl, typ = fields_types_fresh str in
          let typlloc = List.map (fun l -> typ_of_place mir (PlLocal l)) ll in
          List.iter2 unify_from_typ typl typlloc;
          unify_from_typ (typ_of_place mir pl) typ
      | Icall (str, ll, pl, _) ->
          let typl, typ, lftconstr = fn_prototype_fresh str in
          let typlloc = List.map (fun l -> typ_of_place mir (PlLocal l)) ll in
          List.iter2 unify_from_typ typl typlloc;
          unify_from_typ (typ_of_place mir pl) typ;
          List.iter add_outlives lftconstr
      | _ -> ())
    mir.minstrs;

  (* The [living] variable contains constraints of the form "lifetime 'a should be
    alive at program point p". *)
  let living : PpSet.t LMap.t ref = ref LMap.empty in

  (* Helper function to add living constraint. *)
  let add_living l pp =
    living :=
      LMap.update l
        (fun s -> Some (PpSet.add pp (Option.value s ~default:PpSet.empty)))
        !living
  in

  (* Run the live local analysis. See module Live_locals for documentation. *)
  let live_locals = Live_locals.go mir in

  (* TODO: generate living constraints:
     - Add living constraints corresponding to the fact that liftimes appearing free
       in the type of live locals at some program point should be alive at that
       program point.
     - Add living constraints corresponding to the fact that generic lifetime variables
       (those in [mir.mgeneric_lfts]) should be alive during the whole execution of the
       function.
  *)
  Array.iteri
    (fun lbl _ ->
      (* lifetimes appear free in the type of live locals should be alive *)
      LocSet.iter (* iterating on live locals *)
        (fun l ->
          LSet.iter (* iterating on free lifetimes *)
            (fun lft -> add_living lft (PpLocal lbl))
            (free_lfts (typ_of_place mir (PlLocal l)))
          (* the set of free lifetimes *))
        (live_locals lbl)
      (* the set of live locals *);
      (* generic lifetimes are alive at every point *)
      List.iter (fun lft -> add_living lft (PpLocal lbl)) mir.mgeneric_lfts)
    mir.minstrs;

  (* If [lft] is a generic lifetime, [lft] is always alive at [PpInCaller lft]. *)
  List.iter (fun lft -> add_living lft (PpInCaller lft)) mir.mgeneric_lfts;

  (* Now, we compute lifetime sets by finding the smallest solution of the constraints, using the
    Fix library. *)
  let module Fix = Fix.Fix.ForType (struct type t = lifetime end) (Fix.Prop.Set (PpSet))
  in
  Fix.lfp (fun lft lft_sets ->
      LSet.fold
        (fun lft acc -> PpSet.union (lft_sets lft) acc)
        (Option.value ~default:LSet.empty (LMap.find_opt lft !outlives))
        (Option.value ~default:PpSet.empty (LMap.find_opt lft !living)))

let borrowck mir =
  (* We check initializedness requirements for every instruction. *)
  let uninitialized_places = Uninitialized_places.go mir in
  Array.iteri
    (fun lbl (instr, loc) ->
      let uninit : PlaceSet.t = uninitialized_places lbl in

      let check_initialized pl =
        if PlaceSet.exists (fun pluninit -> is_subplace pluninit pl) uninit then
          Error.error loc "Use of a place which is not fully initialized at this point."
      in

      (match instr with
      | Iassign (pl, _, _) | Icall (_, _, pl, _) -> (
          match pl with
          | PlDeref pl0 ->
              if PlaceSet.mem pl0 uninit then
                Error.error loc "Writing into an uninitialized borrow."
          | PlField (pl0, _) ->
              if PlaceSet.mem pl0 uninit then
                Error.error loc "Writing into a field of an uninitialized struct."
          | _ -> ())
      | _ -> ());

      match instr with
      | Iassign (_, RVplace pl, _) | Iassign (_, RVborrow (_, pl), _) ->
          check_initialized pl
      | Iassign (_, RVbinop (_, l1, l2), _) ->
          check_initialized (PlLocal l1);
          check_initialized (PlLocal l2)
      | Iassign (_, RVunop (_, l), _) | Iif (l, _, _) -> check_initialized (PlLocal l)
      | Iassign (_, RVmake (_, ll), _) | Icall (_, ll, _, _) ->
          List.iter (fun l -> check_initialized (PlLocal l)) ll
      | Ireturn -> check_initialized (PlLocal Lret)
      | Iassign (_, (RVunit | RVconst _), _) | Ideinit _ | Igoto _ -> ())
    mir.minstrs;

  (* We check the code honors the non-mutability of shared borrows. *)
  Array.iteri
    (fun lbl (instr, loc) ->
      (* TODO: check that we never write to shared borrows, and that we never create mutable borrows
        below shared borrows. Function [place_mut] can be used to determine if a place is mutable, i.e., if it
        does not dereference a shared borrow. *)
      let uninit = uninitialized_places lbl in

      (* Error producing functions. One for places and the other for right values. *)
      let check_write_shared pl =
        if place_mut mir pl = NotMut then
          Error.error loc "Writing at or below a shared borrow"
      in

      let check_create_below_shared rvpl =
        if place_mut mir rvpl = NotMut then
          Error.error loc "Creating a mutable borrow from or below a shared borrow"
      in

      (* Checking on places we assign, and on the right value in the case of a RVborrow *)
      match instr with
      | Iassign (pl, RVborrow (Mut, rvpl), _) ->
          check_create_below_shared rvpl;
          check_write_shared pl
      | Icall (_, _, pl, _) -> check_write_shared pl
      | Iassign (pl, _, _) -> check_write_shared pl
      | _ -> ())
    mir.minstrs;

  let lft_sets = compute_lft_sets mir in

  (* TODO: check that outlives constraints declared in the prototype of the function are
    enough to ensure safety. I.e., if [lft_sets lft] contains program point [PpInCaller lft'], this
    means that we need that [lft] be alive when [lft'] dies, i.e., [lft] outlives [lft']. This relation
    has to be declared in [mir.outlives_graph]. *)

  (* Error producing function *)
  let check_outlives lft lft' =
    if LSet.mem lft' (LMap.find lft mir.moutlives_graph) then ()
    else
      Error.error mir.mloc "Outlives constraints are not enough to ensure function safety"
  in

  (* iteration on the set of lft' such that lft : lft' *)
  let check_outlives_set lft =
    PpSet.iter
      (fun pp -> match pp with PpInCaller lft' -> check_outlives lft lft' | _ -> ())
      (lft_sets lft)
  in

  (* iteration on all lifetimes *)
  List.iter check_outlives_set mir.mgeneric_lfts;

  (* We check that we never perform any operation which would conflict with an existing
    borrows. *)
  let bor_active_at = Active_borrows.go lft_sets mir in
  Array.iteri
    (fun lbl (instr, loc) ->
      (* The list of bor_info for borrows active at this instruction. *)
      let active_borrows_info : bor_info list =
        List.map (get_bor_info mir) (BSet.to_list (bor_active_at lbl))
      in

      (* Does there exist a borrow of a place pl', which is active at program point [lbl],
        such that a *write* to [pl] conflicts with this borrow?

         If [pl] is a subplace of pl', then writing to [pl] is always conflicting, because
        it is aliasing with the borrow of pl'.

         If pl' is a subplace of [pl], the situation is more complex:
           - if pl' involves as many dereferences as [pl] (e.g., writing to [x.f1] while
            [x.f1.f2] is borrowed), then the write to [pl] will overwrite pl', hence this is
            conflicting.
           - BUT, if pl' involves more dereferences than [pl] (e.g., writing to [x.f1] while
            [*x.f1.f2] is borrowed), then writing to [pl] will *not* modify values accessible
            from pl'. Hence, subtlely, this is not a conflict. *)
      let conflicting_borrow_no_deref pl =
        List.exists
          (fun bi -> is_subplace pl bi.bplace || is_subplace_no_deref bi.bplace pl)
          active_borrows_info
      in

      (match instr with
      | Iassign (pl, _, _) | Icall (_, _, pl, _) ->
          if conflicting_borrow_no_deref pl then
            Error.error loc "Assigning a borrowed place."
      | Ideinit (l, _) ->
          if conflicting_borrow_no_deref (PlLocal l) then
            Error.error loc
              "A local declared here leaves its scope while still being borrowed."
      | Ireturn ->
          Hashtbl.iter
            (fun l _ ->
              match l with
              | Lparam p ->
                  if conflicting_borrow_no_deref (PlLocal l) then
                    Error.error loc
                      "When returning from this function, parameter `%s` is still \
                       borrowed."
                      p
              | _ -> ())
            mir.mlocals
      | _ -> ());

      (* Variant of [conflicting_borrow_no_deref]: does there exist a borrow of a place pl',
        which is active at program point [lbl], such that a *read* to [pl] conflicts with this
        borrow? In addition, if parameter [write] is true, we consider an operation which is
        both a read and a write. *)
      let conflicting_borrow write pl =
        List.exists
          (fun bi ->
            (bi.bmut = Mut || write)
            && (is_subplace pl bi.bplace || is_subplace bi.bplace pl))
          active_borrows_info
      in

      (* Check a "use" (copy or move) of place [pl]. *)
      let check_use pl =
        let consumes = not (typ_is_copy (typ_of_place mir pl)) in
        if conflicting_borrow consumes pl then
          Error.error loc "A borrow conflicts with the use of this place.";
        if consumes && contains_deref_borrow pl then
          Error.error loc "Moving a value out of a borrow."
      in

      match instr with
      | Iassign (_, RVplace pl, _) -> check_use pl
      | Iassign (_, RVborrow (mut, pl), _) ->
          if conflicting_borrow (mut = Mut) pl then
            Error.error loc "There is a borrow conflicting this borrow."
      (* Added the function call case *)
      | Icall (_, ll, _, _) -> List.iter (fun l -> check_use (PlLocal l)) ll
      | _ -> ()
      (* TODO: complete the other cases | Is this even necessary ? This must be checked by the type checker *))
    mir.minstrs
