/* Bison Grammar Parser                             -*- C -*-

   Copyright (C) 2002-2015, 2018-2020 Free Software Foundation, Inc.

   This file is part of Bison, the GNU Compiler Compiler.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


                     /*==========\
                     | Grammar.  |
                     \==========*/


parser grammar BisonParser;

options {
    tokenVocab=BisonLexer;
}

input
    : prologue_declarations '%%' bison_grammar epilogue_opt
    ;

        /*------------------------------------.
        | Declarations: before the first %%.  |
        `------------------------------------*/

prologue_declarations
    : | prologue_declarations prologue_declaration
    ;

prologue_declaration
    : grammar_declaration
    | PROLOGUE
//| '%<flag>'
    | '%debug'
    | '%locations'
//| '%<flag>'
    | '%define' variable value
    | '%defines'
    | '%defines' STRING
    | OBS_PERCENT_ERROR_VERBOSE
    | '%expect' INT
    | '%expect-rr' INT
    | '%file-prefix' STRING
    | '%glr-parser'
    | '%initial-action' actionBlock
    | '%language' STRING
    | PERCENT_NAME_PREFIX STRING
    | '%no-lines'
    | '%nondeterministic-parser'
    | OBS_OUTPUT STRING
    | '%param' params
    | PERCENT_PURE_PARSER
    | PARSE actionBlock+
    | LEX actionBlock
    | '%require' STRING
    | '%skeleton' STRING
    | TOKEN_TABLE
    | '%verbose'
    | '%yacc'
    | ';'
    ;

params
    : params actionBlock
    | actionBlock
    ;


/*----------------------.
| grammar_declaration.  |
`----------------------*/

grammar_declaration
    : symbol_declaration
    | '%start' symbol
    | code_props_type actionBlock generic_symlist
    | '%default-prec'
    | '%no-default-prec'
    | '%code' actionBlock
    | '%code' ID actionBlock
    | '%union' union_name actionBlock
    ;

code_props_type
    : '%destructor'
    | '%printer'
    ;

/*---------.
| %union.  |
`---------*/

union_name
    : | ID
    ;

symbol_declaration
    : '%nterm' nterm_decls
    | '%token' token_decls
    | '%type' symbol_decls
    | precedence_declarator token_decls_for_prec
    ;

precedence_declarator
    : '%left'
    | '%right'
    | '%nonassoc'
    | '%precedence'
    ;

tag_opt
    : | TAG
    ;

generic_symlist
    : generic_symlist_item
    | generic_symlist generic_symlist_item
    ;

generic_symlist_item
    : symbol
    | tag
    ;

tag
    : TAG
    | '<*>'
    | '<>'
    ;

/*-----------------------.
| nterm_decls (%nterm).  |
`-----------------------*/

// A non empty list of possibly tagged symbols for %nterm.
//
// Can easily be defined like symbol_decls but restricted to ID, but
// using token_decls allows to reudce the number of rules, and also to
// make nicer error messages on '%nterm 'a'' or '%nterm FOO 'foo''.

nterm_decls
    : token_decls
    ;

/*-----------------------------------.
| token_decls (%token, and %nterm).  |
`-----------------------------------*/

// A non empty list of possibly tagged symbols for %token or %nterm.

token_decls
    : token_decl_1
    | TAG token_decl_1
    | token_decls TAG token_decl_1
    ;

// One or more symbol declarations for %token or %nterm.

token_decl_1
    : token_decl
    | token_decl_1 token_decl
    ;
  
// One symbol declaration for %token or %nterm.

token_decl
    : id int_opt alias
    | id id '(' id ')' alias    // Not in Bison, but used in https://github.com/ruby/ruby/parse.y
    ;

int_opt
    : | INT
    ;

alias
    : | string_as_id
//| TSTRING
    ;


/*-------------------------------------.
| token_decls_for_prec (%left, etc.).  |
`-------------------------------------*/

// A non empty list of possibly tagged tokens for precedence declaration.
//
// Similar to %token (token_decls), but in '%left FOO 1 'foo'', it treats
// FOO and 'foo' as two different symbols instead of aliasing them.

token_decls_for_prec
    : token_decl_for_prec_1
    | TAG token_decl_for_prec_1
    | token_decls_for_prec TAG token_decl_for_prec_1
    ;

// One or more token declarations for precedence declaration.

token_decl_for_prec_1
    : token_decl_for_prec
    | token_decl_for_prec_1 token_decl_for_prec
    ;

// One token declaration for precedence declaration.

token_decl_for_prec
    : id int_opt
    | string_as_id
    ;


/*-----------------------------------.
| symbol_decls (argument of %type).  |
`-----------------------------------*/

// A non empty list of typed symbols (for %type).

symbol_decls
    : symbol_decl_1
    | TAG symbol_decl_1
    | symbol_decls TAG symbol_decl_1
    ;

// One or more token declarations (for %type).

symbol_decl_1
    : symbol
    | symbol_decl_1 symbol
    ;

        /*------------------------------------------.
        | The grammar section: between the two %%.  |
        `------------------------------------------*/

bison_grammar
    : rules_or_grammar_declaration
    | bison_grammar rules_or_grammar_declaration
    ;

/* As a Bison extension, one can use the grammar declarations in the
   body of the grammar.  */

rules_or_grammar_declaration
    : rules
    | grammar_declaration ';'
    ;

rules
    : id named_ref_opt ':' rhses_1
    ;

rhses_1
    : rhs       # rhs1
    | rhses_1 '|' rhs       # rhs2
    | rhses_1 ';'       # rhs3
    ;

rhs
    : | rhs symbol named_ref_opt
      | rhs tag_opt actionBlock named_ref_opt
      | rhs BRACED_PREDICATE
      | rhs '%empty'
      | rhs '%prec' symbol
      | rhs '%dprec' INT
      | rhs '%merge' TAG
      | rhs '%expect' INT
      | rhs '%expect-rr' INT
    ;

named_ref_opt
    : | BRACKETED_ID
    ;


/*---------------------.
| variable and value.  |
`---------------------*/

variable
    : ID
    ;

value
    : | ID
      | STRING
      | actionBlock
    ;


/*--------------.
| Identifiers.  |
`--------------*/

/* Identifiers are returned as uniqstr values by the scanner.
   Depending on their use, we may need to make them genuine symbols.  */

id
    : ID
    | CHAR
    ;

symbol
    : id
    | string_as_id
    ;

/* A string used as an ID: quote it.  */

string_as_id
    : STRING
    ;

epilogue_opt
    : | '%%' EPILOGUE?
    ;

actionBlock
    : BRACED_CODE
    ;