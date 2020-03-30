lexer grammar FlexLexer;

channels {
	OFF_CHANNEL		// non-default channel for whitespace and comments
}

options {
	superClass = LexerAdaptor ;
}

tokens {
SECTEND,
SCDECL,
XSCDECL,
TOK_OPTION,
TOK_OUTFILE,
TOK_EXTRA_TYPE,
TOK_PREFIX,
TOK_YYCLASS,
TOK_HEADER_FILE,
TOK_TABLES_FILE,
EOF_OP,
BEGIN_REPEAT_POSIX,
NUMBER,
END_REPEAT_POSIX,
BEGIN_REPEAT_FLEX,
END_REPEAT_FLEX,
PREVCCL,
CHAR,
CCE_ALNUM,
CCE_ALPHA,
CCE_BLANK,
CCE_CNTRL,
CCE_DIGIT,
CCE_GRAPH,
CCE_LOWER,
CCE_PRINT,
CCE_PUNCT,
CCE_SPACE,
CCE_XDIGIT,
CCE_UPPER,
CCE_NEG_ALNUM,
CCE_NEG_ALPHA,
CCE_NEG_BLANK,
CCE_NEG_CNTRL,
CCE_NEG_DIGIT,
CCE_NEG_GRAPH,
CCE_NEG_PRINT,
CCE_NEG_PUNCT,
CCE_NEG_SPACE,
CCE_NEG_XDIGIT,
CCE_NEG_LOWER,
CCE_NEG_UPPER,
ERROR,
CCL_OP_DIFF,
CCL_OP_UNION
}

// ======================= Common fragments =========================

fragment Underscore
	: '_'
	;

fragment NameStartChar
	:	'A'..'Z'
	|	'a'..'z'
    | '_'
	|	'\u00C0'..'\u00D6'
	|	'\u00D8'..'\u00F6'
	|	'\u00F8'..'\u02FF'
	|	'\u0370'..'\u037D'
	|	'\u037F'..'\u1FFF'
	|	'\u200C'..'\u200D'
	|	'\u2070'..'\u218F'
	|	'\u2C00'..'\u2FEF'
	|	'\u3001'..'\uD7FF'
	|	'\uF900'..'\uFDCF'
	|	'\uFDF0'..'\uFFFD'
	| '$' // For PHP
	;	// ignores | ['\u10000-'\uEFFFF] ;

fragment DQuoteLiteral
	: DQuote ( EscSeq | ~["\r\n\\] | ( '\\' [\n\r]*) )* DQuote
	;

fragment DQuote
	: '"'
	;

fragment SQuote
	: '\''
	;

fragment CharLiteral
	: SQuote ( EscSeq | ~['\r\n\\] )  SQuote
	;

fragment SQuoteLiteral
	: SQuote ( EscSeq | ~['\r\n\\] )* SQuote
	;

fragment Esc
	: '\\'
	;

fragment EscSeq
	:	Esc
		([abefnrtv?"'\\]	// The standard escaped character set such as tab, newline, etc.
		| [xuU]?[0-9]+) // C-style 
	;

fragment EscAny
	:	Esc .
	;

fragment Id
	: NameStartChar NameChar*
	;

fragment Type
	: ([\t\r\n\f a-zA-Z0-9] | '[' | ']' | '{' | '}' | '.' | '_' | '(' | ')' | ',')+
	;

fragment NameChar
	:	NameStartChar
	|	'0'..'9'
	|	Underscore
	|	'\u00B7'
	|	'\u0300'..'\u036F'
	|	'\u203F'..'\u2040'
	| '.'
	| '-'
	;

fragment BlockComment
	: '/*' 
     (
	   ('/' ~'*')
	   | ~'/'
	 )*
	 '*/'
	;

fragment LineComment
	: '//' ~[\r\n]*
	;

fragment LineCommentExt
	: '//' ~'\n'* ( '\n' Hws* '//' ~'\n'* )*
	;

fragment Ws
	: Hws
	| Vws
	;

fragment Hws
	: [ \t]
	;

fragment Vws
	: [\r\n\f]
	;

/* Four types of user code:
    - prologue (code between '%{' '%}' in the first section, before %%);
    - actions, printers, union, etc, (between braced in the middle section);
    - epilogue (everything after the second %%).
    - predicate (code between '%?{' and '{' in middle section); */

// -------------------------
// Actions

fragment LBrace
	: '{'
	;

fragment RBrace
	: '}'
	;

fragment PercentLBrace
	: '%{'
	;

fragment PercentRBrace
	: '%}'
	;

fragment PercentQuestion
	: '%?{'
	;

fragment ActionCode
    : Stuff*
	;

fragment Stuff
	: EscAny
	| DQuoteLiteral
	| SQuoteLiteral
	| BlockComment
	| LineComment
	| NestedAction
	| ~('{' | '}' | '\'' | '"')
	;

fragment NestedPrologue
	: PercentLBrace ActionCode PercentRBrace
	;

fragment NestedAction
	: LBrace ActionCode RBrace
	;

fragment NestedPredicate
	: PercentQuestion ActionCode RBrace
	;

fragment Sp
	: Ws*
	;

fragment Eqopt
	: (Sp [=])?
	;

fragment Nl :
    [\r]?[\n]
	;

fragment OptWs :
    [ \t]*
    ;

fragment Lexopt :
    [aceknopr]
	;

fragment Alnum :
    ( Alpha | Digit )
	;

fragment Alpha :
	[A-Za-z]
	;

fragment Blank :
	[ \t]
	;

// Cntrl?

fragment Digit :
	[0-9]
	;

// Graph?

fragment Lower :
	[a-z]
	;

// Print?

// Punct?

fragment Space :
	[ ]
	;

fragment Upper :
	[A-Z]
	;

// XDigit?

fragment Name :
	(Alpha | Digit | '$') (Alpha | Digit | [_.\-/$])*
	;


fragment Ccl_expr :
	'[:' '^'? Alpha+ ':]'
	;

// -------------------------
// Comments

BLOCK_COMMENT
	:	BlockComment	-> channel(OFF_CHANNEL)
	;

LINE_COMMENT
	:	LineComment		-> channel(OFF_CHANNEL)
	;


OPEN_BRACKET : '[' ;
CLOSE_BRACKET : ']' ;
DQUOTE : '"' ;
EQUAL : '=' ;
OPEN_CURLY : '{' ;
CLOSE_CURLY : '}' ;
NL : Nl ;
UP : '^' ;
LT : '<' ;
GT : '>' ;
STAR : '*' ;
COMMA : ',' ;
DOLLAR : '$' ;
VBAR : '|' ;
SLASH : '/' ;
PLUS : '+' ;
QUESTION : '?' ;
DOT : '.' ;
OPEN_PAREN : '(' ;
CLOSE_PAREN : ')' ;
MINUS : '-' ;

// ===================================================================

mode INITIAL;

IUpWs : Ws { input.LA(-1) == '\n' }? { START_CODEBLOCK(true); } ;
IUpStartComment : '/*' { input.LA(-1) == '\n' }? { add_action("/*[\"["); yy_push_state( COMMENT ); } ;
IPoundOptWsLineWs : '#' { input.LA(-1) == '\n' }? OptWs 'line' Ws { yy_push_state( LINEDIR ); } ;
SCDECL : '%s' { input.LA(-1) == '\n' }? Id? ;
XSCDECL : '%x' { input.LA(-1) == '\n' }? Id? ;
IEndCodeBlock : '%{' { input.LA(-1) == '\n' }? .* Nl { START_CODEBLOCK(false); } ;
ITop : '%top' { input.LA(-1) == '\n' }? Ws '{' Ws Nl {
                brace_start_line = linenum;
                ++linenum;
                buf_linedir( &top_buf, infilename?infilename:"<stdin>", linenum);
                brace_depth = 1;
                yy_push_state(CODEBLOCK_MATCH_BRACE);
            } ;
IDiscard : Ws -> skip ;
SECTEND:   '%%' { input.LA(-1) == '\n' }? .* {
			sectnum = 2;
			bracelevel = 0;
			mark_defs1();
			line_directive_out(NULL, 1);
			BEGIN(SECT2PROLOG);
			return SECTEND;
			} ;
IUpPointer_nl : '%pointer' { input.LA(-1) == '\n' }? .* Nl { yytext_is_array = false; ++linenum; } ;
IUpArrayNl : '%array' { input.LA(-1) == '\n' }? .* NL	{ yytext_is_array = true; ++linenum; } ;
IUpOption : '%option' { input.LA(-1) == '\n' }? -> type(TOK_OPTION), pushMode(OPTION);
IUpPercentLexoptOptWsDigitOptWsLn : '%' Lexopt OptWs Digit* OptWs Nl { ++linenum; } ;
NLOPTION : Nl -> popMode ;

// ===================================================================

mode OPTION;

TOK_OUTFILE : 'outfile' ;
TOK_EXTRA_TYPE : 'extra-type' ;
TOK_PREFIX : 'prefix' ;
TOK_YYCLASS : 'yyclass' ;
TOK_HEADER_FILE : 'header' '-file'? ;
TOK_TABLES_FILE : 'tables-file' ;


mode SECT2;

	BlankLine : OptWs Nl // { input.LA(1); }
		-> channel(OFF_CHANNEL);

mode GROUP_WITH_PARAMS;

    I_group_with_params_colon : ':' { BEGIN(SECT2); } ;
    I_group_with_params_dash : '-'  { BEGIN(GROUP_MINUS_PARAMS); } ;
    I_group_with_params_i : 'i' { sf_set_case_ins(1); } ;
    I_group_with_params_s : 's' { sf_set_dot_all(1); } ;
    I_group_with_params_x : 'x' { sf_set_skip_ws(1); } ;

mode GROUP_MINUS_PARAMS;

    I_group_minus_params_colon : ':' { BEGIN(SECT2); } ;
    I_group_minus_params_i : 'i' { sf_set_case_ins(0); } ;
    I_group_minus_params_s : 's' { sf_set_dot_all(0); } ;
    I_group_minus_params_x : 'x' { sf_set_skip_ws(0); } ;


mode FIRSTCCL;

	I_firstccl_cce_alnum : Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_firstccl_cce_alpha : Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_firstccl_cce_blank : Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_firstccl_cce_cntrl : Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_firstccl_cce_digit : Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_firstccl_cce_graph : Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_firstccl_cce_lower : Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_firstccl_cce_print : Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_firstccl_cce_punct : Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_firstccl_cce_space : Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_firstccl_cce_upper : Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_firstccl_cce_xdigit : Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	I_firstccl_cce_neg_alnum : '^' Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_firstccl_cce_neg_alpha : '^' Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_firstccl_cce_neg_blank : '^' Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_firstccl_cce_neg_cntrl : '^' Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_firstccl_cce_neg_digit : '^' Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_firstccl_cce_neg_graph : '^' Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_firstccl_cce_neg_lower : '^' Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_firstccl_cce_neg_print : '^' Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_firstccl_cce_neg_punct : '^' Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_firstccl_cce_neg_space : '^' Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_firstccl_cce_neg_upper : '^' Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_firstccl_cce_neg_xdigit : '^' Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	Icll_expr : Ccl_expr {
			format_synerr(
				_( "bad character class expression: %s" ),
					yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
			} ;

mode CCL;

	I_ccl_cce_alnum : Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_ccl_cce_alpha : Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_ccl_cce_blank : Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_ccl_cce_cntrl : Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_ccl_cce_digit : Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_ccl_cce_graph : Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_ccl_cce_lower : Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_ccl_cce_print : Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_ccl_cce_punct : Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_ccl_cce_space : Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_ccl_cce_upper : Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_ccl_cce_xdigit : Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	I_ccl_cce_neg_alnum : '^' Alnum  { BEGIN(CCL); Type=CCE_NEG_ALNUM; } ;
	I_ccl_cce_neg_alpha : '^' Alpha  { BEGIN(CCL); Type=CCE_NEG_ALPHA; } ;
	I_ccl_cce_neg_blank : '^' Blank { BEGIN(CCL); Type=CCE_NEG_BLANK; } ;
	//I_ccl_cce_neg_cntrl : '^' Cntl { BEGIN(CCL); Type=CCE_NEG_CNTRL; } ;
	I_ccl_cce_neg_digit : '^' Digit { BEGIN(CCL); Type=CCE_NEG_DIGIT; } ;
	//I_ccl_cce_neg_graph : '^' Graph { BEGIN(CCL); Type=CCE_NEG_GRAPH; } ;
	I_ccl_cce_neg_lower : '^' Lower { BEGIN(CCL); Type=CCE_NEG_LOWER; } ;
	//I_ccl_cce_neg_print : '^' Print { BEGIN(CCL); Type=CCE_NEG_PRINT; } ;
	//I_ccl_cce_neg_punct : '^' Punct { BEGIN(CCL); Type=CCE_NEG_PUNCT; } ;
	I_ccl_cce_neg_space : '^' Space { BEGIN(CCL); Type=CCE_NEG_SPACE; } ;
	I_ccl_cce_neg_upper : '^' Upper { BEGIN(CCL); Type=CCE_NEG_UPPER; } ;
	//I_ccl_cce_neg_xdigit : '^' Xdigit { BEGIN(CCL); Type=CCE_NEG_XDIGIT; } ;

	I_ccl_cll_expr : Ccl_expr {
			format_synerr(
				_( "bad character class expression: %s" ),
					yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
			} ;

