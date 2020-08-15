grammar fluent;


/* An FTL file defines a Resource consisting of Entries. */
resource            : (entry | blank_block)* EOF;

/* Entries are the main building blocks of Fluent. They define translations and
 * contextual and semantic information about the translations. During the AST
 * construction, adjacent comment lines of the same comment type (defined by
 * the number of #) are joined together. Single-# comments directly preceding
 * Messages and Terms are attached to the Message or Term and are not
 * standalone Entries. */
entry               : (message line_end)
                      | (term line_end)
                      | commentLine
					  ;
message             : identifier blank_inline? '=' blank_inline? ((pattern attribute*) | (attribute+));
term                : '-' identifier blank_inline? '=' blank_inline? pattern attribute*;

/* Adjacent comment lines of the same comment type are joined together during
 * the AST construction. */
commentLine         : ('#' '#' '#' | '#' '#' | '#') (' ' comment_char*)? line_end;
comment_char        : any_char_minus_line_end;

/* Junk represents unparsed content.
 *
 * Junk is parsed line-by-line until a line is found which looks like it might
 * be a beginning of a new message, term, or a comment. Any whitespace
 * following a broken Entry is also considered part of Junk.
 */
junk                : junk_line (junk_line /*TODO - '#' - '-' - [a-zA-Z] */ )*;
junk_line           : .*? (lf | EOF);

/* Attributes of Messages and Terms. */
attribute           : line_end blank? '.' identifier blank_inline? '=' blank_inline? pattern;

/* Patterns are values of Messages, Terms, Attributes and Variants. */
pattern             : patternElement+;

/* TextElement and Placeable can occur inline or as block.
 * Text needs to be indented and start with a non-special character.
 * Placeables can start at the beginning of the line or be indented.
 * Adjacent TextElements are joined in AST creation. */
patternElement      : inline_text
                      | block_text
                      | inline_placeable
                      | block_placeable;
inline_text         : text_char+;
block_text          : blank_block blank_inline indented_char inline_text?;
inline_placeable    : '{' blank? (selectExpression | inlineExpression) blank? '}';
block_placeable     : blank_block blank_inline? inline_placeable;

/* Rules for validating expressions in Placeables and as selectors of
 * SelectExpressions are documented in spec/valid.md and enforced in
 * syntax/abstract.js. */
inlineExpression    : stringLiteral
                      | numberLiteral
                      | functionReference
                      | messageReference
                      | termReference
                      | variableReference
                      | inline_placeable;

/* Literals */
stringLiteral       : '"' quoted_char* '"';
numberLiteral       : '-'? digits ('.' digits)?;

/* Inline Expressions */
functionReference   : identifier callArguments;
messageReference    : identifier attributeAccessor?;
termReference       : '-' identifier attributeAccessor? callArguments?;
variableReference   : '$' identifier;
attributeAccessor   : '.' identifier;
callArguments       : blank? '(' blank? argument_list blank? ')';
argument_list       : (argument blank? ',' blank?)* argument?;
argument            : namedArgument
                      | inlineExpression;
namedArgument       : identifier blank? ':' blank? (stringLiteral | numberLiteral);

/* Block Expressions */
selectExpression    : inlineExpression blank? '-' '>' blank_inline? variant_list;
variant_list        : variant* defaultVariant variant* line_end;
variant             : line_end blank? variantKey blank_inline? pattern;
defaultVariant      : line_end blank? '*' variantKey blank_inline? pattern;
variantKey          : '[' blank? (numberLiteral | identifier) blank? ']';

/* Identifier */
identifier : (lowercase | uppercase) (lowercase | uppercase | digit | underscore | dash)+ ;


/* Content Characters
 *
 * Translation content can be written using any Unicode characters. However,
 * some characters are considered special depending on the type of content
 * they're in. See text_char and quoted_char for more information.
 *
 * Some Unicode characters, even if allowed, should be avoided in Fluent
 * resources. See spec/recommendations.md.
 */
any_char : lowercase | uppercase | digit | underscore | dash | space | line_end | others;
any_char_minus_line_end : lowercase | uppercase | digit | underscore | dash | space | others;

/* Text elements
 *
 * The primary storage for content are text elements. Text elements are not
 * delimited with quotes and may span multiple lines as long as all lines are
 * indented. The opening brace ({) marks a start of a placeable in the pattern
 * and may not be used in text elements verbatim. Due to the indentation
 * requirement some text characters may not appear as the first character on a
 * new line.
 */
special_text_char   : '{' | '}';
text_char           : any_char_minus_line_end /*TODO - Special_text_char - Line_end */;
indented_char       : text_char /*TODO - '[' - '*' - '.' */;

/* String literals
 *
 * For special-purpose content, quoted string literals can be used where text
 * elements are not a good fit. String literals are delimited with double
 * quotes and may not contain line breaks. String literals use the backslash
 * (\) as the escape character. The literal double quote can be inserted via
 * the \" escape sequence. The literal backslash can be inserted with \\. The
 * literal opening brace ({) is allowed in string literals because they may not
 * comprise placeables.
 */
special_quoted_char : '"' | '\\';
special_escape      : '\\' special_quoted_char;
unicode_escape      : 
	(
		'\\' 'u'
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit))
	| (
		'\\' 'U'
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit)
		(a_through_f_lc | a_through_f_uc | digit))
	;
quoted_char         : (any_char_minus_line_end /*TODO - Special_quoted_char - Line_end */)
                      | special_escape
                      | unicode_escape;

/* Numbers */
digits              : digit+;

/* Whitespace */
blank_inline        : space+;
cr : '\r';
lf : '\n';
line_end            : cr lf | lf  ;
blank_block         : (blank_inline? line_end)+;
blank               : (blank_inline | line_end)+;

lowercase :
'a' | 'b' | 'c' | 'd' | 'e' | 'f'
 | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p'
 | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z'
;
a_through_f_lc : 'a' | 'b' | 'c' | 'd' | 'e' | 'f';
uppercase :
 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
 | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P'
 | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z'
 ;
a_through_f_uc :  | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' ;
digit : '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
underscore : '_';
dash : '-';
space : ' ' | '\t';
others : '!' | ',' ;
