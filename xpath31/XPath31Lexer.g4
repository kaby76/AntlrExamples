// XPath v3.1
// Author--Ken Domino
// 
// https://www.w3.org/TR/2017/REC-xpath-31-20170321/
// Alternatives:
// https://github.com/exquery/xpath3-parser/blob/master/src/main/antlr4/org/exquery/xpath/parser/XPath3.g4
// https://github.com/antlr/grammars-v4/blob/master/xpath/xpath.g4

lexer grammar XPath31Lexer;

options { superClass = XpathBase; }

// KEYWORDS

AT : '@' ;
BANG : '!' ;
CB : ']' ;
CC : '}' ;
CEQ : ':=' ;
COLON : ':' ;
COLONCOLON : '::' ;
COMMA : ',' ;
CP : ')' ;
CS : ':*' ;
D : '.' ;
DD : '..' ;
DOLLAR : '$' ;
EG : '=>' ;
EQ : '=' ;
GE : '>=' ;
GG : '>>' ;
GT : '>' ;
LE : '<=' ;
LL : '<<' ;
LT : '<' ;
MINUS : '-' ;
NE : '!=' ;
OB : '[' ;
OC : '{' ;
OP : '(' ;
P : '|' ;
PLUS : '+' ;
POUND : '#' ;
PP : '||' ;
QM : '?' ;
SC : '*:' ;
SLASH : '/' ;
SS : '//' ;
STAR : '*' ;

KW_ANCESTOR : 'ancestor' ;
KW_ANCESTOR_OR_SELF : 'ancestor-or-self' ;
KW_AND : 'and' ;
KW_ARRAY : 'array' ;
KW_AS : 'as' ;
KW_ATTRIBUTE : 'attribute' ;
KW_CAST : 'cast' ;
KW_CASTABLE : 'castable' ;
KW_CHILD : 'child' ;
KW_COMMENT : 'comment' ;
KW_DESCENDANT : 'descendant' ;
KW_DESCENDANT_OR_SELF : 'descendant-or-self' ;
KW_DIV : 'div' ;
KW_DOCUMENT_NODE : 'document-node' ;
KW_ELEMENT : 'element' ;
KW_ELSE : 'else' ;
KW_EMPTY_SEQUENCE : 'empty-sequence' ;
KW_EQ : 'eq' ;
KW_EVERY : 'every' ;
KW_EXCEPT : 'except' ;
KW_FOLLOWING : 'following' ;
KW_FOLLOWING_SIBLING : 'following-sibling' ;
KW_FOR : 'for' ;
KW_FUNCTION : 'function' ;
KW_GE : 'ge' ;
KW_GT : 'gt' ;
KW_IDIV : 'idiv' ;
KW_IF : 'if' ;
KW_IN : 'in' ;
KW_INSTANCE : 'instance' ;
KW_INTERSECT : 'intersect' ;
KW_IS : 'is' ;
KW_ITEM : 'item' ;
KW_LE : 'le' ;
KW_LET : 'let' ;
KW_LT : 'lt' ;
KW_MAP : 'map' ;
KW_MOD : 'mod' ;
KW_NAMESPACE : 'namespace' ;
KW_NAMESPACE_NODE : 'namespace-node' ;
KW_NE : 'ne' ;
KW_NODE : 'node' ;
KW_OF : 'of' ;
KW_OR : 'or' ;
KW_PARENT : 'parent' ;
KW_PRECEDING : 'preceding' ;
KW_PRECEDING_SIBLING : 'preceding-sibling' ;
KW_PROCESSING_INSTRUCTION : 'processing-instruction' ;
KW_RETURN : 'return' ;
KW_SATISFIES : 'satisfies' ;
KW_SCHEMA_ATTRIBUTE : 'schema-attribute' ;
KW_SCHEMA_ELEMENT : 'schema-element' ;
KW_SELF : 'self' ;
KW_SOME : 'some' ;
KW_TEXT : 'text' ;
KW_THEN : 'then' ;
KW_TO : 'to' ;
KW_TREAT : 'treat' ;
KW_UNION : 'union' ;

// A.2.1. TEMINAL SYMBOLS

IntegerLiteral :Digits ;
DecimalLiteral : ('.' Digits) | (Digits '.' [0-9]*) ;
DoubleLiteral : (('.' Digits) | (Digits ('.' [0-9]*)?)) [eE] [+-]? Digits ;
StringLiteral : ('"' (EscapeQuot | ~[^"])* '"') | ('\'' (EscapeApos | ~['])* '\'') ;
URIQualifiedName : BracedURILiteral Name ;
BracedURILiteral : 'Q' '{' [^{}]* '}' ;
EscapeQuot : '""' ; 
EscapeApos : '\'';
Comment : '(:' (CommentContents | Comment)* ':)' ;
QName  :  NTQName ;
NCName : NTNCName ;
Char : NTChar ;

// Fragments

fragment Digits : [0-9]+ ;
fragment CommentContents : Char+ { NoNestingCommentCheck() }? ;

// https://www.w3.org/TR/REC-xml-names/#NT-QName

fragment NTQName : PrefixedName | UnprefixedName ;
fragment PrefixedName : Prefix ':' LocalPart ;
fragment UnprefixedName : LocalPart ;
fragment Prefix : NTNCName ;
fragment LocalPart : NTNCName ;
fragment NTNCName : Name ;
fragment NameStartChar
  :  ':'
  | 'A'..'Z'
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
fragment NameChar
  :  NameStartChar | '-' | '.' | '0'..'9'
  |  '\u00B7' | '\u0300'..'\u036F'
  |  '\u203F'..'\u2040'
  ;
fragment Name  :  NameStartChar NameChar*  ;
fragment Names : Name ('\u0020' Name)* ;
fragment Nmtoken : NameChar+ ;
fragment Nmtokens : Nmtoken ('\u0020' Nmtoken)* ;

// https://www.w3.org/TR/REC-xml/#NT-Char

fragment NTChar : '\u0009' | '\u000a' | '\u000d'
  | '\u0020'..'\ud7ff'
  | '\ue000'..'\ufffd'
  | '\u{10000}'..'\u{10ffff}'
 ;
Whitespace :  ('\u0020' | '\u0008' | '\u000d' | '\u000a')+ ->skip ;

