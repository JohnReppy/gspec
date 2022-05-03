(* gspec-tree.sml
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure GSpecTree =
  struct

    type label = Atom.atom
    type nonterm = Atom.atom
    type term = Atom.atom
    type lit = string

  (* the label of the root section *)
    val rootLabel = Atom.atom ""

    datatype section
      = Container of label * section list
      | Sect of label * rule list

    and rule = Rule of {
        label : label option,
        lhs : nonterm,
        rhs : rhs list
      }

    and rhs = RHS of {
        label : label option,
        spec : phrase list,
        note : string option
      }

    and phrase
      = Nonterm of nonterm
      | Term of term
      | Lit of lit
      | Group of phrase list * multiplicity

    and multiplicity = ZeroOrOne | ZeroOrMore | OneOrMore

    type grammar_spec = section

    val labelToString : label -> string = Atom.toString
    val nontermToString : nonterm -> string = Atom.toString
    val termToString : term -> string = Atom.toString
    val litToString : lit -> string = Fn.id

  end
