%{
#include <stdarg.h>
#include <stdio.h>	
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "cgen.h"

#define YYERROR_VERBOSE 1

extern int yylex(void);
extern uint32_t line_num;
extern FILE **fout_ref;

/*  handy clean-up function */
void 
tf(char *s) 
  {if(s != NULL && strcmp(s, "") != 0) {free(s);}}
  
/* print c-main */  
void pbody();

/* print ptuc-fudger */
void fudger(char *mods, char *decl, char *body);

/* print the header */  
void pheader(char *s);

/* count the number of occurrences of 'c' in 'in_str' */
uint32_t find_counts(char *in_str, char c);

/* pointerize identifiers */
char *ident_to_pointer(char *s);

/* bracketize identifiers */
char *ident_to_array(char *s, char *array_pad);

/* pad cdata to identifiers */
char *ident_to_cdata(char *s, char *cdata);

%}



%union
{
    char* crepr;
}

/* for a more detailed error desc. */
%define parse.error verbose

%token <crepr> IDENT
%token <crepr> POSINT 
%token <crepr> REAL 
%token <crepr> STRING
%token <crepr> STR_LIT

%token KW_PROGRAM 
%token KW_BEGIN 
%token KW_END

%token KW_AND
%token KW_ARRAY
%token KW_BOOLEAN
%token KW_CHAR
%token KW_DIV
%token KW_DO
%token KW_ELSE
%token KW_FOR
%token KW_FUNCTION
%token KW_GOTO
%token KW_IF
%token KW_INTEGER
%token KW_VAR
%token KW_MOD
%token KW_NOT
%token KW_OF
%token KW_OR
%token KW_WHILE
%token KW_PROCEDURE
%token KW_REAL
%token KW_REPEAT
%token KW_TO
%token KW_RESULT
%token KW_RETURN
%token KW_THEN
%token KW_UNTIL
%token KW_DOWNTO
%token KW_TYPE
%token KW_BOOL_TRUE
%token KW_BOOL_FALSE

/* exp. module support */
%token KW_MODULE
%token KW_USE

/* arithmetic operators */
%token KW_OP_PLUS      // +
%token KW_OP_MINUS     // -
%token KW_OP_MUL       // *
%token KW_OP_DIV       // /

/* relational operator keywords */
%token KW_EQ           // =
%token KW_DIFF         // <>
%token KW_LESS_EQ      // <=
%token KW_LESS         // <
%token KW_GREATER      // >
%token KW_GREATER_EQ   // >=

/* logical operators */
%token KW_OP_AND       // &&
%token KW_OP_OR        // ||
%token KW_OP_NOT       // !

/* assignment operators */
%token KW_OP_ASSIGN    // :=

/* (remaining) delimiters */
%token KW_SEMICOLON    // ;
%token KW_COMMA        // ,
%token KW_DOT          // .
%token KW_LPAR         // (
%token KW_RPAR         // )
%token KW_LBRA         // [
%token KW_RBRA         // ]
%token KW_COLON        // :

%start program

/* data-types */
%type <crepr> cdata cdata_with_type type_cast 

/* declarations */
%type <crepr> decls type_decl type_decl_list type_decl_single

/* identifiers */
%type <crepr> ident_list ident_with_bracket //ident_list_with_bracket

/* variable related */
%type <crepr> var_decl var_decl_list var_decl_single

/* array related */
%type <crepr> brackets_list

/* assignments */
%type <crepr> assign_stmt

/* expr. related */
%type <crepr> lit_vals string_vals scalar_vals bool_vals 

%type <crepr> one_side_exp two_side_exp expression

/* statement related */
%type <crepr> statement statements statement_list common_stmt

/* individual statement blocks (for main and procs) */
%type <crepr> while_stmt for_stmt if_stmt 
              goto_stmt label_stmt ret_stmt
              
/* individual statement blocks for function */
%type <crepr> result_stmt func_while_stmt func_for_stmt func_if_stmt 
              func_label_stmt func_ret_stmt ret_val         
              
/* function related */              
%type <crepr> func_decl func_body func_stmts func_statement_list func_stmt             

/* procedure related */
%type <crepr> proc_decl

/* arguments */
%type <crepr> arguments arglist func_arguments func_arglist type_only_arguments

/* including modules */
%type <crepr> incl_mod incl_mods 

/* header and body */
%type <crepr> program_decl body

/* proc calls */
%type <crepr> proc_call func_proc_call

/* expressions */
%type <crepr> basic_exp exp_join func_exp_join



/* this is to free each discarded value in case of error. */
%destructor {
  /* action */ 
  tf($$); 
    if(yyerror_count == 0) {
      /* increment error counts */
      yyerror_count++;
    }
  } 
  /* tag of action application */
  <crepr>
  
/* 
  Associativity Rules.

  A couple of notes are that as per
  specification we have 8 precedence
  classes -- the lower the number the
  more dominant that group's precedence is.
*/


%left KW_SEMICOLON

/* Class 8 prec. group */
%left KW_OP_OR KW_OR

/* Class 7 prec. group */
%left KW_OP_AND KW_AND      

/* Class 6 prec. group */
%left KW_EQ KW_DIFF KW_LESS_EQ KW_LESS KW_GREATER_EQ KW_GREATER

/* Class 5 prec. group */
%left KW_OP_PLUS KW_OP_MINUS

/* Class 4 prec. group */
%left KW_OP_MUL KW_OP_DIV KW_DIV KW_MOD
      
/* Class 3 prec. group (for casting) */
//%precedence TYPE_CAST_PREC
%right TYPE_CAST_PREC

/* Class 2 prec. group */
%right UNARY_PREC

/* Class 1 prec. group (highest precedence) */
%right KW_NOT KW_OP_NOT

/* dangling else lookalikes */
%precedence IF_THEN
%precedence KW_ELSE

%%

program:  
  incl_mods program_decl decls body KW_DOT   		  
  {
    if(yyerror_count == 0) 
      {pheader($2); fudger($1, $3, $4); pbody();}
    else {tf($1); tf($2); tf($3); tf($4);}
  }
  ;


incl_mods:
      {$$ = "";}
      | incl_mods incl_mod KW_SEMICOLON 
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      ;
          
incl_mod:
      KW_MODULE IDENT incl_mods KW_BEGIN decls KW_END KW_DOT 
      {
        $$ = template("// included module %s\n%s\n%s", $2, $3, $5); 
        tf($2); tf($3); tf($5);
      }
      | error KW_SEMICOLON {$$ = "";};
      ;

program_decl:
    KW_PROGRAM IDENT KW_SEMICOLON  	{ $$ = $2; }
    | error KW_SEMICOLON {$$ = "";}
    ;

body: 
    KW_BEGIN statements KW_END
        {$$ = template("{%s}", $2); tf($2);}
    | KW_BEGIN error KW_END
        {$$ = "";}
    ;

/* flexible decls allow in any order variable, type, function decls */      
decls:
      /* in case of no decls */
      {$$ = "";}
      | decls error KW_SEMICOLON {$$ = $1;}
      | decls type_decl 
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      | decls var_decl 
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      | decls func_decl
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      | decls proc_decl
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      ;

/* sub-program decl. */

/* proc. decl. */
proc_decl:
    KW_PROCEDURE IDENT
        KW_LPAR type_only_arguments KW_RPAR KW_SEMICOLON
        decls body KW_SEMICOLON
        {
            $$ = template("void %s(%s) {\n%s\n%s}\n",
                $2, $4, $7, $8);
            tf($2); tf($4); tf($7); tf($8);
        }
    ;

/* function-decl. */
func_decl:
    KW_FUNCTION IDENT
        KW_LPAR type_only_arguments KW_RPAR
        KW_COLON cdata_with_type KW_SEMICOLON
        decls func_body KW_SEMICOLON
        {
            $$ = template("%s %s(%s) {%s result;\n%s\n%s\nreturn result;}\n",
                $7, $2, $4, $7, $9, $10);
            tf($2); tf($4); tf($7); tf($9); tf($10);
        }
    ;

func_body: 
    KW_BEGIN func_stmts KW_END  {$$ = template("{%s}", $2); tf($2);}
    | KW_BEGIN error KW_END     {$$ = "";}
    ;

/* functions have their own statement decl. as
   they need to accommodate the 'result' statement */
func_stmts:
    {$$ = "";}
    | func_statement_list  { $$ = $1; }
    ;

func_statement_list: 
    func_stmt
    | func_statement_list KW_SEMICOLON func_stmt
        { $$ = template("%s%s", $1, $3); tf($1); tf($3); }
    ;
    
func_stmt:
      common_stmt       {$$ = $1;}
      | func_proc_call  {$$ = template("%s;\n", $1); tf($1);}
      | func_while_stmt {$$ = $1;}
      | func_for_stmt   {$$ = $1;}
      | func_if_stmt    {$$ = $1;}
      | func_label_stmt {$$ = $1;}
      | func_ret_stmt   {$$ = $1;}
      | result_stmt     {$$ = $1;}
      | func_body       {$$ = $1;}
      ;
            
        
/* 
  handle variable array size, eat up brackets in a
  padding fashion e.g. [] -> [][] -> [][][] ... 
*/
brackets_list:
      KW_LBRA POSINT KW_RBRA
        {$$ = template("[%s]", $2); tf($2);}
      | brackets_list KW_LBRA POSINT KW_RBRA
        {$$ = template("%s[%s]", $1, $3); tf($1); tf($3);}
      ;

/* type-decl. */
type_decl:
      KW_TYPE type_decl_list {$$ = $2;}
      ;
       
type_decl_list:
      type_decl_single {$$ = $1;}
      | type_decl_list type_decl_single 
        {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
      ;

/* type with data types */       
type_decl_single:
      IDENT KW_EQ cdata_with_type KW_SEMICOLON 
        {$$ = template("\ttypedef %s %s;", $3, $1); tf($1); tf($3);}
      
      | IDENT KW_EQ KW_ARRAY KW_OF 
                      cdata_with_type KW_SEMICOLON
        {
          $$ = template("\ttypedef %s* %s;", $5, $1); 
          tf($1); tf($5);
        }
      | IDENT KW_EQ KW_ARRAY brackets_list KW_OF 
                      cdata_with_type KW_SEMICOLON
        {
          $$ = template("\ttypedef %s %s%s;", $6, $1, $4); 
          tf($1); tf($4); tf($6);
        }
      | IDENT KW_EQ KW_FUNCTION 
              KW_LPAR type_only_arguments KW_RPAR KW_COLON 
              cdata_with_type KW_SEMICOLON
        {
          $$ = template("\ttypedef %s (*%s)(%s);", $8, $1, $5);
          tf($1); tf($5); tf($8);
        }
       | IDENT KW_EQ KW_PROCEDURE 
              KW_LPAR type_only_arguments KW_RPAR KW_SEMICOLON
        {
          $$ = template("\ttypedef void (*%s)(%s);", $1, $5);
          tf($1); tf($5);
        } 
       ;

/* variables */
var_decl:
        KW_VAR var_decl_list 
          { $$ = template("%s\n", $2); tf($2); }
        ;

var_decl_list:
        var_decl_single {$$ = $1;}
        | var_decl_list var_decl_single 
          {$$ = template("%s\n%s", $1, $2); tf($1); tf($2);}
        ;
        
var_decl_single:
      ident_list KW_COLON cdata_with_type KW_SEMICOLON 
        {$$ = template("\t%s %s;\n", $3, $1); tf($1); tf($3);}
      | ident_list KW_COLON KW_ARRAY KW_OF cdata_with_type KW_SEMICOLON 
        {
          /* pointerize the identifier list */
          char *s = ident_to_pointer($1);
          if(s == NULL) 
            {tf(s); tf($5); yyerror("No memory to allocate in order to pointerize");}
          else
            {$$ = template("\t%s %s;\n", $5, s); tf($1); tf($5); tf(s);}
        }     
      | ident_list KW_COLON KW_ARRAY brackets_list KW_OF cdata_with_type KW_SEMICOLON 
        { 
          /* bracketize the identifier list */
          char *s = ident_to_array($1, $4);
          if(s == NULL) 
            {tf(s); tf($4); tf($6); yyerror("No memory to allocate in order to bracketize");}
          else
            {$$ = template("\t%s %s;\n", $6, s); tf($1); tf($4); tf($6); tf(s);}
        }
      ;
                

/* identifiers */
ident_list:
        IDENT {$$ = $1;}
        | ident_list KW_COMMA IDENT 
          {$$ = template("%s, %s", $1, $3); tf($1); tf($3);}
        ;

/* this is to allow ident[index] scheme */
ident_with_bracket:
        IDENT 
          {$$ = $1;}
        | IDENT brackets_list 
          {$$ = template("%s%s", $1, $2); tf($1); tf($2);}
        ;    
    

/* main body statements */      
statements:
    {$$ = "";}
    | statement_list  { $$ = $1; }
    ;

statement_list: 
    statement
    | statement_list KW_SEMICOLON statement
        { $$ = template("%s%s", $1, $3); tf($1); tf($3); }
    ;

common_stmt:
          assign_stmt     {$$ = $1;}
          | goto_stmt     {$$ = $1;}
          ;
          
statement: 
          common_stmt     {$$ = $1;}
          | proc_call     {$$ = template("%s;\n", $1); tf($1);}
          | while_stmt    {$$ = $1;}
          | for_stmt      {$$ = $1;}
          | if_stmt       {$$ = $1;}
          | label_stmt    {$$ = $1;}
          | ret_stmt      {$$ = $1;}
          | body          {$$ = $1;}
          ;         
          
/* handle assignment operator (:=) */
assign_stmt:
      ident_with_bracket KW_OP_ASSIGN exp_join 
        {$$ = template("%s = %s;\n", $1, $3); tf($1); tf($3);}
      ;
         
while_stmt:
         KW_WHILE exp_join KW_DO statement
          {$$ = template("while(%s) {\n%s}\n", $2, $4); tf($2); tf($4);}  
         | KW_REPEAT statement KW_UNTIL exp_join
          {$$ = template("do {\n%s\n} while(!(%s));\n", $2, $4); tf($2); tf($4);}
         ;                

for_stmt:
        KW_FOR ident_with_bracket KW_OP_ASSIGN exp_join KW_TO exp_join KW_DO statement
        {
          $$ = template("for(%s= %s; %s <= %s; %s++) {\n %s\n}", 
                            $2, $4, $2, $6, $2, $8);
          tf($2); tf($4); tf($6); tf($8);
        }
        | KW_FOR ident_with_bracket KW_OP_ASSIGN exp_join KW_DOWNTO exp_join KW_DO statement
        {
          $$ = template("for(%s= %s; %s <= %s; %s--) {\n %s\n}", 
                            $2, $4, $2, $6, $2, $8);
          tf($2); tf($4); tf($6); tf($8);
        }
        ;
        
if_stmt:
      /* enforce this preference as you can't have two consecutive 
         if's but only inside nested 'body' tags (i.e. complex commands) */
      KW_IF exp_join KW_THEN statement %prec IF_THEN
        {$$ = template("if( %s ) {\n%s}\n", $2, $4); tf($2); tf($4);}
      | KW_IF exp_join KW_THEN statement KW_ELSE statement
        {
          $$ = template("if( %s ) {\n%s}\nelse %s\n",$2, $4, $6); 
          tf($2); tf($4); tf($6);
        } 
      ;
      
goto_stmt:
      KW_GOTO IDENT
        {$$ = template("goto %s;\n", $2); tf($2);}
      ;
        
label_stmt:
      IDENT KW_COLON statement
        {$$ = template("%s: {\n%s};\n", $1, $3); tf($1); tf($3);}        
      ;
      
/* return statement */
ret_stmt:
        KW_RETURN {$$ = strdup("return;\n");}
        ;      
      
/*
    Special statement version for functions
*/

func_label_stmt:
      IDENT KW_COLON func_stmt
        {$$ = template("%s: {\n%s};\n", $1, $3); tf($1); tf($3);}        
      ;

func_if_stmt:
      /* enforce this preference as you can't have two consecutive 
         if's but only inside nested 'body' tags (i.e. complex commands) */
      KW_IF func_exp_join KW_THEN func_stmt %prec IF_THEN
        {$$ = template("if( %s ) {\n%s}\n", $2, $4); tf($2); tf($4);}
      | KW_IF func_exp_join KW_THEN func_stmt KW_ELSE func_stmt
        {
          $$ = template("if( %s ) {\n%s}\nelse %s\n",$2, $4, $6); 
          tf($2); tf($4); tf($6);
        } 
      ;
      
func_for_stmt:
        KW_FOR ident_with_bracket KW_OP_ASSIGN func_exp_join 
          KW_TO func_exp_join KW_DO func_stmt
        {
          $$ = template("for(%s= %s; %s <= %s; %s++) {\n %s\n}", 
                            $2, $4, $2, $6, $2, $8);
          tf($2); tf($4); tf($6); tf($8);
        }
        | KW_FOR ident_with_bracket KW_OP_ASSIGN func_exp_join 
          KW_DOWNTO func_exp_join KW_DO func_stmt
        {
          $$ = template("for(%s= %s; %s <= %s; %s--) {\n %s\n}", 
                            $2, $4, $2, $6, $2, $8);
          tf($2); tf($4); tf($6); tf($8);
        }
        ;
        
func_while_stmt:
         KW_WHILE func_exp_join KW_DO func_stmt
          {$$ = template("while(%s) {\n%s}\n", $2, $4); tf($2); tf($4);}  
         | KW_REPEAT func_stmt KW_UNTIL func_exp_join
          {$$ = template("do {\n%s\n} while(!(%s));\n", $2, $4); tf($2); tf($4);}
         ;               

result_stmt:
         KW_RESULT KW_OP_ASSIGN func_exp_join
          {$$ = template("result = %s;\n", $3); tf($3);}
         ;
        
func_ret_stmt:        
        KW_RETURN ret_val 
         {$$ = template("return %s;", $2); tf($2);}
        | KW_RETURN {$$ = strdup("return result;\n");}
        ;   
        
/* return value types */               
ret_val:
    func_exp_join
        {$$ = $1;}
    ;

         
/* function calls */
proc_call: IDENT KW_LPAR arguments KW_RPAR 			
            { $$ = template("%s(%s)", $1, $3); tf($1); tf($3); };
                  

func_proc_call: IDENT KW_LPAR func_arguments KW_RPAR 			
            { $$ = template("%s(%s)", $1, $3); tf($1); tf($3); };

/* function arguments */

/* type only arguments */
type_only_arguments:
      {$$ = "";}
      | ident_list KW_COLON cdata_with_type
        {
          char *s = ident_to_cdata($1, $3);
          if(s == NULL) {
            tf($3); yyerror("No memory to pad cdata to ident");
          } else 
            {$$ = s; tf($1); tf($3);}
          
        }
      | type_only_arguments KW_SEMICOLON ident_list KW_COLON cdata_with_type
        {
          char *s = ident_to_cdata($3, $5);
          if(s == NULL) {
            tf($3); tf($5); yyerror("No memory to pad cdata to ident");
          } else {
            $$ = template("%s, %s", $1, s); 
            tf($1); tf($3); tf($5); tf(s);
          }
          
        }
      ;

/* all arguments */

/* inside proc. and main arguments */
arguments :									
    /* no arguments */  { $$ = ""; }
    | arglist           { $$ = $1; }
    ;

arglist:
    exp_join { $$ = $1; }
    | arglist KW_COMMA exp_join
        {$$ = template("%s,%s", $1, $3); tf($1); tf($3);}
    ;

/* inside function arguments */
func_arguments :									
    /* no arguments */  { $$ = ""; }
    | func_arglist      { $$ = $1; }
    ;

func_arglist:
       func_exp_join
        {$$ = $1;}
       | arglist KW_COMMA func_exp_join 			
        {$$ = template("%s,%s", $1, $3); tf($1); tf($3);}
       ;


/* basic expressions join with potential cast identifiers */
exp_join:
    ident_with_bracket  {$$ = $1;}
    | basic_exp         {$$ = $1;}
    ;
          
/* function flavor to take in account the 'result' keyword */
func_exp_join:
          ident_with_bracket  {$$ = $1;}
          | basic_exp         {$$ = $1;}
          | KW_RESULT         {$$ = strdup("result");}
          ;

/* composition for all of the types that can be an expression */
basic_exp: 
          type_cast exp_join %prec TYPE_CAST_PREC
            {$$ = template("%s %s", $1, $2); tf($1); tf($2); }
          | KW_LPAR basic_exp KW_RPAR {$$ = template("(%s)", $2); tf($2);}
          | proc_call
            {$$ = $1;}
          | lit_vals
            {$$ = $1;}
          | string_vals
            {$$ = $1;}
          | expression
            {$$ = $1;}
          ;
       
expression:
          one_side_exp {$$ = $1;}
          | two_side_exp {$$ = $1;}
          ;

/* two sided expr, e.g. expr or expr, expr and expr etc */                    
two_side_exp:
        /* basic arithmetic operators */
        exp_join KW_OP_PLUS exp_join 
          {$$ = template("%s + %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_OP_MINUS exp_join 
          {$$ = template("%s - %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_OP_MUL exp_join 
          {$$ = template("%s * %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_OP_DIV exp_join 
          {$$ = template("%s / %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_DIV exp_join 
          {$$ = template("%s / %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_MOD exp_join 
          {$$ = template("%s %% %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_EQ exp_join 
          {$$ = template("%s == %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_DIFF exp_join 
          {$$ = template("%s != %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_LESS_EQ exp_join 
          {$$ = template("%s <= %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_LESS exp_join 
          {$$ = template("%s < %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_GREATER_EQ exp_join 
          {$$ = template("%s >= %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_GREATER exp_join 
          {$$ = template("%s > %s", $1, $3); tf($1); tf($3);}
          
        /* logical and binary operators */
        | exp_join KW_OP_AND exp_join 
          {$$ = template("%s && %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_AND exp_join 
          {$$ = template("%s && %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_OP_OR exp_join 
          {$$ = template("%s || %s", $1, $3); tf($1); tf($3);}
        | exp_join KW_OR exp_join 
          {$$ = template("%s or %s", $1, $3); tf($1); tf($3);}
        ;

/* single sided expr, e.g. ! expr, -1.0 etc */                            
one_side_exp:
        KW_NOT exp_join {$$ = template("!%s", $2); tf($2);}
        | KW_OP_NOT exp_join {$$ = template("!%s", $2); tf($2);}
        | KW_OP_PLUS exp_join %prec UNARY_PREC
          {$$ = template("+%s", $2); tf($2);}
        | KW_OP_MINUS exp_join %prec UNARY_PREC 
          {$$ = template("-%s", $2); tf($2);}
        ;

/* expression that we use to allow casting with inf. nested pars */          
type_cast:
      KW_LPAR type_cast KW_RPAR 
        {$$ = template("(%s)", $2); tf($2);}
      | KW_LPAR cdata_with_type KW_RPAR
        {$$ = template("(%s)", $2); tf($2);} 
      ; 

/* data-types using no cast */          
cdata:
      KW_BOOLEAN {$$ = "bool";}
      | KW_CHAR {$$ = "char";}
      | KW_INTEGER {$$ = "int";}
      | KW_REAL {$$ = "double";}
      ;
      
/* data-types that might use cast to type */
cdata_with_type:      
      cdata     {$$ = strdup($1);}
      | IDENT   {$$ = $1;}
      ;  

/* string values */
string_vals: 
      STR_LIT   {$$ = $1;}
      | STRING	{$$ = string_ptuc2c($1);}
      ;

/* scalar/bool values */      
lit_vals:
      scalar_vals {$$ = $1;}
      | bool_vals {$$ = $1;} 
      ;      
      
scalar_vals:
      POSINT  {$$ = $1;}
      | REAL	{$$ = $1;}
      ;

bool_vals:
      KW_BOOL_TRUE    {$$ = strdup("true");}
      | KW_BOOL_FALSE {$$ = strdup("false");}
      ;
%%

/* print c-main */
void
pbody() {
  fprintf(*fout_ref != NULL ? *fout_ref : stdout,
    "int\nmain() {ptuc_fudger(); return 0;}\n");
}

/* print ptuc-fudger */
void
fudger(char *mods, char *decl, char *body) {
  fprintf(*fout_ref != NULL ? *fout_ref : stdout,
    "void ptuc_fudger() \n{\n%s\n%s\n%s}\n", mods, decl, body);
  tf(mods); tf(decl); tf(body);
}

/* print the header */
void
pheader(char *s) {
    fprintf(*fout_ref ? *fout_ref : stdout,
            "%s", c_prologue);
    fprintf(*fout_ref ? *fout_ref : stdout,
            "/* !! pTUC -> C99 converter v0.1 !! */\n");
    fprintf(*fout_ref ? *fout_ref : stdout,
            "\n/* !! This is probably an autogenerated file... !! */\n");
    fprintf(*fout_ref ? *fout_ref : stdout,
            "/* converted program name:  %s */ \n\n", s);
    tf(s);
}

/* count the number of occurrences of 'c' in 'in_str' */
uint32_t
find_counts(char *in_str, char c) {
    uint32_t vars = 0, idx = 0;
    for(vars = 0, idx = 0;
        in_str[idx];
        in_str[idx] == c ? vars++, idx++ : idx++) {}
    return vars;
}

/* pointerize identifiers */
char *
ident_to_pointer(char *s) {
    if(s == NULL || strcmp(s, "") == 0)
    {return "";}
    /* find the number of variables */
    uint32_t vars = find_counts(s, ',');
    size_t buf_len = strlen(s)+(4*vars)+1;
    char *cur_tok = cur_tok = strtok(s, ","),
            *new_buf = calloc(buf_len, sizeof(char));
    if(new_buf == NULL)
    {return NULL;}
    while(cur_tok != NULL) {
        strcat(new_buf, " *");
        strcat(new_buf, cur_tok);
        cur_tok = strtok(NULL, ",");
        if(cur_tok != NULL)
        {strcat(new_buf, ",");}
    }
    return new_buf;
}

/* bracketize identifiers */
char *
ident_to_array(char *s, char *array_pad) {
    if(s == NULL || array_pad == NULL ||
       strcmp(s, "") == 0 ||
       strcmp(array_pad, "") == 0)
    {return "";}
    /* find the number of variables */
    uint32_t vars = find_counts(s, ',');
    /*
      len of 's' plus len of 'array_pad' times vars+1
      plus equal number of "," plus couple
      'null' bytes
    */
    size_t buf_len = strlen(s)+
                     ((vars+1)*strlen(array_pad))+
                     (vars*3)+2;
    char *cur_tok = cur_tok = strtok(s, ","),
            *new_buf = calloc(buf_len, sizeof(char));
    if(new_buf == NULL)
    {return NULL;}
    while(cur_tok != NULL) {
        strcat(new_buf, cur_tok);
        strcat(new_buf, array_pad);
        cur_tok = strtok(NULL, ",");
        if(cur_tok != NULL)
        {strcat(new_buf, ",");}
    }
    return new_buf;
}

/* pad cdata to identifiers */
char *
ident_to_cdata(char *s, char *cdata) {
    if(s == NULL || cdata == NULL ||
       strcmp(s, "") == 0 ||
       strcmp(cdata, "") == 0)
    {return "";}
    /* find the number of variables */
    uint32_t vars = find_counts(s, ',');
    /*
      len of 's' plus len of 'cdata' times `vars`+1 plus
      equal number of "," and " " plus 'null' bytes
    */
    size_t buf_len = strlen(s)+
                     ((vars+1)*strlen(cdata))+
                     (vars*5)+2;
    char *cur_tok = cur_tok = strtok(s, ","),
            *new_buf = calloc(buf_len, sizeof(char));
    if(new_buf == NULL)
    {return NULL;}
    while(cur_tok != NULL) {
        strcat(new_buf, cdata);
        strcat(new_buf, " ");
        strcat(new_buf, cur_tok);
        cur_tok = strtok(NULL, ",");
        if(cur_tok != NULL)
        {strcat(new_buf, ",");}
    }
    return new_buf;
}
