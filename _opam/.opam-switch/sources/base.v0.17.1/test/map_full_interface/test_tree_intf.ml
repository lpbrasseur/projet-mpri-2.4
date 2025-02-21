open! Base

module Definitions = struct
  module Types = struct
    type 'key key = 'key
    type 'cmp cmp = 'cmp
    type ('key, 'data, 'cmp) t = ('key, 'data, 'cmp) Map.Using_comparator.Tree.t
    type ('key, 'data, 'cmp) tree = ('key, 'data, 'cmp) Map.Using_comparator.Tree.t
    type ('key, 'cmp, 'fn) create_options = comparator:('key, 'cmp) Comparator.t -> 'fn
    type ('key, 'cmp, 'fn) access_options = comparator:('key, 'cmp) Comparator.t -> 'fn
  end

  module type S = Functor.S with module Types := Types
end

module type Test_tree = sig
  include module type of struct
    include Definitions
  end

  include S
end
