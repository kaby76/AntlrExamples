grammar Yes3;

file : yes EOF
    ;

yes : YES+
    ;

YES : 'yes'
    ;

WS : [ \t\r\n]+ -> skip
    ;
