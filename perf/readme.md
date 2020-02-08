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

This is the output of running the test:

    ====================
    a1
    Base.
    Token 0 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 1 3 channel OFF_CHANNEL  
    Token 2 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 3 3 channel OFF_CHANNEL  
    Token 4 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 5 3 channel OFF_CHANNEL  
    Token 6 -1 channel DEFAULT_TOKEN_CHANNEL <EOF>

    ( file
      ( DEFAULT_TOKEN_CHANNEL i=0 txt=a tt=1
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=2 txt=a tt=1
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=4 txt=a tt=1
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=6 txt=<EOF> tt=-1
    ) ) 

    Times = 6
    Token 0 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 1 3 channel OFF_CHANNEL  
    Token 2 3 channel OFF_CHANNEL  
    Token 3 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 4 3 channel OFF_CHANNEL  
    Token 5 1 channel DEFAULT_TOKEN_CHANNEL a
    Token 6 -1 channel DEFAULT_TOKEN_CHANNEL <EOF>

    ) 
    ( file
      ( DEFAULT_TOKEN_CHANNEL i=0 txt=a tt=1
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=3 txt=a tt=1
      ) 
      ( OFF_CHANNEL text= 
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=5 txt=a tt=1
      ) 
      ( DEFAULT_TOKEN_CHANNEL i=6 txt=<EOF> tt=-1
    ) ) 

    Times = 7
    ====================
    a2
    Predicate as property lhs.
    Times = 2000001
    Runtime 00:00:04.8586068
    Tokens 2000002
    ====================
    a3
    Predicate as property rhs.
    Times = 0
    Runtime 00:00:01.2840163
    Tokens 2000002
    ====================
    a4
    Predicate as property lhs, with COMMENT to test effect on inter-dfa recognition.
    Times = 72953
    Runtime 00:00:00.5062934
    Tokens 72954
      36476  233778 1067752
       8290    8290   24870
    ====================
    a5
    Predicate as property rhs, with COMMENT to test effect on inter-dfa recognition.
    Times = 0
    Runtime 00:00:00.1004693
    Tokens 72954
      36476  233778 1067752
       8290    8290   24870
    ====================
    a6
    Predicate as field lhs.
    Times = 0
    Runtime 00:00:04.8241921
    Tokens 2000002
    ====================
    a7
    Predicate as field rhs.
    Times = 0
    Runtime 00:00:01.2573492
    Tokens 2000002
