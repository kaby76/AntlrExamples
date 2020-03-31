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




fragment Alnum :
    ( Alpha | Digit )
	;

fragment Alpha :
	[A-Za-z]
	;

fragment Blank :
	' ' | '\t'
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

fragment Ws :
	Blank+
	;

fragment OptWs :
	Blank*
	;

fragment NotWs :
	~( ' ' | '\t' | '\r' | '\n')
	;

fragment Nl :
    [\r]?[\n]
	;


fragment Name :
	(Alpha | Digit | '$') (Alpha | Digit | [_.\-/$])*
	;

fragment Scname :
	Name
	;

fragment EscSeq
	:	'\\'
		([abefnrtv?"'\\]	// The standard escaped character set such as tab, newline, etc.
		| [xuU]?[0-9]+) // C-style 
	;

fragment First_ccl_char :
	~( '\\' | '\n')
	| EscSeq
	;
	
fragment Ccl_char :
	~( '\\' | '\n' | ']')
	| EscSeq
	;

fragment Ccl_expr :
	'[:' '^'? Alpha+ ':]'
	;

fragment Lexopt :
    [aceknopr]
	;

fragment M4qstart :
	'[['
	;

fragment M4qend :
	']]'
	;

// ===================================================================

mode INITIAL;

	I_initial_upws : Ws { this.InputStream.LA(-1) == '\n' }? { START_CODEBLOCK(true); } ;
	I_initial_upstartcomment : '/*' { this.InputStream.LA(-1) == '\n' }? { add_action("/*[\"["); yy_push_state( COMMENT ); } ;
	I_initial_poundoptwslinews : '#' { this.InputStream.LA(-1) == '\n' }? OptWs 'line' Ws { yy_push_state( LINEDIR ); } ;
	I_initial_percents : '%s' { this.InputStream.LA(-1) == '\n' }? Name? { Type=SCDECL; } ;
	I_initial_percentx : '%x' { this.InputStream.LA(-1) == '\n' }? Name? { Type=XSCDECL; } ;
	I_initial_percentcurly : '%{' { this.InputStream.LA(-1) == '\n' }? .* Nl { START_CODEBLOCK(false); } ;
	I_initial_top : '%top' { this.InputStream.LA(-1) == '\n' }? Ws '{' Ws Nl {
					brace_start_line = linenum;
					++linenum;
					buf_linedir( &top_buf, infilename?infilename:"<stdin>", linenum);
					brace_depth = 1;
					yy_push_state(CODEBLOCK_MATCH_BRACE);
				} ;
	I_initial_ws : Ws -> skip ;
	I_initial_perper : '%%' { this.InputStream.LA(-1) == '\n' }? .* {
				sectnum = 2;
				bracelevel = 0;
				mark_defs1();
				line_directive_out(NULL, 1);
				BEGIN(SECT2PROLOG);
				return SECTEND;
				} ;
	I_initial_uppointer_nl : '%pointer' { this.InputStream.LA(-1) == '\n' }? .* Nl { yytext_is_array = false; ++linenum; } ;
	I_initial_uparraynl : '%array' { this.InputStream.LA(-1) == '\n' }? .* Nl	{ yytext_is_array = true; ++linenum; } ;
	I_initial_upoption : '%option' { this.InputStream.LA(-1) == '\n' }? -> type(TOK_OPTION), pushMode(OPTION);
	I_initial_uppercentlexoptoptwsdigitoptwsln : '%' Lexopt OptWs Digit* OptWs Nl { ++linenum; } ;
	I_initial_upname : Name { this.InputStream.LA(-1) == '\n' }? {
			if(yyleng < MAXLINE)
        	{
				strncpy( nmstr, yytext, sizeof(nmstr) );
			}
			else
			{
			   synerr("Definition name too long\n");
			   FLEX_EXIT(EXIT_FAILURE);
			}

			didadef = false;
			BEGIN(PICKUPDEF);
		} ;
	I_initial_scname : Scname { Type=RETURNNAME; } ;
	I_initial_upoptwsnl : OptWs { this.InputStream.LA(-1) == '\n' }? Nl { ++linenum; } ;
	I_initial_optwsnl : OptWs Nl { ACTION_ECHO(); ++linenum; } ;

// ===================================================================

mode COMMENT;

	I_comment_noblahblah : ~('[' | ']' | '*' | '\n')* { ACTION_ECHO(); } ;
	I_comment_dot : . { ACTION_ECHO(); } ;
	I_comment_nl : Nl { ++linenum; ACTION_ECHO(); } ;
	
	I_comment_end : '*/' { add_action("*/]\"]"); yy_pop_state(); } ;

mode CODE_COMMENT;

	I_code_comment_noblahblah : ~('[' | ']' | '*' | '\n')* { ACTION_ECHO(); } ;
	I_code_comment_dot : . { ACTION_ECHO(); } ;
	I_code_comment_nl : Nl { ++linenum; ACTION_ECHO(); } ;

	I_code_comment_end : '*/' { ACTION_ECHO(); yy_pop_state(); } ;

// ===================================================================

mode OPTION;

	TOK_OUTFILE : 'outfile' ;
	TOK_EXTRA_TYPE : 'extra-type' ;
	TOK_PREFIX : 'prefix' ;
	TOK_YYCLASS : 'yyclass' ;
	TOK_HEADER_FILE : 'header' '-file'? ;
	TOK_TABLES_FILE : 'tables-file' ;


mode SECT2;

	BlankLine : OptWs Nl // { this.InputStream.LA(1); }
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
				"bad character class expression: %s"
				+ yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
			} ;

mode CCL;

	I_up : '^' { BEGIN(CCL); Type=CARET; } ;
	I_ret : ~('\\' | '\n') { RETURNCHAR(); } ;
	I_closebracket : ']' { BEGIN(SECT2); Type=CLOSE_BRACKET; } ;
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
				"bad character class expression: %s" +
					yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
			} ;

