(* render-adoc.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Render the grammar using Asciidoctor tables.
 *)

structure AsciiDoc : RENDER =
  struct

    structure T = GSpecTree

  (* place holders for some controls *)
    val linkNTs = ref true      (* create links from non-terminal uses to definitions *)

    datatype out = S of {
        outS : TextIO.outstream,
        cols : string
      }

    fun pr (S{outS, ...}, s) = TextIO.output (outS, s)
    fun prl (S{outS, ...}, l) = TextIO.output (outS, concat l)

    fun openOut (filename, rules) = let
          val outS = TextIO.openOut (OS.Path.joinBaseExt{base=filename, ext=SOME "adoc"})
        (* compute approximate widths of the lhs and rhs of the rules *)
          fun widthsOfRule (T.Rule{lhs, rhs, ...}, (maxLHS, maxRHS)) = let
                val maxLHS = Int.max (size (T.nontermToString lhs), maxLHS)
                fun widthOfPhrase (T.Nonterm nt) = size (T.nontermToString nt)
                  | widthOfPhrase (T.Term t) = size (T.termToString t)
                  | widthOfPhrase (T.Lit t) = size (T.litToString t)
                  | widthOfPhrase (T.Group([p], _)) = widthOfPhrase p + 1
                  | widthOfPhrase (T.Group(ps, _)) =
                    (* count parens, multiplicity operator, and spaces between items *)
                      List.foldl (fn (p, n) => 1 + n + widthOfPhrase p) 2 ps
(* TODO: what about the optional note? *)
(* TODO: should we have special treatment for empty rhs? *)
                fun widthOfRHS (T.RHS{spec, ...}, maxRHS) =
                      Int.max (
                        List.foldl (fn (p, n) => 1 + n + widthOfPhrase p) ~1 spec,
                        maxRHS)
                val maxRHS = Int.max (maxRHS, List.foldl widthOfRHS 0 rhs)
                in
                  (maxLHS, maxRHS)
                end
          val (maxLHS, maxRHS) = List.foldl widthsOfRule (0, 0) rules
          in
print(concat["maxLHS = ", Int.toString maxLHS, ", maxRHS = ", Int.toString maxRHS, "\n"]);
            S{
                outS = outS,
                cols = String.concat [
                    ">", Int.toString maxLHS, ",^3,", "<", Int.toString maxRHS
                  ]
              }
          end

    fun closeOut (S{outS, ...}) = TextIO.closeOut outS

    fun comment (outS, msg) = prl (outS, ["% ", msg, "\n"])

    fun rules (outS as S{cols, ...}) render = (
          prl (outS, [
              "[.grammar,%autowidth,cols=\"", cols, "\",grid=\"none\",frame=\"none\"]\n"
            ]);
          pr (outS, "|====\n");
          render();
          pr (outS, "|====\n"))

    fun rule (outS, _, lhs) render = (
          prl (outS, [
              "| [.nt]#", lhs, "#[[nt.", lhs, "]]\n"
            ]);
          render ())

    fun rhsHelper (outS, true) = pr (outS, "| ::=\n")
      | rhsHelper (outS, false) = pr (outS, "|\n| \\|\n")

    fun empty (outS, isFirst, _, _) = (
          rhsHelper (outS, isFirst);
          pr (outS, "| [.empty]#empty#\n"))

    fun rhs (outS, isFirst, _, _) render = (
          rhsHelper (outS, isFirst);
          pr (outS, "| ");
          render ();
          pr (outS, "\n"))

    fun mult2s GSpecTree.ZeroOrOne = "^?^"
      | mult2s GSpecTree.ZeroOrMore = "^*^"
      | mult2s GSpecTree.OneOrMore = "^+^"

  (* render a single symbol with a multiplicity *)
    fun iterate (outS, m) render = (render(); pr (outS, mult2s m))

  (* render a group with a multiplicity *)
    fun group (outS, m) render = (pr (outS, "( "); render(); prl (outS, [" )", mult2s m]))

  (* render a separator (e.g., space) between rhs phrases *)
    fun sep outS = pr (outS, " ")

(* FIXME *)
    fun textEscape s = let
          fun tr ([], chrs) = String.implodeRev chrs
            | tr (#"*" :: cr, chrs) = tr (cr, #"*" :: #"\\" :: chrs)
            | tr (#"|" :: cr, chrs) = tr (cr, #"|" :: #"\\" :: chrs)
            | tr (#"-" :: #">" :: cr, chrs) = tr (cr, #">" :: #"-" :: #"\\" :: chrs)
            | tr (#"=" :: #">" :: cr, chrs) = tr (cr, #">" :: #"=" :: #"\\" :: chrs)
            | tr (#"." :: #"." :: #"." :: cr, chrs) = tr (cr, #"." :: #"." :: #"." :: #"\\" :: chrs)
            | tr (c::cr, chrs) = tr (cr, c::chrs)
          in
            tr (String.explode s, [])
          end

  (* render rhs symbols *)
    fun nonterm (outS, nt) = prl (outS, ["<<nt.", nt, ",[.nt]#", nt, "#>>"])
    fun term (outS, t) = prl (outS, ["[.term]#", t, "#"])
    fun lit (outS, t) = prl (outS, ["[.sym]#", textEscape t, "#"])
    fun kw (outS, t) = prl (outS, ["[.kw]#", textEscape t, "#"])

  end

structure RenderAsciiDoc = RenderSpecFn (AsciiDoc)
