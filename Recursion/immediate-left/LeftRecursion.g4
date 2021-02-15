grammar LeftRecursion;

expression
   :  expression (PLUS | MINUS) expression
   |  LPAREN expression RPAREN
   |  (PLUS | MINUS)* atom
   ;

atom : NUMBER ;
NUMBER : ('0' .. '9')+ ('.' ('0' .. '9') +)? ;
LPAREN : '(' ;
RPAREN : ')' ;
PLUS : '+' ;
MINUS : '-' ;
WS : [ \r\n\t] + -> skip ;
