(* latex-util.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure LaTeXUtil : sig

    val textEscape : string -> string

  end = struct

    val textEscape = String.translate (
          fn #"{" => "\\{"
           | #"}" => "\\}"
           | #"%" => "\\%"
           | #"#" => "\\#"
           | #"_" => "\\char`\\_"
           | #"^" => "\\char`\\^"
           | c => str c)

  end
