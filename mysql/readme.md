# MySQL Workbench Parser

This code is my translation of the Antlr parser from
the Oracle Workbench library
at https://github.com/mysql/mysql-workbench/tree/8.0/library/parsers/grammars (written by
Mike Lischke).

* The translation removes all but the code for the parser, except
for a few unused methods in MySQLSymbolInfo.cs, which seem somewhat useful.

* The code source tree was flatten into one directory.

* The Antlr grammars are processed automatically using Antlr4BuildTasks.

* The error reporting using the "Code Completion" routines were completely replaced with my
own lookahead predictor because Mike's code does not work correctly.
For further information, see my blog entry describing the new algorithm.
As far as I could tell, the only tree walkers used were for code completion, which was used
for error reporting. They were removed, and the generation of them turned off.

--Ken Domino