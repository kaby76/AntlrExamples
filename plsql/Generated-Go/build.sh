# Generated from trgen 0.19.2
export GO111MODULE=on
for i in {1..5}; do go get github.com/antlr/antlr4/runtime/Go/antlr/v4; if [ "$?" = "0" ]; then break; fi; done; if [ "$?" != "0" ]; then exit 1; fi

set -e

if [ -f transformGrammar.py ]; then python3 transformGrammar.py ; fi

java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  parser/PlSqlLexer.g4
java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  parser/PlSqlParser.g4


go build Test.go
