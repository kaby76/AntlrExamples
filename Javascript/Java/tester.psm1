# Template generated code from trgen 0.10.0
function Build-Grammar {
    $g = antlr JavaScriptLexer.g4 -Dlanguage=Java 
    if($LASTEXITCODE -ne 0){
        return @{
            Message = $g
            Success = $false
        }
    }
    $g = antlr JavaScriptParser.g4 -Dlanguage=Java 
    if($LASTEXITCODE -ne 0){
        return @{
            Message = $g
            Success = $false
        }
    }

    $msg = javac JavaScriptLexer.java JavaScriptParser.java  Program.java ErrorListener.java
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
    $o = trwdog java Program -file $InputFile
    $failed = $LASTEXITCODE -ne 0
    if ($failed -and $errorFile) {
        return $true
    }
    if(!$failed -and !$errorFile){
        return $true
    }
    return $false
}