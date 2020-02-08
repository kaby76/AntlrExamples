# Why you should not use a predicate on the LHS of a lexer rule in Antlr?

Here are some examples that show what happens if you place a predicate at the LHS of a lexer rule.
There are seven programs here:

* a1. LHS predicate with fixed input.
* a2. LHS predicate property.
* a3. RHS predicate property.
* a4. LHS predicate property with COMMENTs.
* a5. RHS predicate property with COMMENTs.
* a6. LHS predicate field.
* a7. RHS predicate field.
* test.sh -- Bash test script. Net Core 3.1 required.
