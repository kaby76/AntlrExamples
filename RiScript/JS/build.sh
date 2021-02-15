#!/bin/sh
rm -rf node_modules
rm -f package-lock.json
npm i antlr4@4.9.1
if [[ "$?" != "0" ]]
then
    exit 1
fi
npm i typescript-string-operations@1.4.1
if [[ "$?" != "0" ]]
then
    exit 1
fi
npm i fs-extra
if [[ "$?" != "0" ]]
then
    exit 1
fi
cp -r /c/Users/kenne/Documents/GitHub/antlr4/runtime/JavaScript/src/antlr4/* node_modules/antlr4/src/antlr4
java -jar ~/Downloads/antlr4-4.9.2-SNAPSHOT-complete.jar -Dlanguage=JavaScript *.g4
# java -jar ~/Downloads/antlr-4.9.1-complete.jar -Dlanguage=JavaScript *.g4
if [[ "$?" != "0" ]]
then
    exit 1
fi
cat - << EOF
To run:
echo string | node.exe program.js -tree
node.exe program.js -tree -input string
node.exe program.js -tree -file path
EOF

