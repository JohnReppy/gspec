(* gspec.lex
 *
 * COPYRIGHT (c) 2022 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

%name GSpecLex;

%arg (lexErr);

%defs (
  structure T = GSpecTokens;

(* some type lex_result is necessitated by ml-ulex *)
  type lex_result = T.token

(* extract the identifier from and bracketing marks *)
  fun getId s = substring(s, 1, size s - 2);

  fun postNote ss = let
        val ss = Substring.triml 2 ss                   (* remove leading "#<" *)
        val ss = Substring.dropl Char.isSpace ss        (* remove leading whitespace *)
        val ss = Substring.dropr Char.isSpace ss        (* remove trailing whitespace *)
        in
          T.POST_NOTE(Substring.string ss)
        end

  (* eof : unit -> lex_result *)
  (* ml-ulex requires this as well *)
  fun eof () = T.EOF
);

%states INITIAL;

%let alpha=[a-zA-Z];
%let idchr={alpha}|[0-9_-];
%let id={alpha}{idchr}*;
%let litchr=[\033-\126];
%let ws = " "|[\t\n\v\f\r];
%let eol = "\n"|"\r\n";
%let anychrs = [^\n\r];

<INITIAL> "("           => (T.LP);
<INITIAL> ")"           => (T.RP);
<INITIAL> "{"           => (T.LCB);
<INITIAL> "}"           => (T.RCB);
<INITIAL> ":"           => (T.COLON);
<INITIAL> "|"           => (T.BAR);
<INITIAL> "?"           => (T.QMARK);
<INITIAL> "*"           => (T.STAR);
<INITIAL> "+"           => (T.PLUS);
<INITIAL> "<"{id}">"    => (T.NONTERM(Atom.atom(getId yytext)));
<INITIAL> "\""{id}"\""  => (T.TERM(Atom.atom(getId yytext)));
<INITIAL> "'"{litchr}+"'"
                        => (T.LIT(getId yytext));
<INITIAL> "["{id}"]"    => (T.LABEL(Atom.atom(getId yytext)));

<INITIAL> "empty"       => (T.KW_empty);

<INITIAL> "#<"{anychrs}*{eol}
                        => (postNote yysubstr);
<INITIAL> "#"{anychrs}*{eol}
                        => (skip());

<INITIAL> {ws}+         => (skip());

(* error rules *)
<INITIAL> {id}          => (lexErr(yypos, ["unbracketed identifier `", yytext, "`"]);
                            skip());
<INITIAL> "\""[^"]*"\"" => (lexErr(yypos, ["invalid terminal identifier `", yytext, "`"]);
                            skip());
<INITIAL> .             => (lexErr(yypos, ["bad character `", String.toString yytext, "`"]);
                            skip());
