# Matlab

This example illustrates several issues one will face
with complex grammars that you may grab from the Internet.
I wrote this example after reading
in [StackOverflow](https://stackoverflow.com/questions/62469159/antlr-matlab-grammar-lexing-conflict)
the problem with parsing code with the single quote character for TRANSPOSE.

The Matlab grammar was copied from the [Antlr grammars repository](https://github.com/antlr/grammars-v4/tree/c04f9cfd25e0a4d6348704e76d9726ba295f668a/matlab),
but it was modified to include semantic predicates to disambiguate problems
when tokenizing the transpose operator. 
The solution here (as opposed to what was suggested in
the StackOverflow answer)
uses two semantic predicates that look at parser state at the end of the rule.
Semantic predicates at the beginning of the rule
will perform inefficiently. Note, there is no keyword "transpose" allowed in Matlab,
but the grammar erroneously defines one.

This example also provides a grammar I imported from the Octave 5.2 sources. The grammar illustrates
the kinds of problems one faces when converting a Bison grammar to Antlr: the lexer is in Flex,
which is not converted by the tool;
the lexer is parser state aware;
unmodified, "[ 1 2 3 ]" does not parse because the grammar
requires separators between the values in the matrix;
the parser contains rules that use newlines as tokens,
so importing a bad grammar does not fix the bad grammar.


