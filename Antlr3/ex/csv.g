grammar csv;

file
    : record (NEWLINE record)* EOF
    ;

record
    : (quoted_field | unquoted_field) (COMMA (quoted_field | unquoted_field))*
    ;

quoted_field
    : DQUOTE
    ( CHAR
    | COMMA
    | DQUOTE DQUOTE
    | NEWLINE
    )* DQUOTE
    ;

unquoted_field
    : CHAR*
    ;

CHAR
    : '\u0000' .. '\u0009'
    | '\u000b' .. '\u000c'
    | '\u000e' .. '\u0021'
    | '\u0023' .. '\u002b'
    | '\u002d' .. '\uffff'
    ;

COMMA
    : '\u002c'
    ;

DQUOTE
    : '\u0022'
    ;

NEWLINE
    : '\u000d'? '\u000a'    // DOS/Windows(\r\n) + Unix(\n)
    | '\u000d'              // Mac OS 9 and earlier(\r)
    ;
