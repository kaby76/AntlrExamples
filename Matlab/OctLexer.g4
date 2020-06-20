lexer grammar OctLexer;

options { superClass=LexBase; }
channels { COMMENT_CHANNEL }

LP : '(' ;
RP : ')' ;
LB :'[' ;
RB : ']' ;
LC : '{' ;
RC : '}' ;
COLON : ':' ;
COMMA : ',' ;
DOT : '.' ;
AT : '@' ;
PLUS : '+' ;
MINUS : '-' ;
EXPR_NOT : '~' | '!' ;
STAR : '*' ;
SL : '/' ;
LEFTDIV : '\\' ;
EXPR_GT : '>' ;
EXPR_LT : '<' ;
EXPR_AND : '&' ;
EXPR_OR : '|' ;
EQ : '=' ;
SEMI : ';' ;
TRANSPOSE : '\'' { CheckQuote("SQ") }? ;

POW : '^' | '**' ;

PLUS_PLUS : '++' ;
MINUS_MINUS : '--' ;
EPLUS : '.+' ;
EMINUS : '.-' ;
EMUL : '.*' ;
EDIV : './' ;
ELEFTDIV : '.\\' ;
EPOW : ('.^' | '.**') ;
EXPR_LE : '<=' ;
EXPR_GE : '>=' ;
EXPR_EQ : '==' ;
EXPR_NE : '~=' | '!=' ;
NCTRANSPOSE : '.\'' ;
EXPR_AND_AND : '&&' ;
EXPR_OR_OR : '||' ;
LEFTDIV_EQ : '\\=' ;

POW_EQ : '^=' | '**=' ;
ADD_EQ : '+=' | '.+=' ;
SUB_EQ : '-=' | '.-=' ;
MUL_EQ : '*=' ;
DIV_EQ : '/=' ;
AND_EQ : '&=' ;
OR_EQ : '|=' ;


EMUL_EQ : '.*=' ;
EDIV_EQ : './=' ;
ELEFTDIV_EQ : '.\\=' ;
EPOW_EQ : '.^=' | '.**=' ;

BREAK : 'break' ;
CATCH : 'catch' ;
CASE : 'case' ;
CLEAR : 'clear' ;
CONTINUE : 'continue' ;
DO : 'do' ;
ELSE : 'else' ;
ELSEIF : 'elseif' ;
END : 'end' ;
FOR : 'for' ;
FCN : 'function' ;
GLOBAL : 'global' ;
HERMITIAN : 'hermitian' ;
UNWIND : 'unwind' ;
CLEANUP : 'cleanup' ;
GET : 'get' ;
SET : 'set' ;
PROPERTIES : 'properties' ;
EVENTS : 'events' ;
METHODS : 'methods' ;
ENUMERATION : 'enumeration' ;
IF : 'if' ;
OTHERWISE : 'otherwise' ;
PARFOR : 'parfor' ;
PERSISTENT : 'persistent' ;
FUNC_RET : 'return' ;
SWITCH : 'switch' ;
TRY : 'try' ;
UNTIL : 'until' ;
WHILE : 'while' ;

SQ_STRING : '\'' ( ~ '\'' | '\'\'' ) * '\'' { CheckQuote("STRING_LITERAL") }? ;
DQ_STRING : '"' ( ~ '"' | '""' ) * '"' ;
NAME : Name ;
SUPERCLASSREF : Name* ('.' Name)* ;
fragment Name : [_$a-zA-Z] [_$a-zA-Z0-9]* ;
NUM : Number ;
IMAG_NUM : Number Im ;
COMMENT : (LineComment | BlockComment) -> channel(COMMENT_CHANNEL) ;
fragment Cchar : [#%] ;
fragment LineComment : Cchar ~ [\r\n]* ;
fragment BlockComment : '#{' .*? ('#}' | EOF) | '%{' .*? ('%}' | EOF) ;
fragment D : [0-9] ;
fragment D_ : [0-9_] ;
fragment S : [ \t] ;
fragment Nl : [\r\n] | ('\r' '\n') ;
fragment Im : [iIjJ] ;
fragment Expon : [DdEe] [+\-]? D D_* ;
fragment Numbin : '0' [bB] [01_]+ ;
fragment Numhex : '0' [xX] [0-9a-fA-F_]* ;
fragment Numreal : (D D_* '.'? D_* Expon?) | ('.' D D_* Expon? );
fragment Number : Numreal | Numhex | Numbin ;
fragment Sign : ('+' | '-') ;
CR : Nl+ ;
WS : S+ -> skip ;
