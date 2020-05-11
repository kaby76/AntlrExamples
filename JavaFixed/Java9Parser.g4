/*
 * [The "BSD license"]
 *  Copyright (c) 2014 Terence Parr
 *  Copyright (c) 2014 Sam Harwell
 *  Copyright (c) 2017 Chan Chung Kwong
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * A Java 8 grammar for ANTLR 4 derived from the Java Language Specification
 * chapter 19.
 *
 * NOTE: This grammar results in a generated parser that is much slower
 *       than the Java 7 grammar in the grammars-v4/java directory. This
 *     one is, however, extremely close to the spec.
 *
 * You can test with
 *
 *  $ antlr4 Java9.g4
 *  $ javac *.java
 *  $ grun Java9 compilationUnit *.java
 *
 * Or,
~/antlr/code/grammars-v4/java9 $ java Test .
/Users/parrt/antlr/code/grammars-v4/java9/./Java9BaseListener.java
/Users/parrt/antlr/code/grammars-v4/java9/./Java9Lexer.java
/Users/parrt/antlr/code/grammars-v4/java9/./Java9Listener.java
/Users/parrt/antlr/code/grammars-v4/java9/./Java9Parser.java
/Users/parrt/antlr/code/grammars-v4/java9/./Test.java
Total lexer+parser time 30844ms.
~/antlr/code/grammars-v4/java9 $ java Test examples/module-info.java
/home/kwong/projects/grammars-v4/java9/examples/module-info.java
Total lexer+parser time 914ms.
~/antlr/code/grammars-v4/java9 $ java Test examples/TryWithResourceDemo.java
/home/kwong/projects/grammars-v4/java9/examples/TryWithResourceDemo.java
Total lexer+parser time 3634ms.
~/antlr/code/grammars-v4/java9 $ java Test examples/helloworld.java
/home/kwong/projects/grammars-v4/java9/examples/helloworld.java
Total lexer+parser time 2497ms.

 */

parser grammar Java9Parser;

options {
tokenVocab=Java9Lexer;
superClass = ParserAdaptor;
}


compilationUnit
    : packageDeclaration? importDeclaration* typeDeclaration* EOF
    | modularCompilation
    ;

packageDeclaration
    : annotation* PACKAGE packageName SEMI
    ;

annotation
    : normalAnnotation
    | markerAnnotation
    | singleElementAnnotation
    ;

normalAnnotation
    : AT typeName LPAREN elementValuePairList? RPAREN
    ;

typeName
    : Identifier
    | packageOrTypeName DOT Identifier
    ;

// LEXER

xxx
    : Identifier
    | TO
    | MODULE
    | OPEN
    | WITH
    | PROVIDES
    | USES
    | OPENS
    | REQUIRES
    | EXPORTS
    ;

packageOrTypeName
    : Identifier
    | packageOrTypeName DOT Identifier
    ;

elementValuePairList
    : elementValuePair (COMMA elementValuePair)*
    ;

elementValuePair
    : Identifier ASSIGN elementValue
    ;

elementValue
    : conditionalExpression
    | elementValueArrayInitializer
    | annotation
    ;

conditionalExpression
    : conditionalOrExpression
    | conditionalOrExpression QUESTION expression COLON (conditionalExpression|lambdaExpression)
    ;

conditionalOrExpression
    : conditionalAndExpression
    | conditionalOrExpression OR conditionalAndExpression
    ;

conditionalAndExpression
    : inclusiveOrExpression
    | conditionalAndExpression AND inclusiveOrExpression
    ;

inclusiveOrExpression
    : exclusiveOrExpression
    | inclusiveOrExpression BITOR exclusiveOrExpression
    ;

exclusiveOrExpression
    : andExpression
    | exclusiveOrExpression CARET andExpression
    ;

andExpression
    : equalityExpression
    | andExpression BITAND equalityExpression
    ;

equalityExpression
    : relationalExpression
    | equalityExpression EQUAL relationalExpression
    | equalityExpression NOTEQUAL relationalExpression
    ;

relationalExpression
    : shiftExpression
    | relationalExpression LT shiftExpression
    | relationalExpression GT shiftExpression
    | relationalExpression LE shiftExpression
    | relationalExpression GE shiftExpression
    | relationalExpression INSTANCEOF referenceType
    ;

shiftExpression
    : additiveExpression
    | shiftExpression LT LT additiveExpression
    | shiftExpression GT GT additiveExpression
    | shiftExpression GT GT GT additiveExpression
    ;

additiveExpression
    : multiplicativeExpression
    | additiveExpression ADD multiplicativeExpression
    | additiveExpression SUB multiplicativeExpression
    ;

multiplicativeExpression
    : unaryExpression
    | multiplicativeExpression MUL unaryExpression
    | multiplicativeExpression DIV unaryExpression
    | multiplicativeExpression MOD unaryExpression
    ;

unaryExpression
    : preIncrementExpression
    | preDecrementExpression
    | ADD unaryExpression
    | SUB unaryExpression
    | unaryExpressionNotPlusMinus
    ;

preIncrementExpression
    : INC unaryExpression
    ;

preDecrementExpression
    : DEC unaryExpression
    ;

unaryExpressionNotPlusMinus
    : postfixExpression
    | TILDE unaryExpression
    | BANG unaryExpression
    | castExpression
    ;

/*postfixExpression
    :   primary
    |   expressionName
    |   postIncrementExpression
    |   postDecrementExpression
    ;
*/

postfixExpression
    : (primary|expressionName) (postIncrementExpression_lf_postfixExpression|postDecrementExpression_lf_postfixExpression)*
    ;

/*
 * Productions from §15 (Expressions)
 */

/*primary
    :   primaryNoNewArray
    |   arrayCreationExpression
    ;
*/

primary
    : (primaryNoNewArray_lfno_primary|arrayCreationExpression) (primaryNoNewArray_lf_primary)*
    ;

primaryNoNewArray_lfno_primary
    : literal
    | typeName (LBRACK RBRACK)* DOT CLASS
    | unannPrimitiveType (LBRACK RBRACK)* DOT CLASS
    | VOID DOT CLASS
    | THIS
    | typeName DOT THIS
    | LPAREN expression RPAREN
    | classInstanceCreationExpression_lfno_primary
    | fieldAccess_lfno_primary
    | arrayAccess_lfno_primary
    | methodInvocation_lfno_primary
    | methodReference_lfno_primary
    ;

literal
    : IntegerLiteral
    | FloatingPointLiteral
    | BooleanLiteral
    | CharacterLiteral
    | StringLiteral
    | NullLiteral
    ;

unannPrimitiveType
    : numericType
    | BOOLEAN
    ;

numericType
    : integralType
    | floatingPointType
    ;

integralType
    : BYTE
    | SHORT
    | INT
    | LONG
    | CHAR
    ;

floatingPointType
    : FLOAT
    | DOUBLE
    ;

expression
    : lambdaExpression
    | assignmentExpression
    ;

lambdaExpression
    : lambdaParameters ARROW lambdaBody
    ;

lambdaParameters
    : Identifier
    | LPAREN formalParameterList? RPAREN
    | LPAREN inferredFormalParameterList RPAREN
    ;

formalParameterList
    : formalParameters COMMA lastFormalParameter
    | lastFormalParameter
    | receiverParameter
    ;

formalParameters
    : formalParameter (COMMA formalParameter)*
    | receiverParameter (COMMA formalParameter)*
    ;

formalParameter
    : variableModifier* unannType variableDeclaratorId
    ;

variableModifier
    : annotation
    | FINAL
    ;

unannType
    : unannPrimitiveType
    | unannReferenceType
    ;

unannReferenceType
    : unannClassOrInterfaceType
    | unannTypeVariable
    | unannArrayType
    ;

/*unannClassOrInterfaceType
    :   unannClassType
    |   unannInterfaceType
    ;
*/

unannClassOrInterfaceType
    : (unannClassType_lfno_unannClassOrInterfaceType|unannInterfaceType_lfno_unannClassOrInterfaceType) (unannClassType_lf_unannClassOrInterfaceType|unannInterfaceType_lf_unannClassOrInterfaceType)*
    ;

unannClassType_lfno_unannClassOrInterfaceType
    : Identifier typeArguments?
    ;

typeArguments
    : LT typeArgumentList GT
    ;

typeArgumentList
    : typeArgument (COMMA typeArgument)*
    ;

typeArgument
    : referenceType
    | wildcard
    ;

referenceType
    : classOrInterfaceType
    | typeVariable
    | arrayType
    ;

/*classOrInterfaceType
    :   classType
    |   interfaceType
    ;
*/

classOrInterfaceType
    : (classType_lfno_classOrInterfaceType|interfaceType_lfno_classOrInterfaceType) (classType_lf_classOrInterfaceType|interfaceType_lf_classOrInterfaceType)*
    ;

classType_lfno_classOrInterfaceType
    : annotation* Identifier typeArguments?
    ;

interfaceType_lfno_classOrInterfaceType
    : classType_lfno_classOrInterfaceType
    ;

classType_lf_classOrInterfaceType
    : DOT annotation* Identifier typeArguments?
    ;

interfaceType_lf_classOrInterfaceType
    : classType_lf_classOrInterfaceType
    ;

typeVariable
    : annotation* Identifier
    ;

arrayType
    : primitiveType dims
    | classOrInterfaceType dims
    | typeVariable dims
    ;

/*
 * Productions from §4 (Types, Values, and Variables)
 */

primitiveType
    : annotation* numericType
    | annotation* BOOLEAN
    ;

dims
    : annotation* LBRACK RBRACK (annotation* LBRACK RBRACK)*
    ;

wildcard
    : annotation* QUESTION wildcardBounds?
    ;

wildcardBounds
    : EXTENDS referenceType
    | SUPER referenceType
    ;

unannInterfaceType_lfno_unannClassOrInterfaceType
    : unannClassType_lfno_unannClassOrInterfaceType
    ;

unannClassType_lf_unannClassOrInterfaceType
    : DOT annotation* Identifier typeArguments?
    ;

unannInterfaceType_lf_unannClassOrInterfaceType
    : unannClassType_lf_unannClassOrInterfaceType
    ;

unannTypeVariable
    : Identifier
    ;

unannArrayType
    : unannPrimitiveType dims
    | unannClassOrInterfaceType dims
    | unannTypeVariable dims
    ;

variableDeclaratorId
    : Identifier dims?
    ;

receiverParameter
    : annotation* unannType (Identifier DOT)? THIS
    ;

lastFormalParameter
    : variableModifier* unannType annotation* ELLIPSIS variableDeclaratorId
    | formalParameter
    ;

inferredFormalParameterList
    : Identifier (COMMA Identifier)*
    ;

lambdaBody
    : expression
    | block
    ;

/*
 * Productions from §14 (Blocks and Statements)
 */

block
    : LBRACE blockStatements? RBRACE
    ;

blockStatements
    : blockStatement+
    ;

blockStatement
    : localVariableDeclarationStatement
    | classDeclaration
    | statement
    ;

localVariableDeclarationStatement
    : localVariableDeclaration SEMI
    ;

localVariableDeclaration
    : variableModifier* unannType variableDeclaratorList
    ;

variableDeclaratorList
    : variableDeclarator (COMMA variableDeclarator)*
    ;

variableDeclarator
    : variableDeclaratorId (ASSIGN variableInitializer)?
    ;

variableInitializer
    : expression
    | arrayInitializer
    ;

/*
 * Productions from §10 (Arrays)
 */

arrayInitializer
    : LBRACE variableInitializerList? COMMA? RBRACE
    ;

variableInitializerList
    : variableInitializer (COMMA variableInitializer)*
    ;

/*
 * Productions from §8 (Classes)
 */

classDeclaration
    : normalClassDeclaration
    | enumDeclaration
    ;

normalClassDeclaration
    : classModifier* CLASS Identifier typeParameters? superclass? superinterfaces? classBody
    ;

classModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    | ABSTRACT
    | STATIC
    | FINAL
    | STRICTFP
    ;

typeParameters
    : LT typeParameterList GT
    ;

typeParameterList
    : typeParameter (COMMA typeParameter)*
    ;

typeParameter
    : typeParameterModifier* Identifier typeBound?
    ;

typeParameterModifier
    : annotation
    ;

typeBound
    : EXTENDS typeVariable
    | EXTENDS classOrInterfaceType additionalBound*
    ;
additionalBound
    : BITAND interfaceType
    ;

interfaceType
    : classType
    ;

classType
    : annotation* Identifier typeArguments?
    | classOrInterfaceType DOT annotation* Identifier typeArguments?
    ;

superclass
    : EXTENDS classType
    ;

superinterfaces
    : IMPLEMENTS interfaceTypeList
    ;

interfaceTypeList
    : interfaceType (COMMA interfaceType)*
    ;

classBody
    : LBRACE classBodyDeclaration* RBRACE
    ;

classBodyDeclaration
    : classMemberDeclaration
    | instanceInitializer
    | staticInitializer
    | constructorDeclaration
    ;

classMemberDeclaration
    : fieldDeclaration
    | methodDeclaration
    | classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

fieldDeclaration
    : fieldModifier* unannType variableDeclaratorList SEMI
    ;

fieldModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    | STATIC
    | FINAL
    | TRANSIENT
    | VOLATILE
    ;

methodDeclaration
    : methodModifier* methodHeader methodBody
    ;

methodModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    | ABSTRACT
    | STATIC
    | FINAL
    | SYNCHRONIZED
    | NATIVE
    | STRICTFP
    ;

methodHeader
    : result methodDeclarator throws_?
    | typeParameters annotation* result methodDeclarator throws_?
    ;

result
    : unannType
    | VOID
    ;

methodDeclarator
    : Identifier LPAREN formalParameterList? RPAREN dims?
    ;

throws_
    : THROWS exceptionTypeList
    ;

exceptionTypeList
    : exceptionType (COMMA exceptionType)*
    ;

exceptionType
    : classType
    | typeVariable
    ;

methodBody
    : block
    | SEMI
    ;

/*
 * Productions from §9 (Interfaces)
 */

interfaceDeclaration
    : normalInterfaceDeclaration
    | annotationTypeDeclaration
    ;

normalInterfaceDeclaration
    : interfaceModifier* INTERFACE Identifier typeParameters? extendsInterfaces? interfaceBody
    ;

interfaceModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    | ABSTRACT
    | STATIC
    | STRICTFP
    ;

extendsInterfaces
    : EXTENDS interfaceTypeList
    ;

interfaceBody
    : LBRACE interfaceMemberDeclaration* RBRACE
    ;

interfaceMemberDeclaration
    : constantDeclaration
    | interfaceMethodDeclaration
    | classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

constantDeclaration
    : constantModifier* unannType variableDeclaratorList SEMI
    ;

constantModifier
    : annotation
    | PUBLIC
    | STATIC
    | FINAL
    ;

interfaceMethodDeclaration
    : interfaceMethodModifier* methodHeader methodBody
    ;

interfaceMethodModifier
    : annotation
    | PUBLIC
    | PRIVATE//Introduced in Java 9
    | ABSTRACT
    | DEFAULT
    | STATIC
    | STRICTFP
    ;

annotationTypeDeclaration
    : interfaceModifier* AT INTERFACE Identifier annotationTypeBody
    ;

annotationTypeBody
    : LBRACE annotationTypeMemberDeclaration* RBRACE
    ;

annotationTypeMemberDeclaration
    : annotationTypeElementDeclaration
    | constantDeclaration
    | classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

annotationTypeElementDeclaration
    : annotationTypeElementModifier* unannType Identifier LPAREN RPAREN dims? defaultValue? SEMI
    ;

annotationTypeElementModifier
    : annotation
    | PUBLIC
    | ABSTRACT
    ;

defaultValue
    : DEFAULT elementValue
    ;

instanceInitializer
    : block
    ;

staticInitializer
    : STATIC block
    ;

constructorDeclaration
    : constructorModifier* constructorDeclarator throws_? constructorBody
    ;

constructorModifier
    : annotation
    | PUBLIC
    | PROTECTED
    | PRIVATE
    ;

constructorDeclarator
    : typeParameters? simpleTypeName LPAREN formalParameterList? RPAREN
    ;

simpleTypeName
    : Identifier
    ;

constructorBody
    : LBRACE explicitConstructorInvocation? blockStatements? RBRACE
    ;

explicitConstructorInvocation
    : typeArguments? THIS LPAREN argumentList? RPAREN SEMI
    | typeArguments? SUPER LPAREN argumentList? RPAREN SEMI
    | expressionName DOT typeArguments? SUPER LPAREN argumentList? RPAREN SEMI
    | primary DOT typeArguments? SUPER LPAREN argumentList? RPAREN SEMI
    ;

argumentList
    : expression (COMMA expression)*
    ;

expressionName
    : Identifier
    | ambiguousName DOT Identifier
    ;

ambiguousName
    : Identifier
    | ambiguousName DOT Identifier
    ;

enumDeclaration
    : classModifier* ENUM Identifier superinterfaces? enumBody
    ;

enumBody
    : LBRACE enumConstantList? COMMA? enumBodyDeclarations? RBRACE
    ;

enumConstantList
    : enumConstant (COMMA enumConstant)*
    ;

enumConstant
    : enumConstantModifier* Identifier (LPAREN argumentList? RPAREN)? classBody?
    ;

enumConstantModifier
    : annotation
    ;

enumBodyDeclarations
    : SEMI classBodyDeclaration*
    ;

statement
    : statementWithoutTrailingSubstatement
    | labeledStatement
    | ifThenStatement
    | ifThenElseStatement
    | whileStatement
    | forStatement
    ;

statementWithoutTrailingSubstatement
    : block
    | emptyStatement
    | expressionStatement
    | assertStatement
    | switchStatement
    | doStatement
    | breakStatement
    | continueStatement
    | returnStatement
    | synchronizedStatement
    | throwStatement
    | tryStatement
    ;

emptyStatement
    : SEMI
    ;

expressionStatement
    : statementExpression SEMI
    ;

statementExpression
    : assignment
    | preIncrementExpression
    | preDecrementExpression
    | postIncrementExpression
    | postDecrementExpression
    | methodInvocation
    | classInstanceCreationExpression
    ;

assignment
    : leftHandSide assignmentOperator expression
    ;

leftHandSide
    : expressionName
    | fieldAccess
    | arrayAccess
    ;

fieldAccess
    : primary DOT Identifier
    | SUPER DOT Identifier
    | typeName DOT SUPER DOT Identifier
    ;

/*arrayAccess
    :   expressionName '[' expression ']'
    |   primaryNoNewArray '[' expression ']'
    ;
*/

arrayAccess
    : (expressionName LBRACK expression RBRACK|primaryNoNewArray_lfno_arrayAccess LBRACK expression RBRACK) (primaryNoNewArray_lf_arrayAccess LBRACK expression RBRACK)*
    ;

primaryNoNewArray_lfno_arrayAccess
    : literal
    | typeName (LBRACK RBRACK)* DOT CLASS
    | VOID DOT CLASS
    | THIS
    | typeName DOT THIS
    | LPAREN expression RPAREN
    | classInstanceCreationExpression
    | fieldAccess
    | methodInvocation
    | methodReference
    ;

classInstanceCreationExpression
    : NEW typeArguments? annotation* Identifier (DOT annotation* Identifier)* typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    | expressionName DOT NEW typeArguments? annotation* Identifier typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    | primary DOT NEW typeArguments? annotation* Identifier typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    ;

typeArgumentsOrDiamond
    : typeArguments
    | LT GT
    ;

methodInvocation
    : methodName LPAREN argumentList? RPAREN
    | typeName DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | expressionName DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | primary DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | SUPER DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | typeName DOT SUPER DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    ;

methodName
    : Identifier
    ;

methodReference
    : expressionName COLONCOLON typeArguments? Identifier
    | referenceType COLONCOLON typeArguments? Identifier
    | primary COLONCOLON typeArguments? Identifier
    | SUPER COLONCOLON typeArguments? Identifier
    | typeName DOT SUPER COLONCOLON typeArguments? Identifier
    | classType COLONCOLON typeArguments? NEW
    | arrayType COLONCOLON NEW
    ;

primaryNoNewArray_lf_arrayAccess
    :
    ;

assignmentOperator
    : ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LSHIFT_ASSIGN
    | RSHIFT_ASSIGN
    | URSHIFT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

postIncrementExpression
    : postfixExpression INC
    ;

postDecrementExpression
    : postfixExpression DEC
    ;

assertStatement
    : ASSERT expression SEMI
    | ASSERT expression COLON expression SEMI
    ;

switchStatement
    : SWITCH LPAREN expression RPAREN switchBlock
    ;

switchBlock
    : LBRACE switchBlockStatementGroup* switchLabel* RBRACE
    ;

switchBlockStatementGroup
    : switchLabels blockStatements
    ;

switchLabels
    : switchLabel+
    ;

switchLabel
    : CASE constantExpression COLON
    | CASE enumConstantName COLON
    | DEFAULT COLON
    ;

constantExpression
    : expression
    ;

enumConstantName
    : Identifier
    ;

doStatement
    : DO statement WHILE LPAREN expression RPAREN SEMI
    ;

breakStatement
    : BREAK Identifier? SEMI
    ;

continueStatement
    : CONTINUE Identifier? SEMI
    ;

returnStatement
    : RETURN expression? SEMI
    ;

synchronizedStatement
    : SYNCHRONIZED LPAREN expression RPAREN block
    ;

throwStatement
    : THROW expression SEMI
    ;

tryStatement
    : TRY block catches
    | TRY block catches? finally_
    | tryWithResourcesStatement
    ;

catches
    : catchClause+
    ;

catchClause
    : CATCH LPAREN catchFormalParameter RPAREN block
    ;

catchFormalParameter
    : variableModifier* catchType variableDeclaratorId
    ;

catchType
    : unannClassType (BITOR classType)*
    ;

unannClassType
    : Identifier typeArguments?
    | unannClassOrInterfaceType DOT annotation* Identifier typeArguments?
    ;

finally_
    : FINALLY block
    ;

tryWithResourcesStatement
    : TRY resourceSpecification block catches? finally_?
    ;

resourceSpecification
    : LPAREN resourceList SEMI? RPAREN
    ;

resourceList
    : resource (SEMI resource)*
    ;

resource
    : variableModifier* unannType variableDeclaratorId ASSIGN expression
    | variableAccess//Introduced in Java 9
    ;

variableAccess
    : expressionName
    | fieldAccess
    ;

labeledStatement
    : Identifier COLON statement
    ;

ifThenStatement
    : IF LPAREN expression RPAREN statement
    ;

ifThenElseStatement
    : IF LPAREN expression RPAREN statementNoShortIf ELSE statement
    ;

statementNoShortIf
    : statementWithoutTrailingSubstatement
    | labeledStatementNoShortIf
    | ifThenElseStatementNoShortIf
    | whileStatementNoShortIf
    | forStatementNoShortIf
    ;

labeledStatementNoShortIf
    : Identifier COLON statementNoShortIf
    ;

ifThenElseStatementNoShortIf
    : IF LPAREN expression RPAREN statementNoShortIf ELSE statementNoShortIf
    ;

whileStatementNoShortIf
    : WHILE LPAREN expression RPAREN statementNoShortIf
    ;

forStatementNoShortIf
    : basicForStatementNoShortIf
    | enhancedForStatementNoShortIf
    ;

basicForStatementNoShortIf
    : FOR LPAREN forInit? SEMI expression? SEMI forUpdate? RPAREN statementNoShortIf
    ;

forInit
    : statementExpressionList
    | localVariableDeclaration
    ;

statementExpressionList
    : statementExpression (COMMA statementExpression)*
    ;

forUpdate
    : statementExpressionList
    ;

enhancedForStatementNoShortIf
    : FOR LPAREN variableModifier* unannType variableDeclaratorId COLON expression RPAREN statementNoShortIf
    ;

whileStatement
    : WHILE LPAREN expression RPAREN statement
    ;

forStatement
    : basicForStatement
    | enhancedForStatement
    ;

basicForStatement
    : FOR LPAREN forInit? SEMI expression? SEMI forUpdate? RPAREN statement
    ;

enhancedForStatement
    : FOR LPAREN variableModifier* unannType variableDeclaratorId COLON expression RPAREN statement
    ;

assignmentExpression
    : conditionalExpression
    | assignment
    ;

classInstanceCreationExpression_lfno_primary
    : NEW typeArguments? annotation* Identifier (DOT annotation* Identifier)* typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    | expressionName DOT NEW typeArguments? annotation* Identifier typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    ;

fieldAccess_lfno_primary
    : SUPER DOT Identifier
    | typeName DOT SUPER DOT Identifier
    ;

arrayAccess_lfno_primary
    : (expressionName LBRACK expression RBRACK|primaryNoNewArray_lfno_primary_lfno_arrayAccess_lfno_primary LBRACK expression RBRACK) (primaryNoNewArray_lfno_primary_lf_arrayAccess_lfno_primary LBRACK expression RBRACK)*
    ;

primaryNoNewArray_lfno_primary_lfno_arrayAccess_lfno_primary
    : literal
    | typeName (LBRACK RBRACK)* DOT CLASS
    | unannPrimitiveType (LBRACK RBRACK)* DOT CLASS
    | VOID DOT CLASS
    | THIS
    | typeName DOT THIS
    | LPAREN expression RPAREN
    | classInstanceCreationExpression_lfno_primary
    | fieldAccess_lfno_primary
    | methodInvocation_lfno_primary
    | methodReference_lfno_primary
    ;

methodInvocation_lfno_primary
    : methodName LPAREN argumentList? RPAREN
    | typeName DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | expressionName DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | SUPER DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    | typeName DOT SUPER DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    ;

methodReference_lfno_primary
    : expressionName COLONCOLON typeArguments? Identifier
    | referenceType COLONCOLON typeArguments? Identifier
    | SUPER COLONCOLON typeArguments? Identifier
    | typeName DOT SUPER COLONCOLON typeArguments? Identifier
    | classType COLONCOLON typeArguments? NEW
    | arrayType COLONCOLON NEW
    ;

primaryNoNewArray_lfno_primary_lf_arrayAccess_lfno_primary
    :
    ;

arrayCreationExpression
    : NEW primitiveType dimExprs dims?
    | NEW classOrInterfaceType dimExprs dims?
    | NEW primitiveType dims arrayInitializer
    | NEW classOrInterfaceType dims arrayInitializer
    ;

dimExprs
    : dimExpr+
    ;

dimExpr
    : annotation* LBRACK expression RBRACK
    ;

primaryNoNewArray_lf_primary
    : classInstanceCreationExpression_lf_primary
    | fieldAccess_lf_primary
    | arrayAccess_lf_primary
    | methodInvocation_lf_primary
    | methodReference_lf_primary
    ;

classInstanceCreationExpression_lf_primary
    : DOT NEW typeArguments? annotation* Identifier typeArgumentsOrDiamond? LPAREN argumentList? RPAREN classBody?
    ;

fieldAccess_lf_primary
    : DOT Identifier
    ;

arrayAccess_lf_primary
    : (primaryNoNewArray_lf_primary_lfno_arrayAccess_lf_primary LBRACK expression RBRACK) (primaryNoNewArray_lf_primary_lf_arrayAccess_lf_primary LBRACK expression RBRACK)*
    ;

primaryNoNewArray_lf_primary_lfno_arrayAccess_lf_primary
    : classInstanceCreationExpression_lf_primary
    | fieldAccess_lf_primary
    | methodInvocation_lf_primary
    | methodReference_lf_primary
    ;

methodInvocation_lf_primary
    : DOT typeArguments? Identifier LPAREN argumentList? RPAREN
    ;

methodReference_lf_primary
    : COLONCOLON typeArguments? Identifier
    ;

primaryNoNewArray_lf_primary_lf_arrayAccess_lf_primary
    :
    ;

postIncrementExpression_lf_postfixExpression
    : INC
    ;

postDecrementExpression_lf_postfixExpression
    : DEC
    ;

castExpression
    : LPAREN primitiveType RPAREN unaryExpression
    | LPAREN referenceType additionalBound* RPAREN unaryExpressionNotPlusMinus
    | LPAREN referenceType additionalBound* RPAREN lambdaExpression
    ;

elementValueArrayInitializer
    : LBRACE elementValueList? COMMA? RBRACE
    ;

elementValueList
    : elementValue (COMMA elementValue)*
    ;

markerAnnotation
    : AT typeName
    ;

singleElementAnnotation
    : AT typeName LPAREN elementValue RPAREN
    ;

packageName
    : Identifier
    | packageName DOT Identifier
    ;

importDeclaration
    : singleTypeImportDeclaration
    | typeImportOnDemandDeclaration
    | singleStaticImportDeclaration
    | staticImportOnDemandDeclaration
    ;

singleTypeImportDeclaration
    : IMPORT typeName SEMI
    ;

typeImportOnDemandDeclaration
    : IMPORT packageOrTypeName DOT MUL SEMI
    ;

singleStaticImportDeclaration
    : IMPORT STATIC typeName DOT Identifier SEMI
    ;

staticImportOnDemandDeclaration
    : IMPORT STATIC typeName DOT MUL SEMI
    ;

typeDeclaration
    : classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

modularCompilation
    : importDeclaration* moduleDeclaration
    ;

moduleDeclaration
    : annotation* OPEN? MODULE moduleName LBRACE moduleDirective* RBRACE
    ;

/*
 * Productions from §6 (Names)
 */

moduleName
    : Identifier
    | moduleName DOT Identifier
    ;

moduleDirective
    : REQUIRES requiresModifier* moduleName SEMI
    | EXPORTS packageName (TO moduleName (COMMA moduleName)*)? SEMI
    | OPENS packageName (TO moduleName (COMMA moduleName)*)? SEMI
    | USES typeName SEMI
    | PROVIDES typeName WITH typeName (COMMA typeName)* SEMI
    ;

requiresModifier
    : TRANSITIVE
    | STATIC
    ;
