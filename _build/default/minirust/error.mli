val usage : unit -> unit

val error : Lexing.position * Lexing.position -> ('a, out_channel, unit, 'b) format4 -> 'a
(** Emit an error message using a program location and a format string, then exit the
    program. Format strings follow the same syntax as the [Printf.printf] function. E.g.,
    the following piece of code:

    [Error.error loc "%d * %i = %s\n" 6 7 "Forty-two"]

    will print something like:

    {v
       File foo.rs, line 18, charachers 18-20:
       6 * 7 = Forty-two
    v} *)
