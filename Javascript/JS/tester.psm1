# Template generated code from trgen 0.10.0
function Build-Grammar {
    $g = antlr JavaScriptLexer.g4 -Dlanguage=JavaScript 
    if($LASTEXITCODE -ne 0){
        return @{
            Message = $g
            Success = $false
        }
    }
    $g = antlr JavaScriptParser.g4 -Dlanguage=JavaScript 
    if($LASTEXITCODE -ne 0){
        return @{
            Message = $g
            Success = $false
        }
    }

    $msg = npm install
    return @{
        Message = $msg
        Success = $LASTEXITCODE -eq 0
    }
}

function Test-Case {
    param (
        $InputFile,
        $TokenFile,
        $TreeFile,
        $ErrorFile
    )
    $o = trwdog node index.js -file $InputFile
    $failed = $LASTEXITCODE -ne 0
    if ($failed -and $errorFile) {
        return $true
    }
    if(!$failed -and !$errorFile){
        return $true
    }
    return $false
}