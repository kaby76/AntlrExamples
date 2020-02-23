# Parsing context-free languages in the Antlr lexer.

Did you know that Antlr's lexer is a CFL parser? I didn't because most programs write regular expressions
for the lexer rules. But, you can write a full-blown CFL. This program demos the use of the well-known
expression grammar in the lexer. The rules can't have left recursion, and they all need to be marked with
the fragment keyword. Consequently, the expression language needed to be rewritten with rule factoring.
