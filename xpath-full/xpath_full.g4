// XPath v3.1
// Author--Ken Domino
// 
// https://www.w3.org/TR/2017/REC-xpath-31-20170321/

grammar xpath_full;

xpath	   :   	expr EOF ;

paramlist	   :   	param ( COMMA param)*	;

param	   : DOLLAR eqname typedeclaration?	;

functionbody	   :   	enclosedexpr	;

enclosedexpr	   : OC expr? CC	;

expr	   :   	exprsingle ( COMMA exprsingle)*	;

exprsingle	   :   	forexpr
| letexpr
| quantifiedexpr
| ifexpr
| orexpr	
;

forexpr	   :   	simpleforclause RETURN exprsingle	;

simpleforclause	   : FOR simpleforbinding ( COMMA simpleforbinding)*	;

simpleforbinding	   : DOLLAR varname IN exprsingle	;

letexpr	   :   	simpleletclause RETURN exprsingle	;

simpleletclause	   : LET simpleletbinding ( COMMA simpleletbinding)*	;

simpleletbinding	   : DOLLAR varname CEQ exprsingle	;

quantifiedexpr	   :   	( SOME | EVERY) DOLLAR varname IN exprsingle ( COMMA DOLLAR varname IN exprsingle)* SATISFIES exprsingle	;

ifexpr	   : IF OP expr CP THEN exprsingle ELSE exprsingle	;

orexpr	   :   	andexpr ( OR andexpr )*	;

andexpr	   :   	comparisonexpr ( AND comparisonexpr )*	;

comparisonexpr	   :   	stringconcatexpr ( (valuecomp
| generalcomp
| nodecomp) stringconcatexpr )?	
;

stringconcatexpr	   :   	rangeexpr ( PP rangeexpr )*	;

rangeexpr	   :   	additiveexpr ( TO additiveexpr )?	;

additiveexpr	   :   	multiplicativeexpr ( ( PLUS | MINUS) multiplicativeexpr )*	;

multiplicativeexpr	   :   	unionexpr ( ( STAR | DIV | IDIV | MOD) unionexpr )*	;

unionexpr	   :   	intersectexceptexpr ( ( UNION | P) intersectexceptexpr )*	;

intersectexceptexpr	   :   	instanceofexpr ( ( INTERSECT | EXCEPT) instanceofexpr )*	;

instanceofexpr	   :   	treatexpr ( INSTANCE OF sequencetype )?	;

treatexpr	   :   	castableexpr ( TREAT AS sequencetype )?	;

castableexpr	   :   	castexpr ( CASTABLE AS singletype )?	;

castexpr	   :   	arrowexpr ( CAST AS singletype )?	;

arrowexpr	   :   	unaryexpr ( SEQGT arrowfunctionspecifier argumentlist )*	;

unaryexpr	   :   	( MINUS | PLUS)* valueexpr	;

valueexpr	   :   	simplemapexpr	;

generalcomp	   : SEQUAL | SNOTEQUAL | SLT | SLE | SGT | SGE	;

valuecomp	   : EQ | NE | LT | LE | GT | GE	;

nodecomp	   : IS | SLTLT | SGTGT	;

simplemapexpr	   :   	pathexpr ( SBANG pathexpr)*	;

pathexpr	   :   	( SSLASH relativepathexpr?)
| ( SSLASHSLASH relativepathexpr)
| relativepathexpr	/* xgc: leading-lone-slash */
;

relativepathexpr	   :   	stepexpr (( SSLASH | SSLASHSLASH) stepexpr)*	;

stepexpr	   :   	postfixexpr | axisstep	;

axisstep	   :   	(reversestep | forwardstep) predicatelist	;

forwardstep	   :   	(forwardaxis nodetest) | abbrevforwardstep	;

forwardaxis	   :   	( CHILD SCOLONCOLON)
| ( DESCENDANT SCOLONCOLON)
| ( ATTRIBUTE SCOLONCOLON)
| ( SELF SCOLONCOLON)
| ( DESCENDANT_OR_SELF SCOLONCOLON)
| ( FOLLOWING_SIBLING SCOLONCOLON)
| ( FOLLOWING SCOLONCOLON)
| ( NAMESPACE SCOLONCOLON)	
;

abbrevforwardstep	   : SAT? nodetest	;

reversestep	   :   	(reverseaxis nodetest) | abbrevreversestep	;

reverseaxis	   :   	( PARENT SCOLONCOLON)
| ( ANCESTOR SCOLONCOLON)
| ( PRECEDING_SIBLING SCOLONCOLON)
| ( PRECEDING SCOLONCOLON)
| ( ANCESTOR_OR_SELF SCOLONCOLON)	
;

abbrevreversestep	   : DD	;

nodetest	   :   	kindtest | nametest	;

nametest	   :   	eqname | wildcard	;

wildcard	   : STAR
| (NCName CS)
| ( SC NCName)
| (BracedURILiteral STAR)	/* ws: explicit */
;

postfixexpr	   :   	primaryexpr (predicate | argumentlist | lookup)*	;

argumentlist	   : OP (argument ( COMMA argument)*)? CP	;

predicatelist	   :   	predicate*	;

predicate	   : OB expr CB	;

lookup	   : SQM keyspecifier	;

keyspecifier	   :   	NCName | IntegerLiteral | parenthesizedexpr | STAR	;

arrowfunctionspecifier	   :   	eqname | varref | parenthesizedexpr	;

primaryexpr	   :   	literal
| varref
| parenthesizedexpr
| contextitemexpr
| functioncall
| functionitemexpr
| mapconstructor
| arrayconstructor
| unarylookup	
;

literal	   :   	numericliteral | StringLiteral	;

numericliteral	   :   	IntegerLiteral | DecimalLiteral | DoubleLiteral	;

varref	   : DOLLAR varname	;

varname	   :   	eqname	;

parenthesizedexpr	   : OP expr? CP	;

contextitemexpr	   : D	;

functioncall	   :   	eqname argumentlist	/* xgc: reserved-function-names */
/* gn: parens */
	;

argument	   :   	exprsingle | argumentplaceholder	;

argumentplaceholder	   : SQM	;

functionitemexpr	   :   	namedfunctionref | inlinefunctionexpr	;

namedfunctionref	   :   	eqname SPOUND IntegerLiteral	/* xgc: reserved-function-names */;

inlinefunctionexpr	   : FUNCTION OP paramlist? CP ( AS sequencetype)? functionbody	;

mapconstructor	   : MAP OC (mapconstructorentry ( COMMA mapconstructorentry)*)? CC	;

mapconstructorentry	   :   	mapkeyexpr SCOLON mapvalueexpr	;

mapkeyexpr	   :   	exprsingle	;

mapvalueexpr	   :   	exprsingle	;

arrayconstructor	   :   	squarearrayconstructor | curlyarrayconstructor	;

squarearrayconstructor	   : OB (exprsingle ( COMMA exprsingle)*)? CB	;

curlyarrayconstructor	   : ARRAY enclosedexpr	;

unarylookup	   : SQM keyspecifier	;

singletype	   :   	simpletypename SQM?	;

typedeclaration	   : AS sequencetype	;

sequencetype	   :   	( EMPTY_SEQUENCE OP CP)
| (itemtype occurrenceindicator?)	
;

occurrenceindicator	   : SQM | STAR | PLUS	/* xgc: occurrence-indicators */;

itemtype	   :   	kindtest | ( ITEM OP CP) | functiontest | maptest | arraytest | atomicoruniontype | parenthesizeditemtype	;

atomicoruniontype	   :   	eqname	;

kindtest	   :   	documenttest
| elementtest
| attributetest
| schemaelementtest
| schemaattributetest
| pitest
| commenttest
| texttest
| namespacenodetest
| anykindtest	
;

anykindtest	   : NODE OP CP	;

documenttest	   : DOCUMENT_NODE OP (elementtest | schemaelementtest)? CP	;

texttest	   : TEXT OP CP	;

commenttest	   : COMMENT OP CP	;

namespacenodetest	   : NAMESPACE_NODE OP CP	;

pitest	   : PROCESSING_INSTRUCTION OP (NCName | StringLiteral)? CP	;

attributetest	   : ATTRIBUTE OP (attribnameorwildcard ( COMMA typename)?)? CP	;

attribnameorwildcard	   :   	attributename | STAR	;

schemaattributetest	   : SCHEMA_ATTRIBUTE OP attributedeclaration CP	;

attributedeclaration	   :   	attributename	;

elementtest	   : ELEMENT OP (elementnameorwildcard ( COMMA typename SQM?)?)? CP	;

elementnameorwildcard	   :   	elementname | STAR	;

schemaelementtest	   : SCHEMA_ELEMENT OP elementdeclaration CP	;

elementdeclaration	   :   	elementname	;

attributename	   :   	eqname	;

elementname	   :   	eqname	;

simpletypename	   :   	typename	;

typename	   :   	eqname	;

functiontest	   :   	anyfunctiontest | typedfunctiontest	;

anyfunctiontest	   : FUNCTION OP STAR CP	;

typedfunctiontest	   : FUNCTION OP (sequencetype ( COMMA sequencetype)*)? CP AS sequencetype	;

maptest	   :   	anymaptest | typedmaptest	;

anymaptest	   : MAP OP STAR CP	;

typedmaptest	   : MAP OP atomicoruniontype COMMA sequencetype CP	;

arraytest	   :   	anyarraytest | typedarraytest	;

anyarraytest	   : ARRAY OP STAR CP	;

typedarraytest	   : ARRAY OP sequencetype CP	;

parenthesizeditemtype	   : OP itemtype CP	;

eqname	   :   	QName | URIQualifiedName
	| RETURN
	| FOR
	| IN
	| LET
	| SOME
	| EVERY
	| SATISFIES
	| IF
	| THEN
	| ELSE
	| OR
	| AND
	| DIV
	| IDIV
	| MOD
	| UNION
	| INTERSECT
	| EXCEPT
	| INSTANCE
	| OF
	| TREAT
	| AS
	| CASTABLE
	| CAST
	| EQ
	| NE
	| LT
	| LE
	| GT
	| GE
	| IS
	| CHILD
	| DESCENDANT
	| ATTRIBUTE
	| SELF
	| DESCENDANT_OR_SELF
	| FOLLOWING_SIBLING
	| FOLLOWING
	| NAMESPACE
	| PARENT
	| ANCESTOR
	| PRECEDING_SIBLING
	| PRECEDING
	| ANCESTOR_OR_SELF
	| FUNCTION
	| MAP
	| ARRAY
	| EMPTY_SEQUENCE
	| ITEM
	| NODE
	| DOCUMENT_NODE
	| TEXT
	| COMMENT
	| NAMESPACE_NODE
	| PROCESSING_INSTRUCTION
	| SCHEMA_ATTRIBUTE
	| ELEMENT
	| SCHEMA_ELEMENT
  ;


// KEYWORDS

COMMA : ',' ;

DOLLAR : '$' ;

OC : '{' ;

CC : '}' ;

RETURN : 'return' ;

FOR : 'for' ;

IN : 'in' ;

LET : 'let' ;

CEQ : ':=' ;

SOME : 'some' ;

EVERY : 'every' ;

SATISFIES : 'satisfies' ;

IF : 'if' ;

OP : '(' ;

CP : ')' ;

THEN : 'then' ;

ELSE : 'else' ;

OR : 'or' ;

AND : 'and' ;

PP : '||' ;

TO : 'to' ;

PLUS : '+' ;

MINUS : '-' ;

STAR : '*' ;

DIV : 'div' ;

IDIV : 'idiv' ;

MOD : 'mod' ;

UNION : 'union' ;

P : '|' ;

INTERSECT : 'intersect' ;

EXCEPT : 'except' ;

INSTANCE : 'instance' ;

OF : 'of' ;

TREAT : 'treat' ;

AS : 'as' ;

CASTABLE : 'castable' ;

CAST : 'cast' ;

SEQGT : '=>' ;

SEQUAL : '=' ;

SNOTEQUAL : '!=' ;

SLT : '<' ;

SLE : '<=' ;

SGT : '>' ;

SGE : '>=' ;

EQ : 'eq' ;

NE : 'ne' ;

LT : 'lt' ;

LE : 'le' ;

GT : 'gt' ;

GE : 'ge' ;

IS : 'is' ;

SLTLT : '<<' ;

SGTGT : '>>' ;

SBANG : '!' ;

SSLASH : '/' ;

SSLASHSLASH : '//' ;

CHILD : 'child' ;

SCOLONCOLON : '::' ;

DESCENDANT : 'descendant' ;

ATTRIBUTE : 'attribute' ;

SELF : 'self' ;

DESCENDANT_OR_SELF : 'descendant-or-self' ;

FOLLOWING_SIBLING : 'following-sibling' ;

FOLLOWING : 'following' ;

NAMESPACE : 'namespace' ;

SAT : '@' ;

PARENT : 'parent' ;

ANCESTOR : 'ancestor' ;

PRECEDING_SIBLING : 'preceding-sibling' ;

PRECEDING : 'preceding' ;

ANCESTOR_OR_SELF : 'ancestor-or-self' ;

DD : '..' ;

CS : ':*' ;

SC : '*:' ;

OB : '[' ;

CB : ']' ;

SQM : '?' ;

D : '.' ;

SPOUND : '#' ;

FUNCTION : 'function' ;

MAP : 'map' ;

SCOLON : ':' ;

ARRAY : 'array' ;

EMPTY_SEQUENCE : 'empty-sequence' ;

ITEM : 'item' ;

NODE : 'node' ;

DOCUMENT_NODE : 'document-node' ;

TEXT : 'text' ;

COMMENT : 'comment' ;

NAMESPACE_NODE : 'namespace-node' ;

PROCESSING_INSTRUCTION : 'processing-instruction' ;

SCHEMA_ATTRIBUTE : 'schema-attribute' ;

ELEMENT : 'element' ;

SCHEMA_ELEMENT : 'schema-element' ;


// A.2.1. TEMINAL SYMBOLS

IntegerLiteral	   :  	Digits	;

DecimalLiteral	   :   	('.' Digits) | (Digits '.' [0-9]*)	/* ws: explicit */ ;

DoubleLiteral	   :   	(('.' Digits) | (Digits ('.' [0-9]*)?)) [eE] [+-]? Digits	/* ws: explicit */ ;

StringLiteral	   :   	('"' (EscapeQuot | ~[^"])* '"')
                      | ('\'' (EscapeApos | ~['])* '\'')	/* ws: explicit */ ;

URIQualifiedName	   :   	BracedURILiteral Name	/* ws: explicit */ ;

BracedURILiteral	   :   	'Q' '{' [^{}]* '}'	/* ws: explicit */ ;

EscapeQuot	   :   	'""' ;	

EscapeApos	   :   	'\'';

Comment	   :   	'(:' (CommentContents | Comment)* ':)'	/* ws: explicit */ /* gn: comments */ ;

QName  :  NTQName ;

NCName : NTNCName ;

Char : NTChar ;

// Fragments

fragment
Digits	   :   	[0-9]+	;

fragment
CommentContents	   :   '(:' .*? (':)' | EOF) ;


// https://www.w3.org/TR/REC-xml-names/#NT-QName

fragment
NTQName : PrefixedName | UnprefixedName ;

fragment
PrefixedName : Prefix ':' LocalPart ;

fragment
UnprefixedName : LocalPart ;

fragment
Prefix : NTNCName ;

fragment
LocalPart : NTNCName ;

fragment
NTNCName : Name ;

fragment
NameStartChar
  :  'A'..'Z'
//  :  ':'
//  | 'A'..'Z'
  |  '_'
  | 'a'..'z'
  | '\u00C0'..'\u00D6'
  | '\u00D8'..'\u00F6'
  | '\u00F8'..'\u02FF'
  | '\u0370'..'\u037D'
  | '\u037F'..'\u1FFF'
  | '\u200C'..'\u200D'
  | '\u2070'..'\u218F'
  | '\u2C00'..'\u2FEF'
  | '\u3001'..'\uD7FF'
  | '\uF900'..'\uFDCF'
  | '\uFDF0'..'\uFFFD'
  | '\u{10000}'..'\u{EFFFF}'
  ;

fragment
NameChar
  :  NameStartChar | '-' | '.' | '0'..'9'
  |  '\u00B7' | '\u0300'..'\u036F'
  |  '\u203F'..'\u2040'
  ;

fragment
Name  :  NameStartChar NameChar*  ;

fragment
Names : Name ('\u0020' Name)* ;

fragment
Nmtoken : NameChar+ ;

fragment
Nmtokens : Nmtoken ('\u0020' Nmtoken)* ;

// https://www.w3.org/TR/REC-xml/#NT-Char

fragment
NTChar : '\u0009' | '\u000a' | '\u000d'
  | '\u0020'..'\ud7ff'
  | '\ue000'..'\ufffd'
  | '\u{10000}'..'\u{10ffff}'
 ;

Whitespace
  :  ('\u0020' | '\u0008' | '\u000d' | '\u000a')+ ->skip
  ;

