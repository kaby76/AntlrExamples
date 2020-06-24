# Parsing Antlr grammars with Antlr

This code is a parser for Antlr using Antlr with a twist--using a C# parser to parse action blocks.
Both the Antlr and C# grammars are from the Antlr grammars repository
([link](https://github.com/antlr/grammars-v4/)). I wrote this example after reviewing a discussion about
[parsing SQL statements that are embedded in comments in a string in Java](https://stackoverflow.com/questions/62535463/can-antlr-route-embedded-grammars-to-a-seperate-file-for-processing).

Basically, the way this works is that when an action block is about to be parsed, the Antlr lexer
creates a lexer and parser for C# and then parses a "block" rule in the input given the current
input stream for the Antlr parse. The C# parser reads the input stream until is is finished with the block.
Because the parser requires lookahead, which advances the input stream past the end of the action block,
the input stream is reset to the end of the action block.



