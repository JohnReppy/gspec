(* main.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure Main : sig

    (* `renderAsciidoc (combined, file)` renders the grammar specification in `file`
     * as Asciidoc.  If the `combined` flag is true, then the sections are combined
     * in the output.
     *)
    val renderAsciidoc : bool * string -> OS.Process.status

    (* `renderLatex (combined, file)` renders the grammar specification in `file`
     * as LaTeX.  If the `combined` flag is true, then the sections are combined
     * in the output.
     *)
    val renderLatex : bool * string -> OS.Process.status

  end = struct

  (* renderers *)
    structure RLG = RenderLaTeXGrammar
    structure RAD = RenderAsciiDoc

    fun err s = TextIO.output (TextIO.stdErr, s)

  (* check for errors and report them if there are any *)
    fun checkForErrors errStrm =
          if Error.anyErrors errStrm
            then raise Error.ERROR
            else ()

    fun doFile render (combined, filename) = let
          val basename = (case OS.Path.splitBaseExt filename
                 of {base, ext=SOME "gspec"} => base
                  | _ => filename
                (* end case *))
          val _ = if OS.FileSys.access(filename, [OS.FileSys.A_READ])
                then ()
                else (
                  err  (concat[
                      "source file \"", filename, "\" does not exist or is not readable\n"
                    ]);
                  raise Error.ERROR)
          val (spec, errStrm) = GSpecParser.parseFile filename
          in
            if Error.anyErrors errStrm
              then (Error.report (TextIO.stdErr, errStrm); OS.Process.failure)
              else (
                if Error.anyWarnings errStrm
                  then Error.report (TextIO.stdErr, errStrm)
                  else ();
                render (combined, basename, valOf spec);
                OS.Process.success)
          end

    val renderAsciidoc = doFile RAD.render
    val renderLatex = doFile RLG.render

  end
