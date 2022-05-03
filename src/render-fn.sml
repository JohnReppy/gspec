(* render-fn.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Functor for implementing a grammar rendering function from operations to render the
 * pieces of a grammar.
 *)

signature RENDER =
  sig

    type out

  (* open an output stream that targets the named file.  The grammar rules that are
   * going to be output are provided to allow the renderer to analyze it (if necessary).
   *)
    val openOut : string * GSpecTree.rule list -> out

  (* close the output stream *)
    val closeOut : out -> unit

    val comment : out * string -> unit

    val rules : out -> (unit -> unit) -> unit

    val rule : out * string option * string -> (unit -> unit) -> unit

  (* render an empty rhs *)
    val empty : out * bool * string option * string option -> unit
    val rhs : out * bool * string option * string option -> (unit -> unit) -> unit

  (* render a single symbol with a multiplicity *)
    val iterate : out * GSpecTree.multiplicity -> (unit -> unit) -> unit

  (* render a group with a multiplicity *)
    val group : out * GSpecTree.multiplicity -> (unit -> unit) -> unit

  (* render a separator (e.g., space) between rhs phrases *)
    val sep : out -> unit

  (* render rhs symbols *)
    val nonterm : out * string -> unit
    val term : out * string -> unit
    val lit : out * string -> unit
    val kw : out * string -> unit

  end

functor RenderSpecFn (R : RENDER) : sig

  (* first argument is true if all sections should be combined into one *)
    val render : bool * string * GSpecTree.grammar_spec -> unit

  end = struct

    structure T = GSpecTree

  (* collect all the rules into a single rule list *)
    fun collect (secs : T.section list) = let
          fun collect' (T.Container(_, secs)) = collect secs
            | collect' (T.Sect(_, rules)) = rules
          in
            List.concat (List.map collect' secs)
          end

    fun isSymbol (T.Group _) = false
      | isSymbol _ = true

    val label2s = Option.map T.labelToString

    fun renderRules (outS, rules) = let
          fun renderPhrases [] = ()
            | renderPhrases [p] = renderPhrase p
            | renderPhrases (p::pr) = (renderPhrase p; R.sep outS; renderPhrases pr)
          and renderPhrase (T.Nonterm nt) = R.nonterm (outS, T.nontermToString nt)
            | renderPhrase (T.Term t) = R.term (outS, T.termToString t)
(* TODO: identify keyword literals *)
            | renderPhrase (T.Lit l) = R.lit (outS, T.litToString l)
            | renderPhrase (T.Group([p], m)) =
                if isSymbol p
                  then R.iterate (outS, m) (fn () => renderPhrase p)
                  else R.group (outS, m) (fn () => renderPhrase p)
            | renderPhrase (T.Group(ps, m)) =
                R.group (outS, m) (fn () => renderPhrases ps)
          fun renderRHS (T.RHS{label, spec, note}, isFirst) = (
                case spec
                 of [] => R.empty (outS, isFirst, label2s label, note)
                  | _ => R.rhs (outS, isFirst, label2s label, note) (fn () =>
                      renderPhrases spec)
                (* end case *);
                false)
          fun renderRule (T.Rule{label, lhs, rhs}) =
                R.rule (outS, label2s label, T.nontermToString lhs) (fn () =>
                  ignore (List.foldl renderRHS true rhs))
          in
            List.app renderRule rules
          end

    fun renderToFile (path, rules) = let
          val outS = R.openOut (path, rules)
          in
            R.rules outS (fn () => renderRules (outS, rules));
            R.closeOut outS
          end

    fun renderSections (path, spec) = let
          fun renderSection prefix (T.Container(lab, secs)) =
                List.app (renderSection (concat[prefix, "-", T.labelToString lab])) secs
            | renderSection prefix (T.Sect(lab, rules)) =
                renderToFile (concat[prefix, "-", T.labelToString lab], rules)
          in
            List.app (renderSection path) spec
          end

    fun render (flatten, path, gspec) = (case gspec
	   of T.Container(_, sects) =>
                if flatten
                  then renderToFile (path, collect sects)
                  else renderSections (path, sects)
            | T.Sect(_, rules) => renderToFile (path, rules)
          (* end case *))

  end
