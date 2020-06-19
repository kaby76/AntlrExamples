/*
BSD License
Copyright (c) 2013, Tom Everett
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of Tom Everett nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*
* Grammar based on yacc-keable for matlab by Danny Luk 12/1995
*
* http://www.angelfire.com/ar/CompiladoresUCSE/images/MATLAB.zip
*/

lexer grammar matlabLexer;

options { superClass=LexBase; }

LP : '(';
RP : ')';
LB :'[';
RB : ']';
COLON : ':';
COMMA : ',';
PLUS : '+';
MINUS : '-';
SQUIGGLE : '~';
STAR : '*';
SL : '/';
BSL : '\\';
UP : '^';
GT : '>';
LT : '<';
AMP : '&';
P : '|';
EQ : '=';
SEMI : ';';
ARRAYMUL : '.*' ;
ARRAYDIV : '.\\' ;
ARRAYRDIV : './' ;
ARRAYPOW : '.^' ;
BREAK : 'break' ;
RETURN : 'return' ;
FUNCTION : 'function' ;
FOR : 'for' ;
WHILE : 'while' ;
END : 'end' ;
GLOBAL : 'global' ;
IF : 'if' ;
CLEAR : 'clear' ;
ELSE : 'else' ;
ELSEIF : 'elseif' ;
LE_OP : '<=' ;
GE_OP : '>=' ;
EQ_OP : '==' ;
NE_OP : '~=' ;
TRANSPOSE : 'transpose' ;
NCTRANSPOSE : '.\'' ;
SQ : '\'' { CanBeTranspose() }? ;
STRING_LITERAL : '\'' ( ~ '\'' | '\'\'' ) * '\'' ;
IDENTIFIER : [a-zA-Z] [a-zA-Z0-9_]* ;
CONSTANT : NUMBER (E SIGN? NUMBER)? ;
fragment NUMBER : ('0' .. '9') + ('.' ('0' .. '9') +)? ;
fragment E : 'E' | 'e' ;
fragment SIGN : ('+' | '-') ;
CR : [\r\n] + ;
WS : [ \t] + -> skip ;
