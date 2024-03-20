(* render-latex-grammar.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Render to LaTeX using the grammar.sty package for layout.
 *)

structure LaTeXGrammar : RENDER =
  struct

    structure U = LaTeXUtil

    type out = TextIO.outstream

    fun pr (outS, s) = TextIO.output (outS, s)
    fun prl (outS, l) = TextIO.output (outS, concat l)

    fun openOut (filename, _) = TextIO.openOut (OS.Path.joinBaseExt{base=filename, ext=SOME "tex"})

    fun closeOut outS = TextIO.closeOut outS

    fun comment (outS, msg) = prl (outS, ["% ", msg, "\n"])

    fun rules outS render = (
          pr (outS, "\\begin{Grammar}\n");
          render();
          pr (outS, "\\end{Grammar}\n"))

    fun rule (outS, _, lhs) render = (
          prl (outS, ["  \\begin{Rules}{", lhs, "}\n"]);
          render ();
          pr (outS, "  \\end{Rules}\n"))

    (* a rule separator is ignored for now *)
    fun ruleSep outS = ()

    fun empty (outS, _, _, _) = pr (outS, "    \\RHS{}\n")

    fun rhs (outS, _, _, _) render = (
          pr (outS, "    \\RHS{");
          render ();
          pr (outS, "}\n"))

    fun mult2s GSpecTree.ZeroOrOne = "\\OPT"
      | mult2s GSpecTree.ZeroOrMore = "\\LIST"
      | mult2s GSpecTree.OneOrMore = "\\LISTONE"

  (* render a single symbol with a multiplicity *)
    fun iterate (outS, m) render = (prl (outS, [mult2s m, "{"]); render(); pr (outS, "}"))

  (* render a group with a multiplicity *)
    fun group (outS, m) render = (prl (outS, [mult2s m, "GRP{"]); render(); pr (outS, "}"))

  (* render a separator (e.g., space) between rhs phrases *)
    fun sep outS = pr (outS, "~~")

  (* render rhs symbols *)
    fun nonterm (outS, nt) = prl (outS, ["\\nt{", U.textEscape nt, "}"])
    fun term (outS, t) = prl (outS, ["\\term{", U.textEscape t, "}"])
    fun lit (outS, t) = prl (outS, ["\\sym{", U.textEscape t, "}"])
    fun kw (outS, t) = prl (outS, ["\\kw{", U.textEscape t, "}"])

  end

structure RenderLaTeXGrammar = RenderSpecFn (LaTeXGrammar)
