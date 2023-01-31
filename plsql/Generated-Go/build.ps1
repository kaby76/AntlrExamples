# Generated from trgen 0.19.2
$env:GO111MODULE = "on"
For ($i=0; $i -le 5; $i++) {
	$(& go get github.com/antlr/antlr4/runtime/Go/antlr/v4 ; $compile_exit_code = $LASTEXITCODE) | Write-Host
	if($compile_exit_code -eq 0){
		Break
	}
	Write-Host "go get failed. Trying again."
}
if($compile_exit_code -ne 0){
    exit $compile_exit_code
}

if (Test-Path -Path transformGrammar.py -PathType Leaf) {
    $(& python3 transformGrammar.py ) 2>&1 | Write-Host
}

$(& java -jar C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar parser/PlSqlLexer.g4 -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  ; $compile_exit_code = $LASTEXITCODE) | Write-Host
if($compile_exit_code -ne 0){
    exit $compile_exit_code
}
$(& java -jar C:/Users/Kenne/.m2/antlr4-4.11.1-complete.jar parser/PlSqlParser.g4 -encoding utf-8 -Dlanguage=Go -o parser -lib parser -package parser  ; $compile_exit_code = $LASTEXITCODE) | Write-Host
if($compile_exit_code -ne 0){
    exit $compile_exit_code
}


$(& go build Test.go; $compile_exit_code = $LASTEXITCODE) | Write-Host
exit $compile_exit_code
