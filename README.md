# Grammar Spec (gspec) Processing Tool

This directory contains a simple tool for processing programming-language
grammar specifications.  The idea is to allow a single specification to
be used to generate multiple textual representations (e.g., LaTex and
Asciidoc).

## Notation

* symbol names: symbol names are identifiers that start with a letter
  and can contain letters, decimal digits, dashes ('-'), underscores ('_'),
  and single quotes (''').

* literal terminal symbols: a literal terminal is specified by enclosing
  it in single quote characters; *e.g.*, `'if'`.

* terminal symbols: a symbol name enclosed in double quotes;
  *e.g.*, `"identifier"`.

* non-terminal symbols: a symbol name enclosed in angle brackets;
  *e.g.*, `<expression>`.

* labels are identifiers enclosed in `[` `]`

* comments start with the `#` character and run to the end of the
  current line.  There is a special form of a comment, called a
  *note*, that starts with the characters `#<` and which is attached
  to the proceeding production.

## Syntax

The following grammar (specified using the above notation) describes the
syntax of grammar specs:

```
[gspec] {
  <spec>    : <section>+
            | <rule>+

  <content> : <section>+
            | <rule>+

  <section> : "label" '{' <content> '}'

  <rule>    : "label"? "non-term" ':' <rhs> ( '|' <rhs> )*

  <rhs>     : "label"? 'empty' "note"?
            | "label"? <phrase>+ "note"?

  <phrase>  : <symbol>
            | <symbol> <repeat>
            | '(' <phrase>+ ')' <repeat>

  <symbol>  : "non-terminal"
            | "terminal"
            | "literal"

  <repeat>  " '?' | '*' | '+'
}
```

## Rule Groups

A specification is either a sequence of CFG rules or a sequence
of rule groups, where each rule group is a named sequence of
CFG rules.

Rule groups provide a mechanism for splitting a specification across
multiple output files.
