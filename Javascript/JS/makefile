# Template generated code from trgen 0.10.0
JAR = C:/Users/Kenne/Downloads/antlr-4.9.2-complete.jar
CLASSPATH = $(JAR)\;.
.SUFFIXES: .g4 .js
ANTLRGRAMMARS ?= $(wildcard *.g4)
GENERATED = JavaScriptLexer.js JavaScriptParser.js 
SOURCES = $(GENERATED) index.js
default: classes
classes: $(SOURCES)
	npm install
clean:
	rm -rf node_modules
	rm -f package-lock.json
	rm -f *.interp
	rm -f *.tokens
	rm -f $(GENERATED)
run:
	trwdog node index.js $(RUNARGS)
JavaScriptLexer.js : JavaScriptLexer.g4
	java -jar $(JAR) -encoding utf-8 -Dlanguage=JavaScript  $<
JavaScriptParser.js : JavaScriptParser.g4
	java -jar $(JAR) -encoding utf-8 -Dlanguage=JavaScript  $<

test:
	bash test.sh
