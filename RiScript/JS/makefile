.SUFFIXES: .g4 .js

ANTLRGRAMMARS ?= $(wildcard *.g4)

%Lexer.js %Parser.js : %.g4
	java -jar ../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar -Dlanguage=JavaScript *.g4

%.js : %.g4
	java -jar ../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar -Dlanguage=JavaScript *.g4

GENERATED = RiScriptLexer.js RiScriptParser.js RiScriptParserListener.js

SOURCES = $(GENERATED) program.js

default: classes

classes: $(GENERATED)

clean:
	rm -rf $(GENERATED) *.tokens *.interp *~ node_modules package-lock.json *.java

run:
	npm i antlr4@4.9.1
	npm i fs-extra
	npm i typescript-string-operations@1.4.1
	cp -r ../fixed-antlr/JavaScript/src/antlr4/ node_modules/antlr4/src/antlr4
	node program.js -file test.txt
