# Generated from trgen 0.22.0
version=4.13.1
rm -f *.interp
files=()
JAR=`python -c "import os; from pathlib import Path; print(os.path.join(Path.home() , '.m2',  'repository', 'org', 'antlr', 'antlr4', '$version', 'antlr4-$version-complete.jar'))"`
files+=( `java -jar "$JAR" -depend -encoding utf-8 -Dlanguage=Java   PythonLexer.g4 | awk '{print $1}' | grep -v ':'` )
files+=( `java -jar "$JAR" -depend -encoding utf-8 -Dlanguage=Java   PythonParser.g4 | awk '{print $1}' | grep -v ':'` )

for i in ${files[*]}
do
    rm -f $i
done
rm -f *.class
exit 0
