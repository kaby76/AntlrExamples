.SUFFIXES: .g4 .js

ANTLRGRAMMARS ?= $(wildcard *.g4)

%Lexer.js %Parser.js : %.g4
	java -jar `cygpath -w ~/Downloads/antlr-4.9.1-complete.jar` -Dlanguage=JavaScript $<

%.js : %.g4
	java -jar `cygpath -w ~/Downloads/antlr-4.9.1-complete.jar` -Dlanguage=JavaScript $<

GENERATED = JavaScriptLexer.js JavaScriptParser.js

SOURCES = $(GENERATED) \
    program.js

default: $(GENERATED)
	npm i antlr4@4.9.1
	npm i typescript-string-operations@1.4.1
	npm i fs-extra

clean:
	rm -rf node_modules
	rm -f package-lock.json
	rm -f $(GENERATED)
	rm -f *.tokens *.interp

run:
	node program.js
