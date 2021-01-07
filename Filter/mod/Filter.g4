grammar Filter;

/* Parser rules */

filter
    : ( (LPAREN logicalExpression RPAREN) | logicalExpression ) EOF
    ;

logicalExpression
    : booleanAndExpression ( OR booleanAndExpression )*
    ;

booleanAndExpression
    :  simpleFilter (AND simpleFilter)*
    ;

simpleFilter
    : STR
    | NOT simpleFilter 
    | key=STR op=EQ value=(STR | DECIMAL)
    | key=STR op=NE value=(STR | DECIMAL)
    | key=STR op=GT value=(STR | DECIMAL)
    | key=STR op=GE value=(STR | DECIMAL)
    | key=STR op=LT value=(STR | DECIMAL)
    | key=STR op=LE value=(STR | DECIMAL)
    | key=STR op=IN referenceValue
    | key=STR op=NOT op=IN referenceValue
    | key=STR op=BETWEEN fromValue=(STR | DECIMAL) AND toValue=(STR | DECIMAL)
    | key=STR NOT BETWEEN fromValue=(STR | DECIMAL) AND toValue=(STR | DECIMAL)
    | key=STR op=IN array
    | key=STR NOT IN array
    | key=STR op=CONTAINS value=(STR | DECIMAL)
    | key=STR NOT CONTAINS value=(STR | DECIMAL)
    | DOLLAR LCURLY FILTER SEP id=(DECIMAL | STR) SEP name=STR RCURLY
    ;

array
    : LBRACKET (arrayItem SEP*)+ RBRACKET
    ;

arrayItem
    : value=(STR | DECIMAL)
    | referenceValue
    ;

referenceValue
    : DOLLAR LCURLY type=LIST SEP id=(STR | DECIMAL) SEP name=(STR | DECIMAL) RCURLY
    ;


/* Lexer Rules*/

SEP: ',' | ';' ;
LIST : 'List' ;
FILTER: 'Filter' ;
DOLLAR: '$';
LCURLY: '{';
RCURLY: '}';
LPAREN: '(';
RPAREN: ')';
LBRACKET: '[';
RBRACKET: ']';
GT: '>';
GE: '>=';
LT: '<';
LE: '<=';
EQ: '=';
NE: '!=';
NOT: '!' | 'not' | 'NOT';
AND: 'AND' | 'and';
OR: 'OR' | 'or';
IN: 'in' | 'IN';
BETWEEN: 'between' | 'BETWEEN';
CONTAINS: 'contains' | 'CONTAINS';
DECIMAL: '-'? DIGIT+ ( '.' DIGIT+ )? ;
fragment DIGIT: [0-9] ;
STR: ALPHANUMERIC+ | '"' (ALPHANUMERIC | [ ] | '""')+ '"';
fragment ALPHANUMERIC: [a-z0-9A-Z!.:@#$%&^*'+/?_`~-];
WS  : [ \t\r\n\f]+ -> skip ;
