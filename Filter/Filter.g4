grammar Filter;

/* Parser rules */

filter

    :   LPAREN logicalExpression RPAREN   #ParenthesizedFilter
    |   logicalExpression EOF           #CmopositeFilterHash;

logicalExpression
       : booleanAndExpression ( OR booleanAndExpression )*                     #LogExp
       ;

booleanAndExpression
    :  simpleFilter ((AND) ? simpleFilter )*                                  #SimF
    ;

simpleFilter
    :NOT simpleFilter                                                        #NegateFilter
    | key=STR op=EQ value=(STR | DECIMAL)                                   #EqualsFilter
    |   key=STR op=NE value=(STR | DECIMAL)                                         #NotEqualsFilter
    |   key=STR op=GT value=(STR | DECIMAL)                                         #GreaterThanFilter
    |   key=STR op=GE value=(STR | DECIMAL)                            #GreaterThanEqualsFilter
    |   key=STR op=LT value=(STR | DECIMAL)                                         #LessThanFilter
    |   key=STR op=LE value=(STR | DECIMAL)                                         #LessThanEqualsFilter
    |   key=STR op=IN referenceValue                                                #InReferenceFilter
    |   key=STR op=NOT op=IN referenceValue                                         #NotInReferenceFilter
    |   key=STR op=BETWEEN fromValue=(STR | DECIMAL) AND toValue=(STR | DECIMAL)    #RangeFilter
    |   key=STR NOT BETWEEN fromValue=(STR | DECIMAL) AND toValue=(STR | DECIMAL)   #OutsideRangeFilter
    |   key=STR op=IN array                                                         #InArrayFilter
    |   key=STR NOT IN array                                                        #NotInArrayFilter
    |   key=STR op=CONTAINS value=(STR | DECIMAL)                                   #ContainsFilter
    |   key=STR NOT CONTAINS value=(STR | DECIMAL)                                  #NotContainsFilter
    |   DOLLAR LCURLY FILTER SEP id=(DECIMAL | STR) SEP name=STR RCURLY             #ReferenceFilter;

array
    :   LBRACKET (arrayItem SEP*)+ RBRACKET ;

arrayItem
    :   value=(STR | DECIMAL)
    |   referenceValue ;

referenceValue
    :   DOLLAR LCURLY type=LIST SEP id=(STR | DECIMAL) SEP name=(STR | DECIMAL) RCURLY ;


/* Lexer Rules*/

SEP: 
',' | ';';

LIST
: 'List' ;

FILTER: 'Filter';

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
AND_MUST: 'AND';

DECIMAL: '-'? DIGIT+ ( '.' DIGIT+ )? ;
fragment DIGIT: [0-9] ;
STR: ALPHANUMERIC+ | '"' (ALPHANUMERIC | [ ] | '""')+ '"';
fragment ALPHANUMERIC: [a-z0-9A-Z!.:@#$%&^*'+/?_`~-];

WS  : [ \t\r\n\f]+ -> skip ;
