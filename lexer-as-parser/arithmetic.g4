// Note: Left recursion is now allowed in the lexer rules ("The following sets of rules are mutually left-recursive").
// This grammar falls back to the older version 2 style.
// Template generated code from Antlr4BuildTasks.Template v 2.1
grammar arithmetic;

file : EXPR (SEMI EXPR)*;

EXPR: Expression;

fragment Expression
      :     AdditiveExpression
      ;

fragment AdditiveExpression
      :     MultiplicativeExpression ((Plus | Minus) MultiplicativeExpression)*
      ;

fragment MultiplicativeExpression
      :     PowerExpression ( (Times | Div) PowerExpression )*
      ;

fragment PowerExpression  
      :     UnaryExpression ( Pow UnaryExpression)*
      ;

fragment UnaryExpression
      :     Minus UnaryExpression
      |     PrimaryExpression
      ;

fragment PrimaryExpression
      :     Atom
      |     Lparen AdditiveExpression Rparen
      ;

fragment Atom
   : Scientific
   | Variable
   ;

fragment Scientific
   : FWS? SCIENTIFIC_NUMBER
   ;

fragment Variable
   : FWS? VARIABLE
   ;

fragment Plus
   : FWS? PLUS
   ;

fragment Minus
   : FWS? MINUS
   ;

fragment Times
   : FWS? TIMES
   ;

fragment Div
   : FWS? DIV
   ;

fragment Pow
   : FWS? POW
   ;

fragment Lparen
   : FWS? LPAREN
   ;

fragment Rparen
   : FWS? RPAREN
   ;

fragment VARIABLE
   : VALID_ID_START VALID_ID_CHAR*
   ;

fragment VALID_ID_START
   : ('a' .. 'z') | ('A' .. 'Z') | '_'
   ;


fragment VALID_ID_CHAR
   : VALID_ID_START | ('0' .. '9')
   ;

//The NUMBER part gets its potential sign from "(PLUS | MINUS)* atom" in the expression rule
fragment SCIENTIFIC_NUMBER
   : NUMBER (E SIGN? UNSIGNED_INTEGER)?
   ;

fragment NUMBER
   : ('0' .. '9') + ('.' ('0' .. '9') +)?
   ;

fragment UNSIGNED_INTEGER
   : ('0' .. '9')+
   ;


fragment E
   : 'E' | 'e'
   ;


fragment SIGN
   : ('+' | '-')
   ;


fragment LPAREN
   : '('
   ;


fragment RPAREN
   : ')'
   ;


fragment PLUS
   : '+'
   ;


fragment MINUS
   : '-'
   ;


fragment TIMES
   : '*'
   ;


fragment DIV
   : '/'
   ;


fragment GT
   : '>'
   ;


fragment LT
   : '<'
   ;


fragment EQ
   : '='
   ;


fragment POINT
   : '.'
   ;


fragment POW
   : '^'
   ;

SEMI
   : ';'
   ;

WS
   : [ \r\n\t] + -> skip
   ;

fragment FWS
   : [ \r\n\t]+
   ;
