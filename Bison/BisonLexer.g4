lexer grammar BisonLexer;

channels {
	OFF_CHANNEL		// non-default channel for whitespace and comments
}

PERCENT_TOKEN:       '%token';
PERCENT_NTERM:       '%nterm';

PERCENT_TYPE:        '%type';
PERCENT_DESTRUCTOR:  '%destructor';
PERCENT_PRINTER:     '%printer';

PERCENT_LEFT:        '%left';
PERCENT_RIGHT:       '%right';
PERCENT_NONASSOC:    '%nonassoc';
PERCENT_PRECEDENCE:  '%precedence';

PERCENT_PREC:        '%prec';
PERCENT_DPREC:       '%dprec';
PERCENT_MERGE:       '%merge';

PERCENT_CODE:            '%code';
PERCENT_DEFAULT_PREC:    '%default-prec';
PERCENT_DEFINE:          '%define';
PERCENT_DEFINES:         '%defines';
PERCENT_ERROR_VERBOSE:   '%error-verbose';
PERCENT_EXPECT:          '%expect';
PERCENT_EXPECT_RR:       '%expect-rr';
PERCENT_FLAG:            '%<flag>';
PERCENT_FILE_PREFIX:     '%file-prefix';
PERCENT_GLR_PARSER:      '%glr-parser';
PERCENT_INITIAL_ACTION:  '%initial-action';
PERCENT_LANGUAGE:        '%language';
PERCENT_NAME_PREFIX:     '%name-prefix';
PERCENT_NO_DEFAULT_PREC: '%no-default-prec';
PERCENT_NO_LINES:        '%no-lines';
PERCENT_NONDETERMINISTIC_PARSER:  '%nondeterministic-parser';
PERCENT_OUTPUT:          '%output';
PERCENT_PURE_PARSER:     '%pure-parser';
PERCENT_REQUIRE:         '%require';
PERCENT_SKELETON:        '%skeleton';
PERCENT_START:           '%start';
PERCENT_TOKEN_TABLE:     '%token-table';
PERCENT_VERBOSE:         '%verbose';
PERCENT_YACC:            '%yacc';

BRACED_CODE:       '{...}';
BRACED_PREDICATE:  '%?{...}';
BRACKETED_ID:      '[' Id ']';
CHAR:              CharLiteral;
COLON:             ':';
EPILOGUE:          'epilogue';
EQUAL:             '=';
//ID_COLON:          Id ':';
ID:                Id;
PERCENT_PERCENT:   '%%';
PIPE:              '|';
PROLOGUE:          '%{' .* '%}';
SEMICOLON:         ';';
TAG:               '<tag>';
TAG_ANY:           '<*>';
TAG_NONE:          '<>';

PARAM: '%param';
UNION: '%union';
EMPTY: '%empty';


STRING: DQuoteLiteral;
INT: [0-9]+;
//TSTRING: ;

fragment DQuoteLiteral	: DQuote ( EscSeq | ~["\r\n\\] )* DQuote	;
fragment DQuote			: '"'	;
fragment SQuote			: '\''	;
fragment CharLiteral	: SQuote ( EscSeq | ~['\r\n\\] )  SQuote	;
fragment SQuoteLiteral	: SQuote ( EscSeq | ~['\r\n\\] )* SQuote	;
fragment USQuoteLiteral	: SQuote ( EscSeq | ~['\r\n\\] )* 			;

fragment Esc			: '\\'	;
fragment EscSeq
	:	Esc
		[btnfr"'\\]	// The standard escaped character set such as tab, newline, etc.
	;
fragment EscAny
	:	Esc .
	;

fragment Id : [a-zA-Z]+;


BLOCK_COMMENT
	:	BlockComment	-> channel(OFF_CHANNEL)
	;

LINE_COMMENT
	:	LineComment		-> channel(OFF_CHANNEL)
	;

fragment BlockComment	: '/*'  .*? ('*/' | EOF)	;
fragment LineComment	: '//' ~[\r\n]* 							;
fragment LineCommentExt	: '//' ~'\n'* ( '\n' Hws* '//' ~'\n'* )*	;
fragment Ws				: Hws | Vws	;
fragment Hws			: [ \t]		;
fragment Vws			: [\r\n\f]	;
WS	:	( Hws | Vws )+		-> channel(OFF_CHANNEL)	;

 /* Four types of user code:
    - prologue (code between '%{' '%}' in the first section, before %%);
    - actions, printers, union, etc, (between braced in the middle section);
    - epilogue (everything after the second %%).
    - predicate (code between '%?{' and '{' in middle section); */

// -------------------------
// Actions

BEGIN_ACTION
	:	LBrace		-> pushMode(MAction)
	;

LBRACE		: LBrace		;
RBRACE		: RBrace		;
fragment LBrace			: '{'	;
fragment RBrace			: '}'	;
// -------------------------
// Actions
//
// Many language targets use {} as block delimiters and so we
// must recursively match {} delimited blocks to balance the
// braces. Additionally, we must make some assumptions about
// literal string representation in the target language. We assume
// that they are delimited by ' or " and so consume these
// in their own alts so as not to inadvertantly match {}.

mode MAction;

	NESTED_ACTION			: LBrace			-> type(ACTION_CONTENT), pushMode(MAction)	;

	ACTION_ESCAPE			: EscAny			-> type(ACTION_CONTENT)		;

	ACTION_STRING_LITERAL	: DQuoteLiteral		-> type(ACTION_CONTENT)		;
	ACTION_CHAR_LITERAL		: SQuoteLiteral		-> type(ACTION_CONTENT)		;

	ACTION_BLOCK_COMMENT	: BlockComment 		-> type(ACTION_CONTENT)		;
	ACTION_LINE_COMMENT		: LineComment 		-> type(ACTION_CONTENT)		;

	END_ACTION				: RBrace		-> popMode		;

	UNTERMINATED_ACTION		: EOF		-> type(ACTION_CONTENT), popMode		;

	ACTION_CONTENT			: .							;
