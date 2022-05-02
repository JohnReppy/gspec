(* gspec-parser.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure GSpecParser : sig

  (* parse a file; return NONE if there are syntax errors *)
    val parseFile : string -> GSpecTree.grammar_spec option * Error.err_stream

  end = struct

    datatype add_or_delete = datatype AntlrRepair.add_or_delete

  (* error function for lexers *)
    fun lexErr errStrm (pos, msg) = Error.errorAt(errStrm, (pos, pos), msg)

  (* map tokens to strings; when adding a token, we use a generic name where it makes sense *)
    fun tokToString ADD (GSpecTokens.LABEL _) = "[label]"
      | tokToString DEL (GSpecTokens.LABEL s) = concat["[", Atom.toString s, "]"]
      | tokToString ADD (GSpecTokens.NONTERM s) = "<nonterm>"
      | tokToString DEL (GSpecTokens.NONTERM s) = concat["\"", Atom.toString s, "\""]
      | tokToString ADD (GSpecTokens.TERM s) = "\"term\""
      | tokToString DEL (GSpecTokens.TERM s) = concat["\"", Atom.toString s, "\""]
      | tokToString ADD (GSpecTokens.LIT s) = "'lit'"
      | tokToString DEL (GSpecTokens.LIT s) = concat["'", s, "'"]
      | tokToString ADD (GSpecTokens.POST_NOTE s) = "note"
      | tokToString DEL (GSpecTokens.POST_NOTE s) = "#< " ^ String.toString s
      | tokToString _ tok = GSpecTokens.toString tok

  (* error function for parsers *)
    val parseErr = Error.parseError tokToString

  (* glue together the lexer and parser *)
    structure GSpecParser = GSpecParseFn(GSpecLex)

    fun parseFile filename = let
          val errStrm = Error.mkErrStream filename
          val file = TextIO.openIn filename
          fun get () = TextIO.input file
          val lexer = GSpecLex.lex (Error.sourceMap errStrm) (lexErr errStrm)
          val (res, _, errs) = GSpecParser.parse lexer (GSpecLex.streamify get)
          in
            TextIO.closeIn file;
            List.app (parseErr errStrm) errs;
            (res, errStrm)
          end

  end

