grammar Yes2;

file : yes EOF
    ;

yes : yes YES
    | YES
    ;

YES : 'yes'
    ;

WS : [ \t\r\n]+ -> skip
    ;
