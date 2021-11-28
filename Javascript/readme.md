# Javascript in Antlr using Trgen drivers

This directory contains a copy of the [JavaScript](https://github.com/antlr/grammars-v4/tree/master/javascript/javascript) grammar
in [grammars-v4](https://github.com/antlr/grammars-v4) that has been set up with
[trgen](https://github.com/kaby76/Domemtech.Trash/tree/main/trgen) drivers. This tool is
part of the [Trash toolkit](https://github.com/kaby76/Domemtech.Trash) for grammars.
The end result of running the tool is a complete, self-contained program whereby you
can do the build directly via "make", or "dotnet build" in the case of the C# program.
For the targets that I generated, you will need to set yourself up with the appropriate
environment. Antlr4 tool JAR file will be need to the Java and JavaScript targets. If you
would like other targets, use trgen to generate the driver. This tool uses the Antlr 4.9.3.

Ken
