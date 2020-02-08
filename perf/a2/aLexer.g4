lexer grammar aLexer;

options {
    superClass = BaseLexer;
}

channels {
	OFF_CHANNEL		// non-default channel for whitespace and comments
}

A : 'a' ;
B : {allow_b}? 'b';

WS
   : [ \r\n\t] + -> channel(OFF_CHANNEL)
   ;