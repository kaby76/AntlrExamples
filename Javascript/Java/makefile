# Template generated code from trgen 0.10.0
JAR = /tmp/antlr-4.9.3-complete.jar
CLASSPATH = $(JAR):.
.SUFFIXES: .g4 .java .class
.java.class:
	javac -cp $(CLASSPATH) $*.java
ANTLRGRAMMARS ?= $(wildcard *.g4)
GENERATED = JavaScriptLexer.java JavaScriptParser.java JavaScriptParserBaseListener.java  JavaScriptParserListener.java
SOURCES = $(GENERATED) \
    Program.java \
    ErrorListener.java
default: classes
classes: $(GENERATED) $(SOURCES:.java=.class)
clean:
	rm -f *.class
	rm -f *.interp
	rm -f *.tokens
	rm -f $(GENERATED)
run:
	trwdog java -classpath $(CLASSPATH) Program $(RUNARGS)
JavaScriptLexer.java : JavaScriptLexer.g4
	java -jar $(JAR) -encoding utf-8  $<
JavaScriptParser.java : JavaScriptParser.g4
	java -jar $(JAR) -encoding utf-8  $<

test:
	bash test.sh
