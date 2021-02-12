import antlr4 from 'antlr4';
import JavaScriptLexer from './JavaScriptLexer.js';
import JavaScriptParser from './JavaScriptParser.js';

export default class JavaScriptLexerBase extends antlr4.Parser {

    constructor(input) {
        super(input);
    }

    p(str) {
        return this.prev(str);
    }

    prev(str) {
        const source = this._input.LT(-1).source[1].strdata;
        const start = this._input.LT(-1).start;
        const stop = this._input.LT(-1).stop;
        const prev = source.slice(start, stop + 1);
        return prev === str;
    }

    notLineTerminator() {
        return !this.here(JavaScriptParser.LineTerminator);
    }

    notOpenBraceAndNotFunction() {
        const nextTokenType = this._input.LT(1).type;
        return (
                nextTokenType !== JavaScriptParser.OpenBrace &&
                nextTokenType !== JavaScriptParser.Function
               );
    }

    closeBrace() {
        return this._input.LT(1).type === JavaScriptParser.CloseBrace;
    }

    here(type) {
        const possibleIndexEosToken = this.getCurrentToken().tokenIndex - 1;
        const ahead = this._input.get(possibleIndexEosToken);
        return ahead.channel === antlr4.Lexer.HIDDEN && ahead.type === type;
    }

    lineTerminatorAhead() {
        let possibleIndexEosToken = this.getCurrentToken().tokenIndex - 1;
        let ahead = this._input.get(possibleIndexEosToken);
        if (ahead.channel !== antlr4.Lexer.HIDDEN) {
            return false;
        }
        if (ahead.type === JavaScriptParser.LineTerminator) {
            return true;
        }
        if (ahead.type === JavaScriptParser.WhiteSpaces) {
            possibleIndexEosToken = this.getCurrentToken().getTokenIndex() - 2;
            ahead = this._input.get(possibleIndexEosToken);
        }
        const text = ahead.type;
        const type = ahead.type;
        return (
                (type === JavaScriptParser.MultiLineComment &&
                 (text.includes("\r") || text.includes("\n"))) ||
                type === JavaScriptParser.LineTerminator
               );
    }
}
