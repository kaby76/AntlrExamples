.SUFFIXES: .g4 .java .class

.java.class:
	javac -classpath .:../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar $*.java

ANTLRGRAMMARS ?= $(wildcard *.g4)

%Lexer.java %Parser.java : %.g4
	java -jar ../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar *.g4

%.java : %.g4
	java -jar ../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar *.g4

GENERATED = RiScriptLexer.java RiScriptParser.java RiScriptParserBaseListener.java RiScriptParserListener.java

SOURCES = $(GENERATED) Program.java ErrorListener.java

default: classes

classes: $(GENERATED) $(SOURCES:.java=.class)

clean:
	rm -f *.class $(GENERATED) *.tokens *.interp *~

run:
	java -classpath ../fixed-antlr/antlr4-4.9.2-SNAPSHOT-complete.jar:. Program -file test.txt
