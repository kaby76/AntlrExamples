// XPath v3.1
// Author--Ken Domino
// Date--4 June 2020
// 
// This is a faithful implementation of the XPath version 3.1 gramar
// from the spec at https://www.w3.org/TR/2017/REC-xpath-31-20170321/
// I have gone through this grammar very, very carefully to make sure
// that it is essentially identical to the spec, that it implements
// the lexical and parsing structures as stated in the spec.
// I have verified this grammar against thousands of test expressions.
// All online xpath "parsers" only seem to require data in xml format. This
// is a pure, no bullshit parser.
//
// A side note on the implementation of this grammar. I copied the grammar
// from the spec then employed Antlrvsix to refactor the grammar.
//
// Note on alternatives:
// https://github.com/exquery/xpath3-parser/blob/master/src/main/antlr4/org/exquery/xpath/parser/XPath3.g4
// This grammar does not implement correctly:
// * the lexical structure of the comment token;
// * the lexical structure of the QName token;
// * the lexical structure of the NCName token.
//
// https://github.com/antlr/grammars-v4/blob/master/xpath/xpath.g4
// This grammar is for version 1.

parser grammar XPath31Parser;

options { tokenVocab=XPath31Lexer; }

xpath : expr EOF ;
paramlist : param ( COMMA param)* ;
param : DOLLAR eqname typedeclaration? ;
functionbody : enclosedexpr ;
enclosedexpr : OC expr? CC ;
expr : exprsingle ( COMMA exprsingle)* ;
exprsingle : forexpr | letexpr | quantifiedexpr | ifexpr | orexpr ;
forexpr : simpleforclause KW_RETURN exprsingle ;
simpleforclause : KW_FOR simpleforbinding ( COMMA simpleforbinding)* ;
simpleforbinding : DOLLAR varname KW_IN exprsingle ;
letexpr :    simpleletclause KW_RETURN exprsingle ;
simpleletclause : KW_LET simpleletbinding ( COMMA simpleletbinding)* ;
simpleletbinding : DOLLAR varname CEQ exprsingle ;
quantifiedexpr :    ( KW_SOME | KW_EVERY) DOLLAR varname KW_IN exprsingle ( COMMA DOLLAR varname KW_IN exprsingle)* KW_SATISFIES exprsingle ;
ifexpr : KW_IF OP expr CP KW_THEN exprsingle KW_ELSE exprsingle ;
orexpr : andexpr ( KW_OR andexpr )* ;
andexpr : comparisonexpr ( KW_AND comparisonexpr )* ;
comparisonexpr : stringconcatexpr ( (valuecomp | generalcomp | nodecomp) stringconcatexpr )? ;
stringconcatexpr : rangeexpr ( PP rangeexpr )* ;
rangeexpr : additiveexpr ( KW_TO additiveexpr )? ;
additiveexpr : multiplicativeexpr ( ( PLUS | MINUS) multiplicativeexpr )* ;
multiplicativeexpr : unionexpr ( ( STAR | KW_DIV | KW_IDIV | KW_MOD) unionexpr )* ;
unionexpr : intersectexceptexpr ( ( KW_UNION | P) intersectexceptexpr )* ;
intersectexceptexpr : instanceofexpr ( ( KW_INTERSECT | KW_EXCEPT) instanceofexpr )* ;
instanceofexpr : treatexpr ( KW_INSTANCE KW_OF sequencetype )? ;
treatexpr : castableexpr ( KW_TREAT KW_AS sequencetype )? ;
castableexpr : castexpr ( KW_CASTABLE KW_AS singletype )? ;
castexpr : arrowexpr ( KW_CAST KW_AS singletype )? ;
arrowexpr : unaryexpr ( EG arrowfunctionspecifier argumentlist )* ;
unaryexpr : ( MINUS | PLUS)* valueexpr ;
valueexpr : simplemapexpr ;
generalcomp : EQ | NE | LT | LE | GT | GE ;
valuecomp : KW_EQ | KW_NE | KW_LT | KW_LE | KW_GT | KW_GE ;
nodecomp : KW_IS | LL | GG ;
simplemapexpr : pathexpr ( BANG pathexpr)* ;
pathexpr : ( SLASH relativepathexpr?) | ( SS relativepathexpr) | relativepathexpr ;
relativepathexpr : stepexpr (( SLASH | SS) stepexpr)* ;
stepexpr : postfixexpr | axisstep ;
axisstep : (reversestep | forwardstep) predicatelist ;
forwardstep : (forwardaxis nodetest) | abbrevforwardstep ;
forwardaxis : ( KW_CHILD COLONCOLON) | ( KW_DESCENDANT COLONCOLON) | ( KW_ATTRIBUTE COLONCOLON) | ( KW_SELF COLONCOLON) | ( KW_DESCENDANT_OR_SELF COLONCOLON) | ( KW_FOLLOWING_SIBLING COLONCOLON) | ( KW_FOLLOWING COLONCOLON) | ( KW_NAMESPACE COLONCOLON) ;
abbrevforwardstep : AT? nodetest ;
reversestep : (reverseaxis nodetest) | abbrevreversestep ;
reverseaxis : ( KW_PARENT COLONCOLON) | ( KW_ANCESTOR COLONCOLON) | ( KW_PRECEDING_SIBLING COLONCOLON) | ( KW_PRECEDING COLONCOLON) | ( KW_ANCESTOR_OR_SELF COLONCOLON) ;
abbrevreversestep : DD ;
nodetest : kindtest | nametest ;
nametest : eqname | wildcard ;
wildcard : STAR | (NCName CS) | ( SC NCName) | (BracedURILiteral STAR) ;
postfixexpr : primaryexpr (predicate | argumentlist | lookup)* ;
argumentlist : OP (argument ( COMMA argument)*)? CP ;
predicatelist : predicate* ;
predicate : OB expr CB ;
lookup : QM keyspecifier ;
keyspecifier : NCName | IntegerLiteral | parenthesizedexpr | STAR ;
arrowfunctionspecifier : eqname | varref | parenthesizedexpr ;
primaryexpr : literal | varref | parenthesizedexpr | contextitemexpr | functioncall | functionitemexpr | mapconstructor | arrayconstructor | unarylookup ;
literal : numericliteral | StringLiteral ;
numericliteral : IntegerLiteral | DecimalLiteral | DoubleLiteral ;
varref : DOLLAR varname ;
varname : eqname ;
parenthesizedexpr : OP expr? CP ;
contextitemexpr : D ;
functioncall : eqname argumentlist ;
argument : exprsingle | argumentplaceholder ;
argumentplaceholder : QM ;
functionitemexpr : namedfunctionref | inlinefunctionexpr ;
namedfunctionref : eqname POUND IntegerLiteral /* xgc: reserved-function-names */;
inlinefunctionexpr : KW_FUNCTION OP paramlist? CP ( KW_AS sequencetype)? functionbody ;
mapconstructor : KW_MAP OC (mapconstructorentry ( COMMA mapconstructorentry)*)? CC ;
mapconstructorentry : mapkeyexpr COLON mapvalueexpr ;
mapkeyexpr : exprsingle ;
mapvalueexpr : exprsingle ;
arrayconstructor : squarearrayconstructor | curlyarrayconstructor ;
squarearrayconstructor : OB (exprsingle ( COMMA exprsingle)*)? CB ;
curlyarrayconstructor : KW_ARRAY enclosedexpr ;
unarylookup : QM keyspecifier ;
singletype : simpletypename QM? ;
typedeclaration : KW_AS sequencetype ;
sequencetype : ( KW_EMPTY_SEQUENCE OP CP) | (itemtype occurrenceindicator?) ;
occurrenceindicator : QM | STAR | PLUS ;
itemtype : kindtest | ( KW_ITEM OP CP) | functiontest | maptest | arraytest | atomicoruniontype | parenthesizeditemtype ;
atomicoruniontype : eqname ;
kindtest : documenttest | elementtest | attributetest | schemaelementtest | schemaattributetest | pitest | commenttest | texttest | namespacenodetest | anykindtest ;
anykindtest : KW_NODE OP CP ;
documenttest : KW_DOCUMENT_NODE OP (elementtest | schemaelementtest)? CP ;
texttest : KW_TEXT OP CP ;
commenttest : KW_COMMENT OP CP ;
namespacenodetest : KW_NAMESPACE_NODE OP CP ;
pitest : KW_PROCESSING_INSTRUCTION OP (NCName | StringLiteral)? CP ;
attributetest : KW_ATTRIBUTE OP (attribnameorwildcard ( COMMA typename)?)? CP ;
attribnameorwildcard : attributename | STAR ;
schemaattributetest : KW_SCHEMA_ATTRIBUTE OP attributedeclaration CP ;
attributedeclaration : attributename ;
elementtest : KW_ELEMENT OP (elementnameorwildcard ( COMMA typename QM?)?)? CP ;
elementnameorwildcard : elementname | STAR ;
schemaelementtest : KW_SCHEMA_ELEMENT OP elementdeclaration CP ;
elementdeclaration : elementname ;
attributename : eqname ;
elementname : eqname ;
simpletypename : typename ;
typename : eqname ;
functiontest : anyfunctiontest | typedfunctiontest ;
anyfunctiontest : KW_FUNCTION OP STAR CP ;
typedfunctiontest : KW_FUNCTION OP (sequencetype ( COMMA sequencetype)*)? CP KW_AS sequencetype ;
maptest : anymaptest | typedmaptest ;
anymaptest : KW_MAP OP STAR CP ;
typedmaptest : KW_MAP OP atomicoruniontype COMMA sequencetype CP ;
arraytest : anyarraytest | typedarraytest ;
anyarraytest : KW_ARRAY OP STAR CP ;
typedarraytest : KW_ARRAY OP sequencetype CP ;
parenthesizeditemtype : OP itemtype CP ;

// Error in the spec. EQName also includes acceptable keywords.
eqname : QName | URIQualifiedName
 | KW_RETURN
 | KW_FOR
 | KW_IN
 | KW_LET
 | KW_SOME
 | KW_EVERY
 | KW_SATISFIES
 | KW_IF
 | KW_THEN
 | KW_ELSE
 | KW_OR
 | KW_AND
 | KW_DIV
 | KW_IDIV
 | KW_MOD
 | KW_UNION
 | KW_INTERSECT
 | KW_EXCEPT
 | KW_INSTANCE
 | KW_OF
 | KW_TREAT
 | KW_AS
 | KW_CASTABLE
 | KW_CAST
 | KW_EQ
 | KW_NE
 | KW_LT
 | KW_LE
 | KW_GT
 | KW_GE
 | KW_IS
 | KW_CHILD
 | KW_DESCENDANT
 | KW_ATTRIBUTE
 | KW_SELF
 | KW_DESCENDANT_OR_SELF
 | KW_FOLLOWING_SIBLING
 | KW_FOLLOWING
 | KW_NAMESPACE
 | KW_PARENT
 | KW_ANCESTOR
 | KW_PRECEDING_SIBLING
 | KW_PRECEDING
 | KW_ANCESTOR_OR_SELF
 | KW_FUNCTION
 | KW_MAP
 | KW_ARRAY
 | KW_EMPTY_SEQUENCE
 | KW_ITEM
 | KW_NODE
 | KW_DOCUMENT_NODE
 | KW_TEXT
 | KW_COMMENT
 | KW_NAMESPACE_NODE
 | KW_PROCESSING_INSTRUCTION
 | KW_SCHEMA_ATTRIBUTE
 | KW_ELEMENT
 | KW_SCHEMA_ELEMENT
 ;

