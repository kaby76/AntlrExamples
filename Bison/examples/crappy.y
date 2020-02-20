%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "calc.tab.h"

	extern int lineno;
	int variable_counter = 0;

/* Flex functions */
	int yylex(void);
	void yyerror(char *s);
	void set_variable(char* var_name, int var_value);
	int get_variable_value(char* var_name);
	extern FILE* yyin;
	%}

%union {
	char index[100];
	int num;
}

%token TOK_NUMBER TOK_MUL TOK_ADD TOK_NEGNUM TOK_EQUAL TOK_MAIN TOK_ORBRACKET TOK_CRBRACKET TOK_OCBRACKET TOK_CCBRACKET TOK_SEMICOLON TOK_PRINT TOK_VARIABLE

   %code requires {
	struct symtable
	{
		char var_name[100];
		int var_value;
	};
}

%code {
	struct symtable symboltable[100];
	int pos = 0;
}

%type <num> expr TOK_NUMBER TOK_NEGNUM
   %type <index> TOK_VARIABLE

   %left TOK_ADD
   %left TOK_MUL

   %%

prog:
    TOK_MAIN TOK_ORBRACKET TOK_CRBRACKET TOK_OCBRACKET stmts TOK_CCBRACKET
		    ;

stmts:
    | stmt TOK_SEMICOLON stmts
		    ;

stmt:
    expr TOK_SEMICOLON
		    | TOK_PRINT expr TOK_SEMICOLON      {   fprintf(stdout, "%d\n", $2);    }
    | assignment
		    ;

expr:
    TOK_NUMBER                                  { $$ = $1; }
    | TOK_VARIABLE                              { $$ = get_variable_value($1); }
    | expr TOK_MUL expr                         { $$ = $1 * $3; }
    | expr TOK_ADD expr                         { $$ = $1 + $3; }
    | TOK_NEGNUM                                { $$ = -$1; }
    | TOK_ORBRACKET expr TOK_CRBRACKET          { $$ = $2; }
    ;

assignment:
    TOK_VARIABLE TOK_EQUAL expr { set_variable($1, $3); }
    ;

    %%

		    void set_variable(char* var_name, int var_value) {
	    int counter;
	    bool found = false;
	    for (counter = 0; counter<=variable_counter; counter++) {
		    if (strcmp(var_name, symboltable[counter].var_name) == 0) {
			    found = true;
			    break;
		    }
	    }

	    if(!found) {
		    strcpy(symboltable[counter].var_name, var_name);
		    symboltable[counter].var_value = var_value;
		    variable_counter++;
	    }
    }

    int get_variable_value(char* var_name) {
	    int counter;
	    for (counter = 0; counter<=variable_counter; counter++) {
		    if (strcmp(var_name, symboltable[counter].var_name) == 0) {
			    return symboltable[counter].var_value;
		    }
	    }
    }

    void yyerror(char *s)
    {
	    fprintf(stderr, "Parsing error: line %d and %s\n", lineno, s);
    }

    int main(int argc,char* argv[])
    {
	    if(argc==1) {
		    printf("\nPlease provide an input file name. Exiting...\n");
		    return 0;
	    }

	    yyin = fopen(argv[1], "r");
	    if (!yyin) {
		    printf("ERROR: Couldn't open file %s\n", argv[1]);
		    return -1;
	    } 

	    yyparse();
	    return 0;
    }