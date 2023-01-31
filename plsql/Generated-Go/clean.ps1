# Generated from trgen 0.19.2
$(& Remove-Item *.interp -Recurse -Force ) 2>&1 | Out-Null
$files = New-Object System.Collections.Generic.List[string]
$f = java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -depend -encoding utf-8 -Dlanguage=Dart -o parser -lib parser -package parser  parser/PlSqlLexer.g4
foreach ($s in $f) {
    $j = $s.Split(" ")[0]
    $files.Add($j)
}
foreach ($f in $files)
{
    $(& Remove-Item $f -Force ) 2>&1 | Out-Null
}
$f = java -jar "C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar" -depend -encoding utf-8 -Dlanguage=Dart -o parser -lib parser -package parser  parser/PlSqlParser.g4
foreach ($s in $f) {
    $j = $s.Split(" ")[0]
    $files.Add($j)
}
foreach ($f in $files)
{
    $(& Remove-Item $f -Force ) 2>&1 | Out-Null
}

$(& Remove-Item ./Test.exe -Force ) 2>&1 | Out-Null
exit 0
