# Generated from trgen 0.19.2
rm -f *.interp
files=()
files+=( `java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -depend -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  parser/PlSqlLexer.g4 | awk '{print $1}' | grep -v ':'` )
files+=( `java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -depend -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  parser/PlSqlParser.g4 | awk '{print $1}' | grep -v ':'` )

for i in ${files[*]}
do
    rm -f $i
done
rm -f ./Test.exe
