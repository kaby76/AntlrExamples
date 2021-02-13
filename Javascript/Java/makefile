
# Generated code from Antlr4BuildTasks.dotnet-antlr v 1.5
# Makefile for JavaScriptLexer.g4, JavaScriptParser.g4

.SUFFIXES: .g4 .java .class

.java.class:
	javac -cp ~/Downloads/antlr-4.9.1-complete.jar:. $*.java

ANTLRGRAMMARS ?= $(wildcard *.g4)

%Lexer.java %Parser.java : %.g4
	java -jar ~/Downloads/antlr-4.9.1-complete.jar  $<

%.java : %.g4
	java -jar ~/Downloads/antlr-4.9.1-complete.jar  $<

GENERATED = JavaScriptLexer.java JavaScriptParser.java

SOURCES = $(GENERATED) \
    Program.java \
    ErrorListener.java

default: classes

classes: $(GENERATED) $(SOURCES:.java=.class)

clean:
	rm **/*.class $(GENERATED)

run:
	java -classpath ~/Downloads/antlr-4.9.1-complete.jar:. .Program

