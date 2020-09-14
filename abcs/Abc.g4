// Template generated code from Antlr4BuildTasks.Template v 8.1
grammar Abc;

file : (a b c)* EOF;
a : A;
b : B;
c : C;
A : 'a'+;
B : 'b'+;
C : 'c'+;
WS : [ \r\n\t] + -> skip ;
