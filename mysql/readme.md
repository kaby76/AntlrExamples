# MySQL Workbench Parser

This code is my translation of the Antlr parser from
the [Oracle Workbench library](https://github.com/mysql/mysql-workbench/tree/8.0/library/parsers/grammars) written by
Mike Lischke.

* The translation removes almost all the code except for parsing.
A few unused methods in MySQLSymbolInfo.cs were kept because
they might be useful in some applications.
The code was cleaned and reorganized using CodeMaid
and Resharper.

* The code source tree was flatten into one directory to make it simplier to navigate.

* The Antlr grammars are processed automatically using Antlr4BuildTasks.

* The error reporting using the "Code Completion" routines were completely replaced with my
own lookahead predictor because Mike's code does not work correctly in some situations.
For further information, see my [blog entry](http://codinggorilla.com/?p=2449) describing the new algorithm.

* As far as I could tell, the only tree walkers used were for code completion
for error reporting, and certainly not for static semantic analysis.
Since the error message handler code was replaced, the tree walkers and the generation
of the base classes were removed.

--Ken Domino
