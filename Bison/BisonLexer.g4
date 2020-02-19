lexer grammar BisonLexer;

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
CHAR:              ['] . ['];
COLON:             ':';
EPILOGUE:          'epilogue';
EQUAL:             '=';
ID:                Id;
ID_COLON:          Id ':';
PERCENT_PERCENT:   '%%';
PIPE:              '|';
PROLOGUE:          '%{...%}';
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
fragment Esc			: '\\'	;
fragment EscSeq
	:	Esc
		[btnfr"'\\]	// The standard escaped character set such as tab, newline, etc.
	;

fragment Id : [a-zA-Z]+;