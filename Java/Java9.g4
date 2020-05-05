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
grammar Java9;

@lexer::header{
using System.Linq;
using System.Text.RegularExpressions;
}

@lexer::members {
	private class Character
	{
		public static bool isJavaIdentifierPart(int c)
		{
			if (Char.IsLetter((char)c))
				return true;
			else if (c == (int)'$')
				return true;
			else if (c == (int)'_')
				return true;
			else if (Char.IsDigit((char)c))
				return true;
			else if (Char.IsNumber((char)c))
				return true;
			return false;
		}

		public static bool isJavaIdentifierStart(int c)
		{
			if (Char.IsLetter((char)c))
				return true;
			else if (c == (int)'$')
				return true;
			else if (c == (int)'_')
				return true;
			return false;
		}

		public static int toCodePoint(int high, int low)
		{
			return Char.ConvertToUtf32((char)high, (char)low);
		}
	}
}

/*
 * Productions from §3 (Lexical Structure)
 */


additionalBound
	:	'&' interfaceType
	;

additiveExpression
	:	multiplicativeExpression
	|	additiveExpression '+' multiplicativeExpression
	|	additiveExpression '-' multiplicativeExpression
	;

ambiguousName
	:	identifier
	|	ambiguousName '.' identifier
	;

andExpression
	:	equalityExpression
	|	andExpression '&' equalityExpression
	;

annotation
	:	normalAnnotation
	|	markerAnnotation
	|	singleElementAnnotation
	;

annotationTypeBody
	:	'{' annotationTypeMemberDeclaration* '}'
	;

annotationTypeDeclaration
	:	interfaceModifier* '@' 'interface' identifier annotationTypeBody
	;

annotationTypeElementDeclaration
	:	annotationTypeElementModifier* unannType identifier '(' ')' dims? defaultValue? ';'
	;

annotationTypeElementModifier
	:	annotation
	|	'public'
	|	'abstract'
	;

annotationTypeMemberDeclaration
	:	annotationTypeElementDeclaration
	|	constantDeclaration
	|	classDeclaration
	|	interfaceDeclaration
	|	';'
	;

argumentList
	:	expression (',' expression)*
	;

/*arrayAccess
	:	expressionName '[' expression ']'
	|	primaryNoNewArray '[' expression ']'
	;
*/

arrayAccess
	:	(	expressionName '[' expression ']'
		|	primaryNoNewArray_lfno_arrayAccess '[' expression ']'
		)
		(	primaryNoNewArray_lf_arrayAccess '[' expression ']'
		)*
	;

arrayAccess_lf_primary
	:	(	primaryNoNewArray_lf_primary_lfno_arrayAccess_lf_primary '[' expression ']'
		)
		(	primaryNoNewArray_lf_primary_lf_arrayAccess_lf_primary '[' expression ']'
		)*
	;

arrayAccess_lfno_primary
	:	(	expressionName '[' expression ']'
		|	primaryNoNewArray_lfno_primary_lfno_arrayAccess_lfno_primary '[' expression ']'
		)
		(	primaryNoNewArray_lfno_primary_lf_arrayAccess_lfno_primary '[' expression ']'
		)*
	;

arrayCreationExpression
	:	'new' primitiveType dimExprs dims?
	|	'new' classOrInterfaceType dimExprs dims?
	|	'new' primitiveType dims arrayInitializer
	|	'new' classOrInterfaceType dims arrayInitializer
	;

/*
 * Productions from §10 (Arrays)
 */

arrayInitializer
	:	'{' variableInitializerList? ','? '}'
	;

arrayType
	:	primitiveType dims
	|	classOrInterfaceType dims
	|	typeVariable dims
	;

assertStatement
	:	'assert' expression ';'
	|	'assert' expression ':' expression ';'
	;

assignment
	:	leftHandSide assignmentOperator expression
	;

assignmentExpression
	:	conditionalExpression
	|	assignment
	;

assignmentOperator
	:	'='
	|	'*='
	|	'/='
	|	'%='
	|	'+='
	|	'-='
	|	'<<='
	|	'>>='
	|	'>>>='
	|	'&='
	|	'^='
	|	'|='
	;

basicForStatement
	:	'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
	;

basicForStatementNoShortIf
	:	'for' '(' forInit? ';' expression? ';' forUpdate? ')' statementNoShortIf
	;

/*
 * Productions from §14 (Blocks and Statements)
 */

block
	:	'{' blockStatements? '}'
	;

blockStatement
	:	localVariableDeclarationStatement
	|	classDeclaration
	|	statement
	;

blockStatements
	:	blockStatement+
	;

breakStatement
	:	'break' identifier? ';'
	;

castExpression
	:	'(' primitiveType ')' unaryExpression
	|	'(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
	|	'(' referenceType additionalBound* ')' lambdaExpression
	;

catchClause
	:	'catch' '(' catchFormalParameter ')' block
	;

catches
	:	catchClause+
	;

catchFormalParameter
	:	variableModifier* catchType variableDeclaratorId
	;

catchType
	:	unannClassType ('|' classType)*
	;

classBody
	:	'{' classBodyDeclaration* '}'
	;

classBodyDeclaration
	:	classMemberDeclaration
	|	instanceInitializer
	|	staticInitializer
	|	constructorDeclaration
	;

/*
 * Productions from §8 (Classes)
 */

classDeclaration
	:	normalClassDeclaration
	|	enumDeclaration
	;

classInstanceCreationExpression
	:	'new' typeArguments? annotation* identifier ('.' annotation* identifier)* typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	|	expressionName '.' 'new' typeArguments? annotation* identifier typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	|	primary '.' 'new' typeArguments? annotation* identifier typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	;

classInstanceCreationExpression_lf_primary
	:	'.' 'new' typeArguments? annotation* identifier typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	;

classInstanceCreationExpression_lfno_primary
	:	'new' typeArguments? annotation* identifier ('.' annotation* identifier)* typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	|	expressionName '.' 'new' typeArguments? annotation* identifier typeArgumentsOrDiamond? '(' argumentList? ')' classBody?
	;

classLiteral
	:	(typeName|numericType|'boolean') ('[' ']')* '.' 'class'
	|	'void' '.' 'class'
	;

classMemberDeclaration
	:	fieldDeclaration
	|	methodDeclaration
	|	classDeclaration
	|	interfaceDeclaration
	|	';'
	;

classModifier
	:	annotation
	|	'public'
	|	'protected'
	|	'private'
	|	'abstract'
	|	'static'
	|	'final'
	|	'strictfp'
	;

/*classOrInterfaceType
	:	classType
	|	interfaceType
	;
*/
classOrInterfaceType
	:	(	classType_lfno_classOrInterfaceType
		|	interfaceType_lfno_classOrInterfaceType
		)
		(	classType_lf_classOrInterfaceType
		|	interfaceType_lf_classOrInterfaceType
		)*
	;

classType
	:	annotation* identifier typeArguments?
	|	classOrInterfaceType '.' annotation* identifier typeArguments?
	;

classType_lf_classOrInterfaceType
	:	'.' annotation* identifier typeArguments?
	;

classType_lfno_classOrInterfaceType
	:	annotation* identifier typeArguments?
	;

/*
 * Productions from §7 (Packages)
 */

compilationUnit
	:	ordinaryCompilation
	|	modularCompilation
	;

conditionalAndExpression
	:	inclusiveOrExpression
	|	conditionalAndExpression '&&' inclusiveOrExpression
	;

conditionalExpression
	:	conditionalOrExpression
	|	conditionalOrExpression '?' expression ':' (conditionalExpression|lambdaExpression)
	;

conditionalOrExpression
	:	conditionalAndExpression
	|	conditionalOrExpression '||' conditionalAndExpression
	;

constantDeclaration
	:	constantModifier* unannType variableDeclaratorList ';'
	;

constantExpression
	:	expression
	;

constantModifier
	:	annotation
	|	'public'
	|	'static'
	|	'final'
	;

constructorBody
	:	'{' explicitConstructorInvocation? blockStatements? '}'
	;

constructorDeclaration
	:	constructorModifier* constructorDeclarator throws_? constructorBody
	;

constructorDeclarator
	:	typeParameters? simpleTypeName '(' formalParameterList? ')'
	;

constructorModifier
	:	annotation
	|	'public'
	|	'protected'
	|	'private'
	;

continueStatement
	:	'continue' identifier? ';'
	;

defaultValue
	:	'default' elementValue
	;

dimExpr
	:	annotation* '[' expression ']'
	;

dimExprs
	:	dimExpr+
	;

dims
	:	annotation* '[' ']' (annotation* '[' ']')*
	;

doStatement
	:	'do' statement 'while' '(' expression ')' ';'
	;

elementValue
	:	conditionalExpression
	|	elementValueArrayInitializer
	|	annotation
	;

elementValueArrayInitializer
	:	'{' elementValueList? ','? '}'
	;

elementValueList
	:	elementValue (',' elementValue)*
	;

elementValuePair
	:	identifier '=' elementValue
	;

elementValuePairList
	:	elementValuePair (',' elementValuePair)*
	;

emptyStatement
	:	';'
	;

enhancedForStatement
	:	'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
	;

enhancedForStatementNoShortIf
	:	'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statementNoShortIf
	;

enumBody
	:	'{' enumConstantList? ','? enumBodyDeclarations? '}'
	;

enumBodyDeclarations
	:	';' classBodyDeclaration*
	;

enumConstant
	:	enumConstantModifier* identifier ('(' argumentList? ')')? classBody?
	;

enumConstantList
	:	enumConstant (',' enumConstant)*
	;

enumConstantModifier
	:	annotation
	;

enumConstantName
	:	identifier
	;

enumDeclaration
	:	classModifier* 'enum' identifier superinterfaces? enumBody
	;

equalityExpression
	:	relationalExpression
	|	equalityExpression '==' relationalExpression
	|	equalityExpression '!=' relationalExpression
	;

exceptionType
	:	classType
	|	typeVariable
	;

exceptionTypeList
	:	exceptionType (',' exceptionType)*
	;

exclusiveOrExpression
	:	andExpression
	|	exclusiveOrExpression '^' andExpression
	;

explicitConstructorInvocation
	:	typeArguments? 'this' '(' argumentList? ')' ';'
	|	typeArguments? 'super' '(' argumentList? ')' ';'
	|	expressionName '.' typeArguments? 'super' '(' argumentList? ')' ';'
	|	primary '.' typeArguments? 'super' '(' argumentList? ')' ';'
	;

expression
	:	lambdaExpression
	|	assignmentExpression
	;

expressionName
	:	identifier
	|	ambiguousName '.' identifier
	;

expressionStatement
	:	statementExpression ';'
	;

extendsInterfaces
	:	'extends' interfaceTypeList
	;

fieldAccess
	:	primary '.' identifier
	|	'super' '.' identifier
	|	typeName '.' 'super' '.' identifier
	;

fieldAccess_lf_primary
	:	'.' identifier
	;

fieldAccess_lfno_primary
	:	'super' '.' identifier
	|	typeName '.' 'super' '.' identifier
	;

fieldDeclaration
	:	fieldModifier* unannType variableDeclaratorList ';'
	;

fieldModifier
	:	annotation
	|	'public'
	|	'protected'
	|	'private'
	|	'static'
	|	'final'
	|	'transient'
	|	'volatile'
	;

finally_
	:	'finally' block
	;

floatingPointType
	:	'float'
	|	'double'
	;

forInit
	:	statementExpressionList
	|	localVariableDeclaration
	;

formalParameter
	:	variableModifier* unannType variableDeclaratorId
	;

formalParameterList
	:	formalParameters ',' lastFormalParameter
	|	lastFormalParameter
	|	receiverParameter
	;

formalParameters
	:	formalParameter (',' formalParameter)*
	|	receiverParameter (',' formalParameter)*
	;

forStatement
	:	basicForStatement
	|	enhancedForStatement
	;

forStatementNoShortIf
	:	basicForStatementNoShortIf
	|	enhancedForStatementNoShortIf
	;

forUpdate
	:	statementExpressionList
	;

// LEXER

identifier : Identifier | 'to' | 'module' | 'open' | 'with' | 'provides' | 'uses' | 'opens' | 'requires' | 'exports';

ifThenElseStatement
	:	'if' '(' expression ')' statementNoShortIf 'else' statement
	;

ifThenElseStatementNoShortIf
	:	'if' '(' expression ')' statementNoShortIf 'else' statementNoShortIf
	;

ifThenStatement
	:	'if' '(' expression ')' statement
	;

importDeclaration
	:	singleTypeImportDeclaration
	|	typeImportOnDemandDeclaration
	|	singleStaticImportDeclaration
	|	staticImportOnDemandDeclaration
	;

inclusiveOrExpression
	:	exclusiveOrExpression
	|	inclusiveOrExpression '|' exclusiveOrExpression
	;

inferredFormalParameterList
	:	identifier (',' identifier)*
	;

instanceInitializer
	:	block
	;

integralType
	:	'byte'
	|	'short'
	|	'int'
	|	'long'
	|	'char'
	;

interfaceBody
	:	'{' interfaceMemberDeclaration* '}'
	;

/*
 * Productions from §9 (Interfaces)
 */

interfaceDeclaration
	:	normalInterfaceDeclaration
	|	annotationTypeDeclaration
	;

interfaceMemberDeclaration
	:	constantDeclaration
	|	interfaceMethodDeclaration
	|	classDeclaration
	|	interfaceDeclaration
	|	';'
	;

interfaceMethodDeclaration
	:	interfaceMethodModifier* methodHeader methodBody
	;

interfaceMethodModifier
	:	annotation
	|	'public'
	|	'private'//Introduced in Java 9
	|	'abstract'
	|	'default'
	|	'static'
	|	'strictfp'
	;

interfaceModifier
	:	annotation
	|	'public'
	|	'protected'
	|	'private'
	|	'abstract'
	|	'static'
	|	'strictfp'
	;

interfaceType
	:	classType
	;

interfaceType_lf_classOrInterfaceType
	:	classType_lf_classOrInterfaceType
	;

interfaceType_lfno_classOrInterfaceType
	:	classType_lfno_classOrInterfaceType
	;

interfaceTypeList
	:	interfaceType (',' interfaceType)*
	;

labeledStatement
	:	identifier ':' statement
	;

labeledStatementNoShortIf
	:	identifier ':' statementNoShortIf
	;

lambdaBody
	:	expression
	|	block
	;

lambdaExpression
	:	lambdaParameters '->' lambdaBody
	;

lambdaParameters
	:	identifier
	|	'(' formalParameterList? ')'
	|	'(' inferredFormalParameterList ')'
	;

lastFormalParameter
	:	variableModifier* unannType annotation* '...' variableDeclaratorId
	|	formalParameter
	;

leftHandSide
	:	expressionName
	|	fieldAccess
	|	arrayAccess
	;
literal
	:	IntegerLiteral
	|	FloatingPointLiteral
	|	BooleanLiteral
	|	CharacterLiteral
	|	StringLiteral
	|	NullLiteral
	;

localVariableDeclaration
	:	variableModifier* unannType variableDeclaratorList
	;

localVariableDeclarationStatement
	:	localVariableDeclaration ';'
	;

markerAnnotation
	:	'@' typeName
	;

methodBody
	:	block
	|	';'
	;

methodDeclaration
	:	methodModifier* methodHeader methodBody
	;

methodDeclarator
	:	identifier '(' formalParameterList? ')' dims?
	;

methodHeader
	:	result methodDeclarator throws_?
	|	typeParameters annotation* result methodDeclarator throws_?
	;


methodInvocation
	:	methodName '(' argumentList? ')'
	|	typeName '.' typeArguments? identifier '(' argumentList? ')'
	|	expressionName '.' typeArguments? identifier '(' argumentList? ')'
	|	primary '.' typeArguments? identifier '(' argumentList? ')'
	|	'super' '.' typeArguments? identifier '(' argumentList? ')'
	|	typeName '.' 'super' '.' typeArguments? identifier '(' argumentList? ')'
	;

methodInvocation_lf_primary
	:	'.' typeArguments? identifier '(' argumentList? ')'
	;

methodInvocation_lfno_primary
	:	methodName '(' argumentList? ')'
	|	typeName '.' typeArguments? identifier '(' argumentList? ')'
	|	expressionName '.' typeArguments? identifier '(' argumentList? ')'
	|	'super' '.' typeArguments? identifier '(' argumentList? ')'
	|	typeName '.' 'super' '.' typeArguments? identifier '(' argumentList? ')'
	;

methodModifier
	:	annotation
	|	'public'
	|	'protected'
	|	'private'
	|	'abstract'
	|	'static'
	|	'final'
	|	'synchronized'
	|	'native'
	|	'strictfp'
	;

methodName
	:	identifier
	;

methodReference
	:	expressionName '::' typeArguments? identifier
	|	referenceType '::' typeArguments? identifier
	|	primary '::' typeArguments? identifier
	|	'super' '::' typeArguments? identifier
	|	typeName '.' 'super' '::' typeArguments? identifier
	|	classType '::' typeArguments? 'new'
	|	arrayType '::' 'new'
	;

methodReference_lf_primary
	:	'::' typeArguments? identifier
	;

methodReference_lfno_primary
	:	expressionName '::' typeArguments? identifier
	|	referenceType '::' typeArguments? identifier
	|	'super' '::' typeArguments? identifier
	|	typeName '.' 'super' '::' typeArguments? identifier
	|	classType '::' typeArguments? 'new'
	|	arrayType '::' 'new'
	;

modularCompilation
	:	importDeclaration* moduleDeclaration
	;

moduleDeclaration
	:	annotation* 'open'? 'module' moduleName '{' moduleDirective* '}'
	;

moduleDirective
	:	'requires' requiresModifier* moduleName ';'
	|	'exports' packageName ('to' moduleName (',' moduleName)*)? ';'
	|	'opens' packageName ('to' moduleName (',' moduleName)*)? ';'
	|	'uses' typeName ';'
	|	'provides' typeName 'with' typeName (',' typeName)* ';'
	;

/*
 * Productions from §6 (Names)
 */

moduleName
	:	identifier
	|	moduleName '.' identifier
	;

multiplicativeExpression
	:	unaryExpression
	|	multiplicativeExpression '*' unaryExpression
	|	multiplicativeExpression '/' unaryExpression
	|	multiplicativeExpression '%' unaryExpression
	;

normalAnnotation
	:	'@' typeName '(' elementValuePairList? ')'
	;

normalClassDeclaration
	:	classModifier* 'class' identifier typeParameters? superclass? superinterfaces? classBody
	;

normalInterfaceDeclaration
	:	interfaceModifier* 'interface' identifier typeParameters? extendsInterfaces? interfaceBody
	;

numericType
	:	integralType
	|	floatingPointType
	;

ordinaryCompilation
	:	packageDeclaration? importDeclaration* typeDeclaration* EOF
	;

packageDeclaration
	:	packageModifier* 'package' packageName ';'
	;

packageModifier
	:	annotation
	;

packageName
	:	identifier
	|	packageName '.' identifier
	;

packageOrTypeName
	:	identifier
	|	packageOrTypeName '.' identifier
	;

postDecrementExpression
	:	postfixExpression '--'
	;

postDecrementExpression_lf_postfixExpression
	:	'--'
	;

/*postfixExpression
	:	primary
	|	expressionName
	|	postIncrementExpression
	|	postDecrementExpression
	;
*/

postfixExpression
	:	(	primary
		|	expressionName
		)
		(	postIncrementExpression_lf_postfixExpression
		|	postDecrementExpression_lf_postfixExpression
		)*
	;

postIncrementExpression
	:	postfixExpression '++'
	;

postIncrementExpression_lf_postfixExpression
	:	'++'
	;

preDecrementExpression
	:	'--' unaryExpression
	;

preIncrementExpression
	:	'++' unaryExpression
	;

/*
 * Productions from §15 (Expressions)
 */

/*primary
	:	primaryNoNewArray
	|	arrayCreationExpression
	;
*/

primary
	:	(	primaryNoNewArray_lfno_primary
		|	arrayCreationExpression
		)
		(	primaryNoNewArray_lf_primary
		)*
	;

primaryNoNewArray
	:	literal
	|	classLiteral
	|	'this'
	|	typeName '.' 'this'
	|	'(' expression ')'
	|	classInstanceCreationExpression
	|	fieldAccess
	|	arrayAccess
	|	methodInvocation
	|	methodReference
	;

primaryNoNewArray_lf_arrayAccess
	:
	;

primaryNoNewArray_lf_primary
	:	classInstanceCreationExpression_lf_primary
	|	fieldAccess_lf_primary
	|	arrayAccess_lf_primary
	|	methodInvocation_lf_primary
	|	methodReference_lf_primary
	;

primaryNoNewArray_lf_primary_lf_arrayAccess_lf_primary
	:
	;

primaryNoNewArray_lf_primary_lfno_arrayAccess_lf_primary
	:	classInstanceCreationExpression_lf_primary
	|	fieldAccess_lf_primary
	|	methodInvocation_lf_primary
	|	methodReference_lf_primary
	;

primaryNoNewArray_lfno_arrayAccess
	:	literal
	|	typeName ('[' ']')* '.' 'class'
	|	'void' '.' 'class'
	|	'this'
	|	typeName '.' 'this'
	|	'(' expression ')'
	|	classInstanceCreationExpression
	|	fieldAccess
	|	methodInvocation
	|	methodReference
	;

primaryNoNewArray_lfno_primary
	:	literal
	|	typeName ('[' ']')* '.' 'class'
	|	unannPrimitiveType ('[' ']')* '.' 'class'
	|	'void' '.' 'class'
	|	'this'
	|	typeName '.' 'this'
	|	'(' expression ')'
	|	classInstanceCreationExpression_lfno_primary
	|	fieldAccess_lfno_primary
	|	arrayAccess_lfno_primary
	|	methodInvocation_lfno_primary
	|	methodReference_lfno_primary
	;

primaryNoNewArray_lfno_primary_lf_arrayAccess_lfno_primary
	:
	;

primaryNoNewArray_lfno_primary_lfno_arrayAccess_lfno_primary
	:	literal
	|	typeName ('[' ']')* '.' 'class'
	|	unannPrimitiveType ('[' ']')* '.' 'class'
	|	'void' '.' 'class'
	|	'this'
	|	typeName '.' 'this'
	|	'(' expression ')'
	|	classInstanceCreationExpression_lfno_primary
	|	fieldAccess_lfno_primary
	|	methodInvocation_lfno_primary
	|	methodReference_lfno_primary
	;

/*
 * Productions from §4 (Types, Values, and Variables)
 */

primitiveType
	:	annotation* numericType
	|	annotation* 'boolean'
	;

receiverParameter
	:	annotation* unannType (identifier '.')? 'this'
	;

referenceType
	:	classOrInterfaceType
	|	typeVariable
	|	arrayType
	;

relationalExpression
	:	shiftExpression
	|	relationalExpression '<' shiftExpression
	|	relationalExpression '>' shiftExpression
	|	relationalExpression '<=' shiftExpression
	|	relationalExpression '>=' shiftExpression
	|	relationalExpression 'instanceof' referenceType
	;

requiresModifier
	:	'transitive'
	|	'static'
	;

resource
	:	variableModifier* unannType variableDeclaratorId '=' expression
	|	variableAccess//Introduced in Java 9
	;

resourceList
	:	resource (';' resource)*
	;

resourceSpecification
	:	'(' resourceList ';'? ')'
	;

result
	:	unannType
	|	'void'
	;

returnStatement
	:	'return' expression? ';'
	;

shiftExpression
	:	additiveExpression
	|	shiftExpression '<' '<' additiveExpression
	|	shiftExpression '>' '>' additiveExpression
	|	shiftExpression '>' '>' '>' additiveExpression
	;

simpleTypeName
	:	identifier
	;

singleElementAnnotation
	:	'@' typeName '(' elementValue ')'
	;

singleStaticImportDeclaration
	:	'import' 'static' typeName '.' identifier ';'
	;

singleTypeImportDeclaration
	:	'import' typeName ';'
	;

statement
	:	statementWithoutTrailingSubstatement
	|	labeledStatement
	|	ifThenStatement
	|	ifThenElseStatement
	|	whileStatement
	|	forStatement
	;

statementExpression
	:	assignment
	|	preIncrementExpression
	|	preDecrementExpression
	|	postIncrementExpression
	|	postDecrementExpression
	|	methodInvocation
	|	classInstanceCreationExpression
	;

statementExpressionList
	:	statementExpression (',' statementExpression)*
	;

statementNoShortIf
	:	statementWithoutTrailingSubstatement
	|	labeledStatementNoShortIf
	|	ifThenElseStatementNoShortIf
	|	whileStatementNoShortIf
	|	forStatementNoShortIf
	;

statementWithoutTrailingSubstatement
	:	block
	|	emptyStatement
	|	expressionStatement
	|	assertStatement
	|	switchStatement
	|	doStatement
	|	breakStatement
	|	continueStatement
	|	returnStatement
	|	synchronizedStatement
	|	throwStatement
	|	tryStatement
	;

staticImportOnDemandDeclaration
	:	'import' 'static' typeName '.' '*' ';'
	;

staticInitializer
	:	'static' block
	;

superclass
	:	'extends' classType
	;

superinterfaces
	:	'implements' interfaceTypeList
	;

switchBlock
	:	'{' switchBlockStatementGroup* switchLabel* '}'
	;

switchBlockStatementGroup
	:	switchLabels blockStatements
	;

switchLabel
	:	'case' constantExpression ':'
	|	'case' enumConstantName ':'
	|	'default' ':'
	;

switchLabels
	:	switchLabel+
	;

switchStatement
	:	'switch' '(' expression ')' switchBlock
	;

synchronizedStatement
	:	'synchronized' '(' expression ')' block
	;

throws_
	:	'throws' exceptionTypeList
	;

throwStatement
	:	'throw' expression ';'
	;

tryStatement
	:	'try' block catches
	|	'try' block catches? finally_
	|	tryWithResourcesStatement
	;

tryWithResourcesStatement
	:	'try' resourceSpecification block catches? finally_?
	;

typeArgument
	:	referenceType
	|	wildcard
	;

typeArgumentList
	:	typeArgument (',' typeArgument)*
	;

typeArguments
	:	'<' typeArgumentList '>'
	;

typeArgumentsOrDiamond
	:	typeArguments
	|	'<' '>'
	;

typeBound
	:	'extends' typeVariable
	|	'extends' classOrInterfaceType additionalBound*
	;

typeDeclaration
	:	classDeclaration
	|	interfaceDeclaration
	|	';'
	;

typeImportOnDemandDeclaration
	:	'import' packageOrTypeName '.' '*' ';'
	;

typeName
	:	identifier
	|	packageOrTypeName '.' identifier
	;

typeParameter
	:	typeParameterModifier* identifier typeBound?
	;

typeParameterList
	:	typeParameter (',' typeParameter)*
	;

typeParameterModifier
	:	annotation
	;

typeParameters
	:	'<' typeParameterList '>'
	;

typeVariable
	:	annotation* identifier
	;

unannArrayType
	:	unannPrimitiveType dims
	|	unannClassOrInterfaceType dims
	|	unannTypeVariable dims
	;

/*unannClassOrInterfaceType
	:	unannClassType
	|	unannInterfaceType
	;
*/

unannClassOrInterfaceType
	:	(	unannClassType_lfno_unannClassOrInterfaceType
		|	unannInterfaceType_lfno_unannClassOrInterfaceType
		)
		(	unannClassType_lf_unannClassOrInterfaceType
		|	unannInterfaceType_lf_unannClassOrInterfaceType
		)*
	;

unannClassType
	:	identifier typeArguments?
	|	unannClassOrInterfaceType '.' annotation* identifier typeArguments?
	;

unannClassType_lf_unannClassOrInterfaceType
	:	'.' annotation* identifier typeArguments?
	;

unannClassType_lfno_unannClassOrInterfaceType
	:	identifier typeArguments?
	;

unannInterfaceType
	:	unannClassType
	;

unannInterfaceType_lf_unannClassOrInterfaceType
	:	unannClassType_lf_unannClassOrInterfaceType
	;

unannInterfaceType_lfno_unannClassOrInterfaceType
	:	unannClassType_lfno_unannClassOrInterfaceType
	;

unannPrimitiveType
	:	numericType
	|	'boolean'
	;

unannReferenceType
	:	unannClassOrInterfaceType
	|	unannTypeVariable
	|	unannArrayType
	;

unannType
	:	unannPrimitiveType
	|	unannReferenceType
	;

unannTypeVariable
	:	identifier
	;

unaryExpression
	:	preIncrementExpression
	|	preDecrementExpression
	|	'+' unaryExpression
	|	'-' unaryExpression
	|	unaryExpressionNotPlusMinus
	;

unaryExpressionNotPlusMinus
	:	postfixExpression
	|	'~' unaryExpression
	|	'!' unaryExpression
	|	castExpression
	;

variableAccess
	:	expressionName
	|	fieldAccess
	;

variableDeclarator
	:	variableDeclaratorId ('=' variableInitializer)?
	;

variableDeclaratorId
	:	identifier dims?
	;

variableDeclaratorList
	:	variableDeclarator (',' variableDeclarator)*
	;

variableInitializer
	:	expression
	|	arrayInitializer
	;

variableInitializerList
	:	variableInitializer (',' variableInitializer)*
	;

variableModifier
	:	annotation
	|	'final'
	;

whileStatement
	:	'while' '(' expression ')' statement
	;

whileStatementNoShortIf
	:	'while' '(' expression ')' statementNoShortIf
	;

wildcard
	:	annotation* '?' wildcardBounds?
	;

wildcardBounds
	:	'extends' referenceType
	|	'super' referenceType
	;

// §3.9 Keywords

ABSTRACT : 'abstract';
ASSERT : 'assert';
BOOLEAN : 'boolean';
BREAK : 'break';
BYTE : 'byte';
CASE : 'case';
CATCH : 'catch';
CHAR : 'char';
CLASS : 'class';
CONST : 'const';
CONTINUE : 'continue';
DEFAULT : 'default';
DO : 'do';
DOUBLE : 'double';
ELSE : 'else';
ENUM : 'enum';
EXTENDS : 'extends';
FINAL : 'final';
FINALLY : 'finally';
FLOAT : 'float';
FOR : 'for';
IF : 'if';
GOTO : 'goto';
IMPLEMENTS : 'implements';
IMPORT : 'import';
INSTANCEOF : 'instanceof';
INT : 'int';
INTERFACE : 'interface';
LONG : 'long';
NATIVE : 'native';
NEW : 'new';
PACKAGE : 'package';
PRIVATE : 'private';
PROTECTED : 'protected';
PUBLIC : 'public';
RETURN : 'return';
SHORT : 'short';
STATIC : 'static';
STRICTFP : 'strictfp';
SUPER : 'super';
SWITCH : 'switch';
SYNCHRONIZED : 'synchronized';
THIS : 'this';
THROW : 'throw';
THROWS : 'throws';
TRANSIENT : 'transient';
TRY : 'try';
VOID : 'void';
VOLATILE : 'volatile';
WHILE : 'while';
UNDER_SCORE : '_';//Introduced in Java 9

// §3.10.1 Integer Literals

IntegerLiteral
	:	DecimalIntegerLiteral
	|	HexIntegerLiteral
	|	OctalIntegerLiteral
	|	BinaryIntegerLiteral
	;

fragment
DecimalIntegerLiteral
	:	DecimalNumeral IntegerTypeSuffix?
	;

fragment
HexIntegerLiteral
	:	HexNumeral IntegerTypeSuffix?
	;

fragment
OctalIntegerLiteral
	:	OctalNumeral IntegerTypeSuffix?
	;

fragment
BinaryIntegerLiteral
	:	BinaryNumeral IntegerTypeSuffix?
	;

fragment
IntegerTypeSuffix
	:	[lL]
	;

fragment
DecimalNumeral
	:	'0'
	|	NonZeroDigit (Digits? | Underscores Digits)
	;

fragment
Digits
	:	Digit (DigitsAndUnderscores? Digit)?
	;

fragment
Digit
	:	'0'
	|	NonZeroDigit
	;

fragment
NonZeroDigit
	:	[1-9]
	;

fragment
DigitsAndUnderscores
	:	DigitOrUnderscore+
	;

fragment
DigitOrUnderscore
	:	Digit
	|	'_'
	;

fragment
Underscores
	:	'_'+
	;

fragment
HexNumeral
	:	'0' [xX] HexDigits
	;

fragment
HexDigits
	:	HexDigit (HexDigitsAndUnderscores? HexDigit)?
	;

fragment
HexDigit
	:	[0-9a-fA-F]
	;

fragment
HexDigitsAndUnderscores
	:	HexDigitOrUnderscore+
	;

fragment
HexDigitOrUnderscore
	:	HexDigit
	|	'_'
	;

fragment
OctalNumeral
	:	'0' Underscores? OctalDigits
	;

fragment
OctalDigits
	:	OctalDigit (OctalDigitsAndUnderscores? OctalDigit)?
	;

fragment
OctalDigit
	:	[0-7]
	;

fragment
OctalDigitsAndUnderscores
	:	OctalDigitOrUnderscore+
	;

fragment
OctalDigitOrUnderscore
	:	OctalDigit
	|	'_'
	;

fragment
BinaryNumeral
	:	'0' [bB] BinaryDigits
	;

fragment
BinaryDigits
	:	BinaryDigit (BinaryDigitsAndUnderscores? BinaryDigit)?
	;

fragment
BinaryDigit
	:	[01]
	;

fragment
BinaryDigitsAndUnderscores
	:	BinaryDigitOrUnderscore+
	;

fragment
BinaryDigitOrUnderscore
	:	BinaryDigit
	|	'_'
	;

// §3.10.2 Floating-Point Literals

FloatingPointLiteral
	:	DecimalFloatingPointLiteral
	|	HexadecimalFloatingPointLiteral
	;

fragment
DecimalFloatingPointLiteral
	:	Digits '.' Digits? ExponentPart? FloatTypeSuffix?
	|	'.' Digits ExponentPart? FloatTypeSuffix?
	|	Digits ExponentPart FloatTypeSuffix?
	|	Digits FloatTypeSuffix
	;

fragment
ExponentPart
	:	ExponentIndicator SignedInteger
	;

fragment
ExponentIndicator
	:	[eE]
	;

fragment
SignedInteger
	:	Sign? Digits
	;

fragment
Sign
	:	[+-]
	;

fragment
FloatTypeSuffix
	:	[fFdD]
	;

fragment
HexadecimalFloatingPointLiteral
	:	HexSignificand BinaryExponent FloatTypeSuffix?
	;

fragment
HexSignificand
	:	HexNumeral '.'?
	|	'0' [xX] HexDigits? '.' HexDigits
	;

fragment
BinaryExponent
	:	BinaryExponentIndicator SignedInteger
	;

fragment
BinaryExponentIndicator
	:	[pP]
	;

// §3.10.3 Boolean Literals

BooleanLiteral
	:	'true'
	|	'false'
	;

// §3.10.4 Character Literals

CharacterLiteral
	:	'\'' SingleCharacter '\''
	|	'\'' EscapeSequence '\''
	;

fragment
SingleCharacter
	:	~['\\\r\n]
	;

// §3.10.5 String Literals

StringLiteral
	:	'"' StringCharacters? '"'
	;

fragment
StringCharacters
	:	StringCharacter+
	;

fragment
StringCharacter
	:	~["\\\r\n]
	|	EscapeSequence
	;

// §3.10.6 Escape Sequences for Character and String Literals

fragment
EscapeSequence
	:	'\\' [btnfr"'\\]
	|	OctalEscape
    |   UnicodeEscape // This is not in the spec but prevents having to preprocess the input
	;

fragment
OctalEscape
	:	'\\' OctalDigit
	|	'\\' OctalDigit OctalDigit
	|	'\\' ZeroToThree OctalDigit OctalDigit
	;

fragment
ZeroToThree
	:	[0-3]
	;

// This is not in the spec but prevents having to preprocess the input
fragment
UnicodeEscape
    :   '\\' 'u'+ HexDigit HexDigit HexDigit HexDigit
    ;

// §3.10.7 The Null Literal

NullLiteral
	:	'null'
	;

// §3.11 Separators

LPAREN : '(';
RPAREN : ')';
LBRACE : '{';
RBRACE : '}';
LBRACK : '[';
RBRACK : ']';
SEMI : ';';
COMMA : ',';
DOT : '.';
ELLIPSIS : '...';
AT : '@';
COLONCOLON : '::';


// §3.12 Operators

ASSIGN : '=';
GT : '>';
LT : '<';
BANG : '!';
TILDE : '~';
QUESTION : '?';
COLON : ':';
ARROW : '->';
EQUAL : '==';
LE : '<=';
GE : '>=';
NOTEQUAL : '!=';
AND : '&&';
OR : '||';
INC : '++';
DEC : '--';
ADD : '+';
SUB : '-';
MUL : '*';
DIV : '/';
BITAND : '&';
BITOR : '|';
CARET : '^';
MOD : '%';
//LSHIFT : '<<';
//RSHIFT : '>>';
//URSHIFT : '>>>';

ADD_ASSIGN : '+=';
SUB_ASSIGN : '-=';
MUL_ASSIGN : '*=';
DIV_ASSIGN : '/=';
AND_ASSIGN : '&=';
OR_ASSIGN : '|=';
XOR_ASSIGN : '^=';
MOD_ASSIGN : '%=';
LSHIFT_ASSIGN : '<<=';
RSHIFT_ASSIGN : '>>=';
URSHIFT_ASSIGN : '>>>=';

// §3.8 Identifiers (must appear after all keywords in the grammar)

Identifier
	:	JavaLetter JavaLetterOrDigit*
	;

fragment
JavaLetter
	:	[a-zA-Z$_] // these are the "java letters" below 0x7F
	|	// covers all characters above 0x7F which are not a surrogate
		~[\u0000-\u007F\uD800-\uDBFF]
		{Character.isJavaIdentifierStart(this.InputStream.LA(-1))}?
	|	// covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
		[\uD800-\uDBFF] [\uDC00-\uDFFF]
		{Character.isJavaIdentifierStart(Character.toCodePoint((char)this.InputStream.LA(-2), (char)this.InputStream.LA(-1)))}?
	;

fragment
JavaLetterOrDigit
	:	[a-zA-Z0-9$_] // these are the "java letters or digits" below 0x7F
	|	// covers all characters above 0x7F which are not a surrogate
		~[\u0000-\u007F\uD800-\uDBFF]
		{Character.isJavaIdentifierPart(this.InputStream.LA(-1))}?
	|	// covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
		[\uD800-\uDBFF] [\uDC00-\uDFFF]
		{Character.isJavaIdentifierPart(Character.toCodePoint((char)this.InputStream.LA(-2), (char)this.InputStream.LA(-1)))}?
	;

//
// Whitespace and comments
//

WS  :  [ \t\r\n\u000C]+ -> channel(HIDDEN)
    ;

COMMENT
    :   '/*' .*? '*/' -> channel(HIDDEN)
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> channel(HIDDEN)
    ;
