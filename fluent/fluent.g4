grammar fluent;

/* An FTL file defines a Resource consisting of Entries. */
resource            : (entry | Blank_block | junk)*;

/* Entries are the main building blocks of Fluent. They define translations and
 * contextual and semantic information about the translations. During the AST
 * construction, adjacent comment lines of the same comment type (defined by
 * the number of #) are joined together. Single-# comments directly preceding
 * Messages and Terms are attached to the Message or Term and are not
 * standalone Entries. */
entry               : (message Line_end)
                      | (term Line_end)
                      | commentLine;
message             : identifier Blank_inline? '=' Blank_inline? ((pattern attribute*) | (attribute+));
term                : '-' identifier Blank_inline? '=' Blank_inline? pattern attribute*;

/* Adjacent comment lines of the same comment type are joined together during
 * the AST construction. */
commentLine         : ('###' | '##' | '#') ('\u0020' Comment_char*)? Line_end;
Comment_char        : Any_char /*TODO - Line_end */;

/* Junk represents unparsed content.
 *
 * Junk is parsed line-by-line until a line is found which looks like it might
 * be a beginning of a new message, term, or a comment. Any whitespace
 * following a broken Entry is also considered part of Junk.
 */
junk                : Junk_line (Junk_line /*TODO - '#' - '-' - [a-zA-Z] */ )*;
Junk_line           : /[^\n]*/ ('\u000A' | EOF);

/* Attributes of Messages and Terms. */
attribute           : Line_end Blank? '.' identifier Blank_inline? '=' Blank_inline? pattern;

/* Patterns are values of Messages, Terms, Attributes and Variants. */
pattern             : patternElement+;

/* TextElement and Placeable can occur inline or as block.
 * Text needs to be indented and start with a non-special character.
 * Placeables can start at the beginning of the line or be indented.
 * Adjacent TextElements are joined in AST creation. */
patternElement      : Inline_text
                      | Block_text
                      | inline_placeable
                      | block_placeable;
Inline_text         : Text_char+;
Block_text          : Blank_block Blank_inline Indented_char Inline_text?;
inline_placeable    : '{' Blank? (selectExpression | inlineExpression) Blank? '}';
block_placeable     : Blank_block Blank_inline? inline_placeable;

/* Rules for validating expressions in Placeables and as selectors of
 * SelectExpressions are documented in spec/valid.md and enforced in
 * syntax/abstract.js. */
inlineExpression    : StringLiteral
                      | NumberLiteral
                      | functionReference
                      | messageReference
                      | termReference
                      | variableReference
                      | inline_placeable;

/* Literals */
StringLiteral       : '"' Quoted_char* '"';
NumberLiteral       : '-'? Digits ('.' Digits)?;

/* Inline Expressions */
functionReference   : identifier callArguments;
messageReference    : identifier attributeAccessor?;
termReference       : '-' identifier attributeAccessor? callArguments?;
variableReference   : '$' identifier;
attributeAccessor   : '.' identifier;
callArguments       : Blank? '(' Blank? argument_list Blank? ')';
argument_list       : (argument Blank? ',' Blank?)* argument?;
argument            : namedArgument
                      | inlineExpression;
namedArgument       : identifier Blank? ':' Blank? (StringLiteral | NumberLiteral);

/* Block Expressions */
selectExpression    : inlineExpression Blank? '->' Blank_inline? variant_list;
variant_list        : variant* defaultVariant variant* Line_end;
variant             : Line_end Blank? variantKey Blank_inline? pattern;
defaultVariant      : Line_end Blank? '*' variantKey Blank_inline? pattern;
variantKey          : '[' Blank? (NumberLiteral | identifier) Blank? ']';

/* Identifier */
identifier : Identifier;



// LEXER

Identifier          : [a-zA-Z] [a-zA-Z0-9_-]*;

/* Content Characters
 *
 * Translation content can be written using any Unicode characters. However,
 * some characters are considered special depending on the type of content
 * they're in. See text_char and quoted_char for more information.
 *
 * Some Unicode characters, even if allowed, should be avoided in Fluent
 * resources. See spec/recommendations.md.
 */
Any_char            : [\u0000-\u{10FFFF}];

/* Text elements
 *
 * The primary storage for content are text elements. Text elements are not
 * delimited with quotes and may span multiple lines as long as all lines are
 * indented. The opening brace ({) marks a start of a placeable in the pattern
 * and may not be used in text elements verbatim. Due to the indentation
 * requirement some text characters may not appear as the first character on a
 * new line.
 */
Special_text_char   : '{'
                      | '}';
Text_char           : Any_char /*TODO - Special_text_char - Line_end */;
Indented_char       : Text_char /*TODO - '[' - '*' - '.' */;

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
Special_quoted_char : '"'
                      | '\\';
Special_escape      : '\\' Special_quoted_char;
Unicode_escape      : ('\\u' /[0-9a-fA-F]{4}/)
                      | ('\\U' /[0-9a-fA-F]{6}/);
Quoted_char         : (Any_char /*TODO - Special_quoted_char - Line_end */)
                      | Special_escape
                      | Unicode_escape;

/* Numbers */
Digits              : [0-9]+;

/* Whitespace */
Blank_inline        : '\u0020'+;
Line_end            : '\u000D\u000A'
                      | '\u000A'
		      ;
Blank_block         : (Blank_inline? Line_end)+;
Blank               : (Blank_inline | Line_end)+;
