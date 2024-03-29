// Template generated code from trgen 0.10.0

import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const antlr4 = require('antlr4');
import JavaScriptLexer from './JavaScriptLexer.js';
import JavaScriptParser from './JavaScriptParser.js';

const strops = require('typescript-string-operations');
let fs = require('fs-extra')

function getChar() {
    let buffer = Buffer.alloc(1);
    var xx = fs.readSync(0, buffer, 0, 1);
    if (xx === 0) {
        return '';
    }
    return buffer.toString('utf8');
}

class MyErrorListener extends antlr4.error.ErrorListener {
    syntaxError(recognizer, offendingSymbol, line, column, msg, err) {
        num_errors++;
        console.error(`${offendingSymbol} line ${line}, col ${column}: ${msg}`);
    }
}

var show_tokens = false;
var show_tree = false;
var input = null;
var file_name = null;
for (let i = 2; i < process.argv.length; ++i)
{
    switch (process.argv[i]) {
        case '-tokens':
            var show_tokens = true;
            break;
        case '-tree':
            var show_tree = true;
            break;
        case '-input':
            var input = process.argv[++i];
            break;
        case '-file':
            var file_name = process.argv[++i];
            break;
        default:
            console.log('unknown '.concat(process.argv[i]));
    }
}
var str = null;
if (input == null && file_name == null)
{
    var sb = new strops.StringBuilder();
    var ch;
    while ((ch = getChar()) != '')
    {
        sb.Append(ch);
    }
    var input = sb.ToString();
    str = antlr4.CharStreams.fromString(input);
} else if (input != null)
{
    str = antlr4.CharStreams.fromString(input);
} else if (file_name != null)
{
    str = antlr4.CharStreams.fromPathSync(file_name, 'utf8');
}
var num_errors = 0;
const lexer = new JavaScriptLexer(str);
lexer.strictMode = false;
const tokens = new antlr4.CommonTokenStream(lexer);
const parser = new JavaScriptParser(tokens);
lexer.removeErrorListeners();
parser.removeErrorListeners();
parser.addErrorListener(new MyErrorListener());
lexer.addErrorListener(new MyErrorListener());
if (show_tokens)
{
    for (var i = 0; ; ++i)
    {
        var ro_token = lexer.nextToken();
        var token = ro_token;
        token.TokenIndex = i;
        console.log(token.toString());
        if (token.type === antlr4.Token.EOF)
            break;
    }
    lexer.reset();
}
const tree = parser.program();
if (show_tree)
{
    console.log(tree.toStringTree(parser.ruleNames));
}
if (num_errors > 0)
{
    console.error('Parse failed.');
    process.exitCode = 1;
}
else
{
    console.error('Parse succeeded.');
    process.exitCode = 0;
}
