grammar Yes1;

file : yes EOF
    ;

yes : YES yes
    | YES
    ;

YES : 'yes'
    ;

WS : [ \t\r\n]+ -> skip
    ;
