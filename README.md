# Antlr Version 4 Examples

[![Build status](https://ci.appveyor.com/api/projects/status/th2hyup4n8t5blwa?svg=true)](https://ci.appveyor.com/project/kaby76/antlrexamples)

* [A parser for Mysql](https://github.com/kaby76/AntlrExamples/tree/master/mysql) -- This excellent example of the power of Antlr 4 is from the Oracle Workbench library
at https://github.com/mysql/mysql-workbench/tree/8.0/library/parsers/grammars, and written by
Mike Lischke.

* [Why you should not use a LHS predicate in Antlr Lexers](https://github.com/kaby76/AntlrExamples/tree/master/perf).

* [Parsing Bison grammars with Antlr](https://github.com/kaby76/AntlrExamples/tree/master/Bison). This program parses Bison grammar files using Antlr!

* [Parsing Antlr grammars with Antlr](https://github.com/kaby76/AntlrExamples/tree/master/Antlr). This program parses Antlr4 grammar files using Antlr.

* [Parsing context-free languages in the Antlr lexer](https://github.com/kaby76/AntlrExamples/tree/master/lexer-as-parser). This program demos the use of the well-known expression grammar in the lexer. The rules can't have left recursion, and they all need to be marked with the _fragment_ keyword, but it works.

* [XPath version 3.1](https://github.com/kaby76/AntlrExamples/tree/master/xpath31). This C# program contains the latest grammar
for XPath, along with 1000+ test cases.

* [Simple arithmetic example targeting C++ using CMake](https://github.com/kaby76/AntlrExamples/tree/master/CMakeProject1). This program
is unique for a CMake configured Antlr C++ program. This is a concrete example of the somewhat incomplete [instructions](https://github.com/antlr/antlr4/tree/master/runtime/Cpp/cmake) given in the Antlr website.

* [Tomaszewski's example](https://github.com/kaby76/AntlrExamples/tree/master/Tomaszewski). I was combing the web and came
across [an interesting article by Tomaszewki](https://pdfs.semanticscholar.org/a8dd/2ef009df7601cdbc90332765a56a24c7821c.pdf), of a CFG grammar that doesn't recognize strings like "ww", but a CFG that
recognizes string not in the language--an interesting play on what a recognizer could do.

* [Matlab](https://github.com/kaby76/AntlrExamples/tree/master/Matlab). This is an example of the Matlab grammar
with semantic predicates to correct a tokenization problem with the transpose operator. I've also included
the grammar for Octave which I derived by importing the Bison grammar in from the source for Octave.

* [Antlr grammars with C# action blocks](https://github.com/kaby76/AntlrExamples/tree/master/AntlrTargetCSharp).
This is an example of parsing an Antlr targeting C# in action blocks.

* [PL1](https://github.com/kaby76/AntlrExamples/tree/master/pl1). This is grammar for PL/I that I generated
from an import of a Bison grammar for the GNU PL/I front end.
