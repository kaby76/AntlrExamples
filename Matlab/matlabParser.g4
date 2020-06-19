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

parser grammar matlabParser;

options { tokenVocab=matlabLexer; }

primary_expression
   : IDENTIFIER
   | CONSTANT
   | STRING_LITERAL
   | LP expression RP
   | LB RB
   | LB array_list RB
   ;

postfix_expression
   : primary_expression
   | array_expression
   | postfix_expression TRANSPOSE
   | postfix_expression NCTRANSPOSE
   ;

index_expression
   : COLON
   | expression
   ;

index_expression_list
   : index_expression
   | index_expression_list COMMA index_expression
   ;

array_expression
   : IDENTIFIER LP index_expression_list RP
   ;

unary_expression
   : postfix_expression
   | unary_operator postfix_expression
   | unary_expression SQ
   ;

unary_operator
   : PLUS
   | MINUS
   | SQUIGGLE
   ;

multiplicative_expression
   : unary_expression
   | multiplicative_expression STAR unary_expression
   | multiplicative_expression SL unary_expression
   | multiplicative_expression BSL unary_expression
   | multiplicative_expression UP unary_expression
   | multiplicative_expression ARRAYMUL unary_expression
   | multiplicative_expression ARRAYDIV unary_expression
   | multiplicative_expression ARRAYRDIV unary_expression
   | multiplicative_expression ARRAYPOW unary_expression
   ;

additive_expression
   : multiplicative_expression
   | additive_expression PLUS multiplicative_expression
   | additive_expression MINUS multiplicative_expression
   ;

relational_expression
   : additive_expression
   | relational_expression LT additive_expression
   | relational_expression GT additive_expression
   | relational_expression LE_OP additive_expression
   | relational_expression GE_OP additive_expression
   ;

equality_expression
   : relational_expression
   | equality_expression EQ_OP relational_expression
   | equality_expression NE_OP relational_expression
   ;

and_expression
   : equality_expression
   | and_expression AMP equality_expression
   ;

or_expression
   : and_expression
   | or_expression P and_expression
   ;

expression
   : or_expression
   | expression COLON or_expression
   ;

assignment_expression
   : postfix_expression EQ expression
   ;

eostmt
   : COMMA
   | SEMI
   | CR
   ;

statement
   : global_statement
   | clear_statement
   | assignment_statement
   | expression_statement
   | selection_statement
   | iteration_statement
   | jump_statement
   ;

statement_list
   : statement
   | statement_list statement
   ;

identifier_list
   : IDENTIFIER
   | identifier_list IDENTIFIER
   ;

global_statement
   : GLOBAL identifier_list eostmt
   ;

clear_statement
   : CLEAR identifier_list eostmt
   ;

expression_statement
   : eostmt
   | expression eostmt
   ;

assignment_statement
   : assignment_expression eostmt
   ;

array_element
   : expression
   | expression_statement
   ;

array_list
   : array_element
   | array_list array_element
   ;

selection_statement
   : IF expression statement_list END eostmt
   | IF expression statement_list ELSE statement_list END eostmt
   | IF expression statement_list elseif_clause END eostmt
   | IF expression statement_list elseif_clause ELSE statement_list END eostmt
   ;

elseif_clause
   : ELSEIF expression statement_list
   | elseif_clause ELSEIF expression statement_list
   ;

iteration_statement
   : WHILE expression statement_list END eostmt
   | FOR IDENTIFIER EQ expression statement_list END eostmt
   | FOR LP IDENTIFIER EQ expression RP statement_list END eostmt
   ;

jump_statement
   : BREAK eostmt
   | RETURN eostmt
   ;

translation_unit
   : statement_list
   | FUNCTION function_declare eostmt statement_list
   ;

func_ident_list
   : IDENTIFIER
   | func_ident_list COMMA IDENTIFIER
   ;

func_return_list
   : IDENTIFIER
   | LB func_ident_list RB
   ;

function_declare_lhs
   : IDENTIFIER
   | IDENTIFIER LP RP
   | IDENTIFIER LP func_ident_list RP
   ;

function_declare
   : function_declare_lhs
   | func_return_list EQ function_declare_lhs
   ;
