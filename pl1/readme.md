# Parsing PL/I

This code is a parser for PL/I using Antlr. This is an import of the Bison grammar for PL/I,
which I've included here with the source. The generated grammar has some problems, some
of which have been corrected.

* The Bison rules for precedence and associativity have not been included in the generated grammar.

* There was [indirect left recursion in expr and exprbase](https://github.com/kaby76/AntlrVSIX/issues/70)
which I didn't solve but just worked around.

* Some rules were removed because they were for error recovery, which is not needed for Antlr.

* There is no Flex import, so I manually entered these rules.

* Keywords can be in upper or lower case. I added a transform to convert a string literal for a keyword
into a sequential set of upper and lower case characters of the keyword, but it had some problems, so I
had to tweek that by hand.

* I could not find the rules for "*PROCESS;", so I just created a rule for that. There's no %IMPORT yet.

* The parser is very slow for some of the tests contained here, which I found in Github.
