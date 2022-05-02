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

## Syntax

The following grammar (specified using the above notation) describes the
syntax of grammar specs:

````
[gspec] {
  <spec>  : <rule-group>+
          | <rule>+

  <rule-group> : "label" '{' <rule>+ '}'

  <rule>  : "non-term" ':' <rhs> ( '|' <rhs> )* "blank-line"

  <rhs>   : 'empty' <comment>?
          | <item>* <comment>?

  <comment> : '#{' "text" '}'

  <item>  : <symbol>
          | <symbol> <repeat>
          | '(' <item>+ ')' <repeat>

  <symbol> : "literal"
           | "term-id"
           | "non-term"

  <repeat> " '?' | '*' | '+'
}
````

## Rule Groups

A specification is either a sequence of CFG rules or a sequence
of rule groups, where each rule group is a named sequence of
CFG rules.

Rule groups provide a mechanism for splitting a specification across
multiple output files.
