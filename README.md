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

* terminal symbols: a terminal symbol name enclosed in double quotes;
  *e.g.*, `"identifier"`.

* non-terminal symbols: a non-terminal symbol name enclosed in angle brackets;
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
  <spec>    : <content>

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

  <repeat>  : " '?' | '*' | '+'
}
```

## Grammar Sections

A grammar can be specified as a sequence of CFG rules or as
a heirarchy of labeled sections, where the innermost sections
contain CFG rules.

Sections provide a mechanism for splitting a specification across
multiple output files.  For example, if we have a grammar specification
in the file `lang.gspec` that has the following structure

```
section foo {
  section bar { ... }
  section baz { ... }
}
```

then there will be two output files generated: `lang-foo-bar.out` and
`lang-foo-baz.out` (where `out` is the file suffix for the target format).

## Targets

We currently envision three targets for the `gspec` tool (of which two
are currently implemented).  These are

* LaTeX using the `grammar.sty` file that is provided in the `support`
  directory

* LaTeX using the `syntax.sty` package that comes with most
  TeX distributions. (not yet implemented)

* HTML via **asciidoctor**.  This target produces Asciidoc files that
  can be used to generate HTML.  The `grammar.css` support file defines
  styles for the different kinds of grammar symbols.

