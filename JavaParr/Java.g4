/*
 [The "BSD licence"]
 Copyright (c) 2013 Terence Parr, Sam Harwell
 Copyright (c) 2017 Ivan Kochurkin (upgrade to Java 8)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

grammar Java;

// ANNOTATIONS


compilationUnit
    : packageDeclaration? importDeclaration* typeDeclaration* EOF
    ;

packageDeclaration
    : annotation* PACKAGE qualifiedName ';'
    ;
annotation
    : '@' qualifiedName ('(' (elementValuePairs|elementValue)? ')')?
    ;

qualifiedName
    : IDENTIFIER ('.' IDENTIFIER)*
    ;

elementValuePairs
    : elementValuePair (',' elementValuePair)*
    ;

elementValuePair
    : IDENTIFIER '=' elementValue
    ;

elementValue
    : expression
    | annotation
    | elementValueArrayInitializer
    ;

expression
    : primary
    | expression bop='.' (IDENTIFIER|methodCall|THIS|NEW nonWildcardTypeArguments? innerCreator|SUPER superSuffix|explicitGenericInvocation)
    | expression '[' expression ']'
    | methodCall
    | NEW creator
    | '(' typeType ')' expression
    | expression postfix= ('++'|'--')
    | prefix= ('+'|'-'|'++'|'--') expression
    | prefix= ('~'|'!') expression
    | expression bop= ('*'|'/'|'%') expression
    | expression bop= ('+'|'-') expression
    | expression ('<' '<'|'>' '>' '>'|'>' '>') expression
    | expression bop= ('<='|'>='|'>'|'<') expression
    | expression bop=INSTANCEOF typeType
    | expression bop= ('=='|'!=') expression
    | expression bop='&' expression
    | expression bop='^' expression
    | expression bop='|' expression
    | expression bop='&&' expression
    | expression bop='||' expression
    | <assoc=right> expression bop='?' expression ':' expression
    | <assoc=right> expression bop= ('='|'+='|'-='|'*='|'/='|'&='|'|='|'^='|'>>='|'>>>='|'<<='|'%=') expression
    | lambdaExpression // Java8

    // Java 8 methodReference
    | expression '::' typeArguments? IDENTIFIER
    | typeType '::' (typeArguments? IDENTIFIER|NEW)
    | classType '::' typeArguments? NEW
    ;

primary
    : '(' expression ')'
    | THIS
    | SUPER
    | literal
    | IDENTIFIER
    | typeTypeOrVoid '.' CLASS
    | nonWildcardTypeArguments (explicitGenericInvocationSuffix|THIS arguments)
    ;

literal
    : integerLiteral
    | floatLiteral
    | CHAR_LITERAL
    | STRING_LITERAL
    | BOOL_LITERAL
    | NULL_LITERAL
    ;

integerLiteral
    : DECIMAL_LITERAL
    | HEX_LITERAL
    | OCT_LITERAL
    | BINARY_LITERAL
    ;

floatLiteral
    : FLOAT_LITERAL
    | HEX_FLOAT_LITERAL
    ;

typeTypeOrVoid
    : typeType
    | VOID
    ;

typeType
    : annotation? (classOrInterfaceType|primitiveType) ('[' ']')*
    ;

classOrInterfaceType
    : IDENTIFIER typeArguments? ('.' IDENTIFIER typeArguments?)*
    ;

typeArguments
    : '<' typeArgument (',' typeArgument)* '>'
    ;

typeArgument
    : typeType
    | '?' ( (EXTENDS|SUPER) typeType)?
    ;

primitiveType
    : BOOLEAN
    | CHAR
    | BYTE
    | SHORT
    | INT
    | LONG
    | FLOAT
    | DOUBLE
    ;

nonWildcardTypeArguments
    : '<' typeList '>'
    ;

typeList
    : typeType (',' typeType)*
    ;

explicitGenericInvocationSuffix
    : SUPER superSuffix
    | IDENTIFIER arguments
    ;

superSuffix
    : arguments
    | '.' IDENTIFIER arguments?
    ;

arguments
    : '(' expressionList? ')'
    ;

expressionList
    : expression (',' expression)*
    ;

methodCall
    : IDENTIFIER '(' expressionList? ')'
    | THIS '(' expressionList? ')'
    | SUPER '(' expressionList? ')'
    ;

innerCreator
    : IDENTIFIER nonWildcardTypeArgumentsOrDiamond? classCreatorRest
    ;

nonWildcardTypeArgumentsOrDiamond
    : '<' '>'
    | nonWildcardTypeArguments
    ;

classCreatorRest
    : arguments classBody?
    ;

classBody
    : '{' classBodyDeclaration* '}'
    ;

classBodyDeclaration
    : ';'
    | STATIC? block
    | modifier* memberDeclaration
    ;

// STATEMENTS / BLOCKS

block
    : '{' blockStatement* '}'
    ;

blockStatement
    : localVariableDeclaration ';'
    | statement
    | localTypeDeclaration
    ;

localVariableDeclaration
    : variableModifier* typeType variableDeclarators
    ;

variableModifier
    : FINAL
    | annotation
    ;

variableDeclarators
    : variableDeclarator (',' variableDeclarator)*
    ;

variableDeclarator
    : variableDeclaratorId ('=' variableInitializer)?
    ;

variableDeclaratorId
    : IDENTIFIER ('[' ']')*
    ;

variableInitializer
    : arrayInitializer
    | expression
    ;

arrayInitializer
    : '{' (variableInitializer (',' variableInitializer)* (',')?)? '}'
    ;

statement
    : blockLabel=block
    | ASSERT expression (':' expression)? ';'
    | IF parExpression statement (ELSE statement)?
    | FOR '(' forControl ')' statement
    | WHILE parExpression statement
    | DO statement WHILE parExpression ';'
    | TRY block (catchClause+ finallyBlock?|finallyBlock)
    | TRY resourceSpecification block catchClause* finallyBlock?
    | SWITCH parExpression '{' switchBlockStatementGroup* switchLabel* '}'
    | SYNCHRONIZED parExpression block
    | RETURN expression? ';'
    | THROW expression ';'
    | BREAK IDENTIFIER? ';'
    | CONTINUE IDENTIFIER? ';'
    | SEMI
    | statementExpression=expression ';'
    | identifierLabel=IDENTIFIER ':' statement
    ;

// EXPRESSIONS

parExpression
    : '(' expression ')'
    ;

forControl
    : enhancedForControl
    | forInit? ';' expression? ';' forUpdate=expressionList?
    ;

enhancedForControl
    : variableModifier* typeType variableDeclaratorId ':' expression
    ;

forInit
    : localVariableDeclaration
    | expressionList
    ;

catchClause
    : CATCH '(' variableModifier* catchType IDENTIFIER ')' block
    ;

catchType
    : qualifiedName ('|' qualifiedName)*
    ;

finallyBlock
    : FINALLY block
    ;

resourceSpecification
    : '(' resources ';'? ')'
    ;

resources
    : resource (';' resource)*
    ;

resource
    : variableModifier* classOrInterfaceType variableDeclaratorId '=' expression
    ;

/** Matches cases then statements, both of which are mandatory.
 *  To handle empty cases at the end, we add switchLabel* to statement.
 */
    switchBlockStatementGroup
    : switchLabel+ blockStatement+
    ;

switchLabel
    : CASE (constantExpression=expression|enumConstantName=IDENTIFIER) ':'
    | DEFAULT ':'
    ;

localTypeDeclaration
    : classOrInterfaceModifier* (classDeclaration|interfaceDeclaration)
    | ';'
    ;

classOrInterfaceModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    | STATIC
    | ABSTRACT
    | FINAL    // FINAL for class only -- does not apply to interfaces
    | STRICTFP
    ;

classDeclaration
    : CLASS IDENTIFIER typeParameters? (EXTENDS typeType)? (IMPLEMENTS typeList)? classBody
    ;

typeParameters
    : '<' typeParameter (',' typeParameter)* '>'
    ;

typeParameter
    : annotation* IDENTIFIER (EXTENDS typeBound)?
    ;

typeBound
    : typeType ('&' typeType)*
    ;

interfaceDeclaration
    : INTERFACE IDENTIFIER typeParameters? (EXTENDS typeList)? interfaceBody
    ;

interfaceBody
    : '{' interfaceBodyDeclaration* '}'
    ;

interfaceBodyDeclaration
    : modifier* interfaceMemberDeclaration
    | ';'
    ;

modifier
    : classOrInterfaceModifier
    | NATIVE
    | SYNCHRONIZED
    | TRANSIENT
    | VOLATILE
    ;

interfaceMemberDeclaration
    : constDeclaration
    | interfaceMethodDeclaration
    | genericInterfaceMethodDeclaration
    | interfaceDeclaration
    | annotationTypeDeclaration
    | classDeclaration
    | enumDeclaration
    ;

constDeclaration
    : typeType constantDeclarator (',' constantDeclarator)* ';'
    ;

constantDeclarator
    : IDENTIFIER ('[' ']')* '=' variableInitializer
    ;

// see matching of [] comment in methodDeclaratorRest
// methodBody from Java8

interfaceMethodDeclaration
    : interfaceMethodModifier* (typeTypeOrVoid|typeParameters annotation* typeTypeOrVoid) IDENTIFIER formalParameters ('[' ']')* (THROWS qualifiedNameList)? methodBody
    ;

// Java8

interfaceMethodModifier
    : annotation
    | PUBLIC
    | ABSTRACT
    | DEFAULT
    | STATIC
    | STRICTFP
    ;

formalParameters
    : '(' formalParameterList? ')'
    ;

formalParameterList
    : formalParameter (',' formalParameter)* (',' lastFormalParameter)?
    | lastFormalParameter
    ;

formalParameter
    : variableModifier* typeType variableDeclaratorId
    ;

lastFormalParameter
    : variableModifier* typeType '...' variableDeclaratorId
    ;

qualifiedNameList
    : qualifiedName (',' qualifiedName)*
    ;

methodBody
    : block
    | ';'
    ;

genericInterfaceMethodDeclaration
    : typeParameters interfaceMethodDeclaration
    ;

annotationTypeDeclaration
    : '@' INTERFACE IDENTIFIER annotationTypeBody
    ;

annotationTypeBody
    : '{' (annotationTypeElementDeclaration)* '}'
    ;

annotationTypeElementDeclaration
    : modifier* annotationTypeElementRest
    | ';' // this is not allowed by the grammar, but apparently allowed by the actual compiler
    ;

annotationTypeElementRest
    : typeType annotationMethodOrConstantRest ';'
    | classDeclaration ';'?
    | interfaceDeclaration ';'?
    | enumDeclaration ';'?
    | annotationTypeDeclaration ';'?
    ;

annotationMethodOrConstantRest
    : annotationMethodRest
    | annotationConstantRest
    ;

annotationMethodRest
    : IDENTIFIER '(' ')' defaultValue?
    ;

defaultValue
    : DEFAULT elementValue
    ;

annotationConstantRest
    : variableDeclarators
    ;

enumDeclaration
    : ENUM IDENTIFIER (IMPLEMENTS typeList)? '{' enumConstants? ','? enumBodyDeclarations? '}'
    ;

enumConstants
    : enumConstant (',' enumConstant)*
    ;

enumConstant
    : annotation* IDENTIFIER arguments? classBody?
    ;

enumBodyDeclarations
    : ';' classBodyDeclaration*
    ;

memberDeclaration
    : methodDeclaration
    | genericMethodDeclaration
    | fieldDeclaration
    | constructorDeclaration
    | genericConstructorDeclaration
    | interfaceDeclaration
    | annotationTypeDeclaration
    | classDeclaration
    | enumDeclaration
    ;

/* We use rule this even for void methods which cannot have [] after parameters.
   This simplifies grammar and we can consider void to be a type, which
   renders the [] matching as a context-sensitive issue or a semantic check
   for invalid return type after parsing.
 */

methodDeclaration
    : typeTypeOrVoid IDENTIFIER formalParameters ('[' ']')* (THROWS qualifiedNameList)? methodBody
    ;

genericMethodDeclaration
    : typeParameters methodDeclaration
    ;

fieldDeclaration
    : typeType variableDeclarators ';'
    ;

constructorDeclaration
    : IDENTIFIER formalParameters (THROWS qualifiedNameList)? constructorBody=block
    ;

genericConstructorDeclaration
    : typeParameters constructorDeclaration
    ;

explicitGenericInvocation
    : nonWildcardTypeArguments explicitGenericInvocationSuffix
    ;

creator
    : nonWildcardTypeArguments createdName classCreatorRest
    | createdName (arrayCreatorRest|classCreatorRest)
    ;

createdName
    : IDENTIFIER typeArgumentsOrDiamond? ('.' IDENTIFIER typeArgumentsOrDiamond?)*
    | primitiveType
    ;

typeArgumentsOrDiamond
    : '<' '>'
    | typeArguments
    ;

arrayCreatorRest
    : '[' (']' ('[' ']')* arrayInitializer|expression ']' ('[' expression ']')* ('[' ']')*)
    ;

// Java8

lambdaExpression
    : lambdaParameters '->' lambdaBody
    ;

// Java8

lambdaParameters
    : IDENTIFIER
    | '(' formalParameterList? ')'
    | '(' IDENTIFIER (',' IDENTIFIER)* ')'
    ;

// Java8

lambdaBody
    : expression
    | block
    ;

classType
    : (classOrInterfaceType '.')? annotation* IDENTIFIER typeArguments?
    ;

elementValueArrayInitializer
    : '{' (elementValue (',' elementValue)*)? (',')? '}'
    ;

importDeclaration
    : IMPORT STATIC? qualifiedName ('.' '*')? ';'
    ;

typeDeclaration
    : classOrInterfaceModifier* (classDeclaration|enumDeclaration|interfaceDeclaration|annotationTypeDeclaration)
    | ';'
    ;

ABSTRACT
    : 'abstract'
    ;

ASSERT
    : 'assert'
    ;

BOOLEAN
    : 'boolean'
    ;

BREAK
    : 'break'
    ;

BYTE
    : 'byte'
    ;

CASE
    : 'case'
    ;

CATCH
    : 'catch'
    ;

CHAR
    : 'char'
    ;

CLASS
    : 'class'
    ;

CONST
    : 'const'
    ;

CONTINUE
    : 'continue'
    ;

DEFAULT
    : 'default'
    ;

DO
    : 'do'
    ;

DOUBLE
    : 'double'
    ;

ELSE
    : 'else'
    ;

ENUM
    : 'enum'
    ;

EXTENDS
    : 'extends'
    ;

FINAL
    : 'final'
    ;

FINALLY
    : 'finally'
    ;

FLOAT
    : 'float'
    ;

FOR
    : 'for'
    ;

IF
    : 'if'
    ;

GOTO
    : 'goto'
    ;

IMPLEMENTS
    : 'implements'
    ;

IMPORT
    : 'import'
    ;

INSTANCEOF
    : 'instanceof'
    ;

INT
    : 'int'
    ;

INTERFACE
    : 'interface'
    ;

LONG
    : 'long'
    ;

NATIVE
    : 'native'
    ;

NEW
    : 'new'
    ;

PACKAGE
    : 'package'
    ;

PRIVATE
    : 'private'
    ;

PROTECTED
    : 'protected'
    ;

PUBLIC
    : 'public'
    ;

RETURN
    : 'return'
    ;

SHORT
    : 'short'
    ;

STATIC
    : 'static'
    ;

STRICTFP
    : 'strictfp'
    ;

SUPER
    : 'super'
    ;

SWITCH
    : 'switch'
    ;

SYNCHRONIZED
    : 'synchronized'
    ;

THIS
    : 'this'
    ;

THROW
    : 'throw'
    ;

THROWS
    : 'throws'
    ;

TRANSIENT
    : 'transient'
    ;

TRY
    : 'try'
    ;

VOID
    : 'void'
    ;

VOLATILE
    : 'volatile'
    ;

WHILE
    : 'while'
    ;

// Literals

DECIMAL_LITERAL
    : ('0'|[1-9] (Digits?|'_'+ Digits)) [lL]?
    ;

HEX_LITERAL
    : '0' [xX] [0-9a-fA-F] ([0-9a-fA-F_]* [0-9a-fA-F])? [lL]?
    ;

OCT_LITERAL
    : '0' '_'* [0-7] ([0-7_]* [0-7])? [lL]?
    ;

BINARY_LITERAL
    : '0' [bB] [01] ([01_]* [01])? [lL]?
    ;

FLOAT_LITERAL
    : (Digits '.' Digits?|'.' Digits) ExponentPart? [fFdD]?
    | Digits (ExponentPart [fFdD]?|[fFdD])
    ;

HEX_FLOAT_LITERAL
    : '0' [xX] (HexDigits '.'?|HexDigits? '.' HexDigits) [pP] [+-]? Digits [fFdD]?
    ;

BOOL_LITERAL
    : 'true'|'false'
    ;

CHAR_LITERAL
    : '\'' (~['\\\r\n]|EscapeSequence) '\''
    ;

STRING_LITERAL
    : '"' (~["\\\r\n]|EscapeSequence)* '"'
    ;

NULL_LITERAL
    : 'null'
    ;

// Separators

LPAREN
    : '('
    ;

RPAREN
    : ')'
    ;

LBRACE
    : '{'
    ;

RBRACE
    : '}'
    ;

LBRACK
    : '['
    ;

RBRACK
    : ']'
    ;

SEMI
    : ';'
    ;

COMMA
    : ','
    ;

DOT
    : '.'
    ;

// Operators

ASSIGN
    : '='
    ;

GT
    : '>'
    ;

LT
    : '<'
    ;

BANG
    : '!'
    ;

TILDE
    : '~'
    ;

QUESTION
    : '?'
    ;

COLON
    : ':'
    ;

EQUAL
    : '=='
    ;

LE
    : '<='
    ;

GE
    : '>='
    ;

NOTEQUAL
    : '!='
    ;

AND
    : '&&'
    ;

OR
    : '||'
    ;

INC
    : '++'
    ;

DEC
    : '--'
    ;

ADD
    : '+'
    ;

SUB
    : '-'
    ;

MUL
    : '*'
    ;

DIV
    : '/'
    ;

BITAND
    : '&'
    ;

BITOR
    : '|'
    ;

CARET
    : '^'
    ;

MOD
    : '%'
    ;

ADD_ASSIGN
    : '+='
    ;

SUB_ASSIGN
    : '-='
    ;

MUL_ASSIGN
    : '*='
    ;

DIV_ASSIGN
    : '/='
    ;

AND_ASSIGN
    : '&='
    ;

OR_ASSIGN
    : '|='
    ;

XOR_ASSIGN
    : '^='
    ;

MOD_ASSIGN
    : '%='
    ;

LSHIFT_ASSIGN
    : '<<='
    ;

RSHIFT_ASSIGN
    : '>>='
    ;

URSHIFT_ASSIGN
    : '>>>='
    ;

// Java 8 tokens

ARROW
    : '->'
    ;

COLONCOLON
    : '::'
    ;

// Additional symbols not defined in the lexical specification

AT
    : '@'
    ;

ELLIPSIS
    : '...'
    ;

// Whitespace and comments

WS
    : [ \t\r\n\u000C]+ -> channel(HIDDEN)
    ;

COMMENT
    : '/*' .*? '*/'                         -> channel(HIDDEN)
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> channel(HIDDEN)
    ;

// Identifiers

IDENTIFIER
    : Letter LetterOrDigit*
    ;

// Fragment rules

fragment
ExponentPart
    : [eE] [+-]? Digits
    ;

fragment
EscapeSequence
    : '\\' [btnfr"'\\]
    | '\\' ([0-3]? [0-7])? [0-7]
    | '\\' 'u'+ HexDigit HexDigit HexDigit HexDigit
    ;

fragment
HexDigits
    : HexDigit ((HexDigit|'_')* HexDigit)?
    ;

fragment
HexDigit
    : [0-9a-fA-F]
    ;

fragment
Digits
    : [0-9] ([0-9_]* [0-9])?
    ;

fragment
LetterOrDigit
    : Letter|[0-9]
    ;

fragment
Letter
    : [a-zA-Z$_] // these are the "java letters" below 0x7F
    | ~[\u0000-\u007F\uD800-\uDBFF] // covers all characters above 0x7F which are not a surrogate
    | [\uD800-\uDBFF] [\uDC00-\uDFFF] // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
    ;