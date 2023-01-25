lexer grammar SybaseLexer;

import TSqlLexer;

STRING options { caseInsensitive=false; } : 'N'? '\'' (~'\'' | '\'\'')* '\'' ;
DOUBLE_QUOTED_STRING options { caseInsensitive=false; } : '"' (~'"' | '\\"' )* '"' ;
