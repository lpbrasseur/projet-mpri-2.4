# 1 "shape_tools.cppo.mli"
open Odoc_model.Paths

# 4 "shape_tools.cppo.mli"
type t = Shape.t * Odoc_model.Paths.Identifier.SourceLocation.t Shape.Uid.Map.t


# 12 "shape_tools.cppo.mli"
val lookup_def :
  Env.t ->
  Identifier.NonSrc.t ->
  Identifier.SourceLocation.t option
