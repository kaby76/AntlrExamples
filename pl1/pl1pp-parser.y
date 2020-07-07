%pure-parser
%name-prefix="pp_yy"
%error-verbose
%locations
%parse-param {int unused}
%{ 
	/* PL1PP-PARSER.Y
	 * ==============
	 *
	 * PL/I preprocessor parser 
	 *
	 * Copyright 2006 Henrik Sorensen
	 *
	 * This file is part of GCC front-end for the PL/I programming language, GCC PL/I.
	 *
	 * GCC PL/I is free software; you can redistribute it and/or modify
	 * it under the terms of the GNU General Public License as published by
	 * the Free Software Foundation; version 2.
	 *
	 * GCC PL/I is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * GNU General Public License for more details.
	 *
	 * You should have received a copy of the GNU General Public License
	 * along with GCC PL/I; see the file COPYING.  If not, write to
	 * the Free Software Foundation, 59 Temple Place - Suite 330,
	 * Boston, MA 02111-1307, USA.
	 *
	 * 
	 */

	/* make with bison -v -d -t pl1pp-parser.y */

#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include "PPDebugLog.h"
#include "TokenLocationStructs.h"
#include "TokenLocation.h"
#include "SavedTokenStructs.h"
#include "ppVariableStructs.h"
#include "ppVariable.h"
#include "PLIMessage.h"
#include "PLIParserStructs.h"
#include "ppIncludeFileUtils.h"


/* ============================= */


int pp_yydebug;

/* OBS: scannerContext is used in some of the sub modules. */
struct ppContextAnchor *scannerContext; 


/* yylex should return tokens from the list of tokens
 * 
 */
struct savedtokenlist *currentToken;

%}

/* 
 * Note keep the token list in sync with pl1-parser.y
 * 
 * Token numbers higher than 0x3000 is only for the preprocessor,
 * for example the INCLUDE and REPLACE are not used in pl1-parser.y
 * 
 */

%token ACTIVATE 0x3000 DEACTIVATE 0x3001 INCLUDE 0x3002 NOPRINT 0x3005 NOTE 0x3010 REPLACE 0x3015 

/* Tokens shared with pl1-parser.y : */


%token STR_CONSTANT 0x0310 NUM 0x0320 NUMFLOAT 0x0330 VARNAME 0x0340 
%token UNKNOWN 0x0350 AND 0x0360 NOT 0x0370 OR 0x0380 CONCAT 0x0390 
%token POWER 0x03a0 PTR 0x03b0 HANDLEPTR 0x03b3 SELFOP 0x03d0
%token GE 0x03e0 LE 0x03f0 NE 0x03f5

%token A 0x0400 ABNORMAL 0x0404 ADDBUFF 0x0408 ALIAS 0x040a ALIGNED 0x040f 
%token ALLOCATE 0x0414 ANYCONDITION 0x0418 AREA 0x041a ASCII 0x041f 
%token ASSEMBLER 0x0424 ASSIGNABLE 0x0428 ATTACH 0x042a ATTENTION 0x042f 
%token AUTOMATIC 0x0434
%token B 0x0500 B1 0x0503 B2 0x0504 B3 0x0505 B4 0x0506 BACKWARDS 0x050f 
%token BASED 0x0513 BEGIN_ 0x0516 BIGENDIAN 0x0519 BINARY 0x051c BIT 0x051f
%token BKWD 0x0523 BLKSIZE 0x0526 BUFFERED 0x0529 BUFFERS 0x052c BUFFOFF 0x052f
%token BUFND 0x0533 BUFNI 0x0536 BUFSP 0x0539 BUILTIN 0x053c BY 0x053f 
%token BYADDR 0x0543 BYVALUE 0x0546 BX 0x0549
%token C 0x0553 CALL 0x0556 CELL 0x0559 CDECL 0x055c CHARACTER 0x055f
%token CHARGRAPHIC 0x0563 CHECK 0x0569 CLOSE 0x056c COBOL 0x056f COLUMN 0x0573
%token COMPLEX 0x0576 CONDITION 0x0579 CONNECTED 0x0582
%token CONSECUTIVE 0x0583 CONSTANT 0x0586 CONTROLLED 0x0589 CONVERSION 0x058c
%token COPY 0x058f CTLASA 0x0593 CTL360 0x0596
%token D 0x0603 DATA 0x0606 DATE 0x0609 DB 0x060c DECLARE 0x060f
%token DECIMAL 0x0613 DEFAULT 0x0616 DEFINE 0x0619 DEFINED 0x061c
%token DELAY 0x061f DELETE 0x0623 DESCRIPTOR 0x0626 DESCRIPTORS 0x0629
%token DETACH 0x062c DIMENSION 0x062f DIRECT 0x0633 DISPLAY 0x0636
%token DO 0x0639 DOWNTHRU 0x063c
%token E 0x0643 EDIT 0x0646 ELSE 0x0649 END 0x064c ENDFILE 0x064f
%token ENDPAGE 0x0653 ENTRY 0x0656 ENVIRONMENT 0x0659 ERROR 0x065c
%token EVENT 0x065f EXCLUSIVE 0x0663 EXIT 0x0666 EXPORTS 0x0669 EXTERNAL  0x066c
%token F 0x066f FB 0x0673 FBS 0x0676 FETCH 0x0679 FETCHABLE 0x067c
%token FILE_ 0x067f FINISH 0x0683 FIXED 0x0686 FIXEDOVERFLOW 0x0689
%token FLOAT 0x0693 FLUSH 0x0696 FOREVER 0x0699 FORMAT 0x069c 
%token FORMAT_STMT 0x069f FORTRAN 0x0703 FROMALIEN 0x0706 FREE 0x0709
%token FROM 0x070c FS 0x070f
%token G 0x0713 GENERIC 0x0716 GENKEY 0x0719 GET 0x071c GO 0x071f
%token GOTO 0x0723 GRAPHIC 0x0726 GX 0x0729
%token HANDLE 0x0733 HEXADEC 0x0736
%token I 0x1000 IEEE 0x1003 IF 0x1006 IGNORE 0x1009 IMPORTED 0x100c
%token IN 0x100f INDEXAREA 0x1013 INDEXED 0x1016 INITIAL_ 0x1019
%token INLINE 0x101c INPUT 0x101f INTER 0x1023 INTERACTIVE 0x1026 
%token INTERNAL 0x1029 INTO 0x102c INVALIDOP 0x102f IRREDUCIBLE 0x1033 ITERATE 0x1036
%token KEY 0x1039 KEYED 0x103c KEYFROM 0x103f KEYLENGTH 0x1043 KEYLOC 0x1046 KEYTO  0x1049
%token LABEL 0x1053 LEAVE 0x1056 LIKE 0x1059 LIMITED 0x105c LINE 0x105f
%token LINESIZE 0x1063 LINKAGE 0x1066 LIST 0x1069 LITTLEENDIAN 0x106c
%token LOCAL 0x106f LOCATE 0x1073 LOOP 0x1076
%token M 0x1079 MAIN 0x107c
%token NAME 0x107f NCP 0x1083
%token NOCHARGRAPHIC 0x1086 NOCHECK 0x1089 NOCONVERSION 0x108c 
%token NODESCRIPTOR 0x108f NOEXECOPS 0x1093 NOFIXEDOVERFLOW 0x1096
%token NOINIT 0x1099 NOINLINE 0x109c  NOINVALIDOP 0x109f NOLOCK 0x10a3 
%token NONE 0x10a6 NONASSIGNABLE 0x10a9 NONCONNECTED 0x10ac NONVARYING 0x10af
%token NON_QUICK 0x10b3 NO_QUICK_BLOCKS 0x10b6
%token NOOVERFLOW 0x10b9 NORMAL 0x10bc
%token NOSIZE 0x10bf NOSUBSCRIPTRANGE 0x10c3 NOSTRINGRANGE 0x10c6 
%token NOSTRINGSIZE 0x10c9 NOUNDERFLOW 0x10cc NOWRITE 0x10cf 
%token NOZERODIVIDE 0x10d3
%token OFFSET 0x10d6 ON 0x10d9 OPEN 0x10dc OPTIONAL 0x10df OPTIONS 0x10e3
%token OPTLINK 0x10e6 ORDER 0x10e9 ORDINAL 0x10ec OTHERWISE 0x10ef 
%token OUTPUT 0x10f3 OVERFLOW_  0x10f6
%token P 0x10fc PACKAGE 0x10ff PACKED 0x1103 PACKED_DECIMAL 0x1106 PAGE 0x1109
%token PAGESIZE 0x110c PARAMETER 0x110f PASSWORD 0x1113 PENDING 0x1116
%token POINTER 0x1119 PICTURE 0x111c POSITION 0x111f PRECISION 0x1123
%token PRIORITY 0x1126 PRINT 0x1129 PROCEDURE 0x112c PUT 0x112f
%token R 0x1133 RANGE 0x1136 READ 0x1139 REAL 0x113c RECORD 0x113f
%token RECSIZE 0x1143 RECURSIVE 0x1146 REDUCIBLE 0x1149 REENTRANT 0x114c
%token REFER 0x114f REGIONAL 0x1153 RELEASE 0x1156 RENAME 0x1159
%token REORDER 0x115c REUSE 0x115f REPEAT 0x1163 REPLY 0x1166 REREAD 0x1169
%token RESERVED 0x116c RESERVES 0x116f RESIGNAL 0x1173 RETCODE 0x1176 RETURN 0x1179 
%token RETURNS 0x117c REVERT 0x117f REWRITE 0x1183
%token SCALARVARYING 0x1186 SELECT 0x1189 SEPARATE_STATIC 0x118c
%token SEQUENTIAL 0x118f SET 0x1193 SIGNAL 0x1196 SIGNED 0x1199 SIS 0x119c
%token SIZE 0x119f SKIP 0x11a3
%token SNAP 0x11a6 STATIC 0x11a9 STDCALL 0x11ac STOP 0x11af STORAGE 0x11b3
%token STREAM 0x11b6 STRING 0x11b9 STRINGRANGE 0x11bc STRINGSIZE 0x11bf
%token STRINGVALUE 0x11c3 STRUCTURE 0x11c6
%token SUB 0x11c9 SUBSCRIPTRANGE 0x11cc SUPPORT 0x11cf SYSTEM 0x11d3
%token TASK 0x11d6 THEN 0x11d9 THREAD 0x11dc TITLE 0x11df TO 0x11e3
%token TOTAL 0x11e6 TP 0x11e9 TRANSIENT 0x11ec TRANSMIT 0x11ef
%token TRKOFL 0x11f3 TSTACK 0x11f6 TYPE 0x11f9
%token U 0x11fc UNALIGNED 0x11ff UNBUFFERED 0x1203 UNCONNECTED 0x1206
%token UNDEFINEDFILE 0x1209 UNDERFLOW_ 0x120c UNION 0x120f UNLOCK 0x1213
%token UNSIGNED 0x1216 UNTIL 0x1219 UPDATE 0x121c UPTHRU 0x121f
%token V 0x1223 VALIDATE 0x1226 VALUE 0x1229 VARIABLE 0x122c VARYING 0x122f 
%token VARYINGZ 0x1233 VB 0x1236 VBS 0x1239 VS 0x123c VSAM 0x123f
%token WAIT 0x1243 WHEN 0x1246 WHILE 0x1249 WIDECHAR 0x124c WINMAIN 0x124f
%token WRITE 0x1253 WX 0x1256
%token ZERODIVIDE 0x1259
%token X 0x125c XN 0x125f XU 0x1263


%left '-' '+' CONCAT
%left '*' '/'

%union 
	{int v;
	char *s;
	struct namelist* l;
	}
%type <v> dcltype expr 
%type <s> varname VARNAME exprconst includefilename STR_CONSTANT
%type <l> varnamecommalist

%{
	/* definition that are dependent on the generated types */
	
	void pp_yyerror (YYLTYPE *locp,
	         int unused,
             const char *msg);

	int pp_yylex (YYSTYPE *lvalp, YYLTYPE *llocp);

	int pl1pp_parser(struct anyTokenList *list, struct ppContextAnchor *ppret);
	
%}

%%
pl1pp: pl1ppstmtlist;
pl1ppstmtlist: 
		'%' pl1ppstmt ';'
	|	'%' varname ':' pl1ppstmt ';' { if(!ppDefineVariable($2,LIT_DCL_TYPE_LABEL,&@1)) YYERROR; }
	|	pl1ppstmtlist '%' pl1ppstmt ';'
	|	pl1ppstmtlist '%' varname ':' pl1ppstmt ';' { if(!ppDefineVariable($3,LIT_DCL_TYPE_LABEL,&@2)) YYERROR; }
	;
pl1ppstmt: /* empty */
	|	ACTIVATE varname  {if(!ppSetActivateStmt($2)) YYERROR;}
	|	DEACTIVATE varname {if(!ppSetDeactivateStmt($2)) YYERROR;}
	|	DECLARE dclstmt
	|	DO   { if(ppSetDoStmt(NULL,-1,-1,&@1)<0) YYERROR;    }	
	|	DO dostmt 
	|	END { if(ppSetEndStmt(&@1)<0) YYERROR;   }
	|   GOTO varname { ppSetGotoStmt($2,&@2); }
	|	INCLUDE includestmt
	|	varname '=' expr	{ ppSetIntValue($1,$3,&@3); }
	|	varname '=' exprconst	{ ppSetStringValue($1,$3,&@3); }
	|	REPLACE varname BY expr { if(!ppDefineVariable($2,LIT_DCL_TYPE_FIXED,&@2)) YYERROR; 
		                          ppSetIntValue($2,$4,&@4); }
	|	REPLACE varname BY exprconst { if(!ppDefineVariable($2,LIT_DCL_TYPE_CHAR,&@2)) YYERROR; 
		                               ppSetStringValue($2,$4,&@4); }
	|	PAGE
	|	PAGE '(' NUM ')'
	|	PRINT
	|	SKIP
	|	SKIP '(' NUM ')'
	|	NOPRINT
	|	NOTE '(' STR_CONSTANT ',' exprconst ')'	{ if(!ppSetNoteStmt($<s>3,$5)) YYERROR; }
	;

dclstmt: varname dcltype                 { if(!ppDefineVariable($1,$2,&@1)) YYERROR ; }
	|	'(' varnamecommalist ')' dcltype { if(!ppDefineVariableList($2,$4)) YYERROR;  }
	;
dcltype: FIXED	{ $$=LIT_DCL_TYPE_FIXED; }
	|	CHARACTER { $$=LIT_DCL_TYPE_CHAR; }
	;

dostmt: varname '=' expr TO expr { if(ppSetDoStmt($1,$3,$5,&@1)<0) YYERROR; } 
       ;

varname:
           VARNAME            { $$=$<s>1 ; }
       |       varname_kw         { $$=$<s>1 ; }
       |       varname_kwpp       { $$=$<s>1 ; }
       |       varname_conditions { $$=$<s>1 ; }
       ;
       
       

       /* Note: The varnames that are commented out, 
        *       are resolved in the scanner 
        *       and returned as token VARNAME 
        */         
varname_kw:
             A
               | ABNORMAL
               | ADDBUFF
               | ALIAS
               | ALIGNED
               | ALLOCATE
               | ASCII
               | ASSIGNABLE
               | ASSEMBLER
               | ATTACH
               | AUTOMATIC
               | B
           | B1
               | B2
               | B3
               | B4
               | BACKWARDS
               | BASED
               | BEGIN_
               | BIGENDIAN
               | BINARY
               | BIT
               | BKWD
               | BLKSIZE
               | BUFFERED
               | BUFFERS
               | BUFFOFF
               | BUFND
               | BUFNI
               | BUFSP
               | BUILTIN
               | BY
               | BYADDR
               | BYVALUE
               | BX
               | C
               | CALL
               | CELL
               | CDECL
               | CHARACTER
               | CHARGRAPHIC
               | CLOSE
               | COBOL
               | COLUMN
               | COMPLEX
               | CONNECTED
               | CONSECUTIVE
               | CONSTANT
               | CONTROLLED
               | COPY
               | CTLASA
               | CTL360
               | D
               | DATA
               | DATE
               | DB
               | DECLARE /* note should work with the preprocessor */
               | DECIMAL
               | DEFINE
               | DEFINED
       /*      | DEFAULT */
               | DELAY
               | DELETE
               | DESCRIPTOR
               | DESCRIPTORS
               | DETACH
               | DIMENSION
               | DISPLAY
               | DIRECT
               | DO
               | DOWNTHRU
               | E
               | EDIT
               | ELSE
               | END
               | ENTRY     /* note the statement variant is returned as ENTRY_STMT */
               | ENVIRONMENT
               | EVENT
               | EXCLUSIVE
               | EXPORTS
               | EXTERNAL
               | EXIT
               | F
               | FB
               | FS
               | FBS
               | FETCH
               | FETCHABLE
               | FILE_
               | FIXED
               | FLOAT
               | FLUSH
               | FOREVER
               | FORMAT    /* note the statement variant is returned as FORMAT_STMT */
               | FORTRAN
               | FREE
               | FROM
               | FROMALIEN
               | G
               | GENERIC
               | GENKEY
               | GET
               | GO
               | GOTO
               | GRAPHIC
               | GX
               | HANDLE
               | HEXADEC
               | I
               | IEEE
               | IF
               | IGNORE
               | IMPORTED
               | IN
               | INDEXAREA
               | INDEXED
               | INITIAL_
               | INLINE
               | INPUT
               | INTER
               | INTERACTIVE
               | INTERNAL
               | INTO
               | IRREDUCIBLE
               | ITERATE
               | KEYED
               | KEYLENGTH
               | KEYLOC
               | KEYTO
               | KEYFROM
               | LABEL
               | LEAVE
               | LIKE
               | LIMITED
               | LINE
               | LINESIZE
               | LINKAGE
               | LIST
               | LITTLEENDIAN
               | LOCAL
               | LOCATE
               | LOOP
               | M
               | MAIN
               | NCP
               | NOCHARGRAPHIC
               | NOCHECK
               | NOCONVERSION
               | NODESCRIPTOR
               | NOEXECOPS
               | NOFIXEDOVERFLOW
               | NOINIT
               | NOINLINE
               | NOINVALIDOP
               | NOLOCK
               | NONASSIGNABLE
               | NONCONNECTED
               | NONE
               | NONVARYING
               | NON_QUICK
               | NO_QUICK_BLOCKS
               | NOOVERFLOW
               | NORMAL
               | NOSIZE
               | NOSUBSCRIPTRANGE
               | NOSTRINGRANGE
               | NOSTRINGSIZE
               | NOUNDERFLOW
               | NOWRITE
               | NOZERODIVIDE
               | OFFSET
               | ON
               | OPEN
               | OPTIONAL
               | OPTIONS
               | OPTLINK
               | ORDER
               | ORDINAL
       /*      | OTHERWISE */
               | OUTPUT
               | P
               | PACKAGE
               | PACKED
               | PACKED_DECIMAL
               | PAGE
               | PAGESIZE
               | PARAMETER
               | PASSWORD
               | PICTURE
               | POINTER
               | POSITION
               | PRECISION
               | PRINT
               | PRIORITY
       /*      | PROCEDURE */
               | PUT
               | R
               | RANGE
               | REAL
               | READ
               | RECSIZE
               | RECURSIVE
               | REENTRANT
               | REDUCIBLE
               | REFER
               | REGIONAL
               | RELEASE
               | RENAME
               | REORDER
               | REPEAT
               | REPLY
               | REREAD
               | RESERVED
               | RESERVES
               | RESIGNAL
               | RETCODE
               | RETURN
               | RETURNS
               | REUSE
               | REVERT
               | REWRITE
               | SCALARVARYING
               | SELECT
               | SEPARATE_STATIC
               | SEQUENTIAL
               | SET
               | SIGNAL
               | SIGNED
               | SIS
               | SKIP
       /*      | SNAP */
               | STATIC
               | STDCALL
               | STOP
               | STREAM
               | STRING
               | STRINGVALUE
               | STRUCTURE
               | SUB
               | SUPPORT
               | SYSTEM
               | TASK
               | THEN
               | THREAD
               | TITLE
               | TO
               | TOTAL
               | TP
               | TRANSIENT
               | TRKOFL
               | TSTACK
               | TYPE
               | U
               | UNALIGNED
               | UNBUFFERED
               | UNCONNECTED
               | UNDEFINEDFILE
               | UNION
               | UNLOCK
               | UNSIGNED
               | UNTIL
               | UPDATE
               | UPTHRU
               | V
               | VALIDATE
               | VALUE
               | VARIABLE
               | VARYING
               | VARYINGZ
               | VB
               | VBS
               | VS
               | VSAM
               | WAIT
               | WHEN
               | WHILE
               | WIDECHAR
               | WINMAIN
               | WRITE
               | WX
               | X
               | XN
               | XU
               ;
varname_kwpp: ACTIVATE
               | DEACTIVATE
               | INCLUDE
               | NOPRINT
               | NOTE
               | PAGE
               | REPLACE
               ;
varname_conditions:
                 ANYCONDITION
               | AREA
               | ATTENTION
               | CHECK
               | CONDITION
               | CONVERSION
               | ENDFILE
               | ENDPAGE
               | ERROR
               | FINISH
               | FIXEDOVERFLOW
               | INVALIDOP
               | KEY
               | NAME
               | OVERFLOW_
               | PENDING
               | RECORD
               | SIZE
               | STORAGE
               | STRINGRANGE
               | STRINGSIZE
               | SUBSCRIPTRANGE
               | TRANSMIT
               | UNDERFLOW_
               | ZERODIVIDE
               ;
	
varnamecommalist: varname	{ $$=ppInitList($1,&@1); }
	|	varnamecommalist ',' varname	{ $$=ppAddName($1,$3,&@3); }
	;
	
expr:	expr '+' expr	{ $$=$1 + $3 ; }
	|	expr '*' expr	{ $$=$1 * $3 ; }
	|	expr '-' expr	{ $$=$1 - $3 ; }
	|	expr '/' expr	{ $$=$1 / $3 ; }
	|	'(' expr ')'	{ $$=$2; }
	|	NUM				{ $$=atoi($<s>1); }
	|	varname			{ $$=ppGetIntValue($1,&@1) ; }
	;
	
exprconst:
		exprconst CONCAT exprconst {$$=malloc(strlen($1)+strlen($3)+1); strcpy($$,$1); strcat($$,$3); }
        |       exprconst CONCAT varname {char *tmpstr=ppGetValueAsString(ppFindDCLName($3),&@3);  $$=malloc(strlen($1)+strlen(tmpstr)+1); strcpy($$,$1); strcat($$,tmpstr); }
	|	STR_CONSTANT	{ $$ = $1 ; }
	;

includestmt:
		includefilename			{ debugParserpp("all right! its include of %s\n",$1);
			                      ppSetIncludeStmt($1,NULL,&@1); 
								}
	|	varname '(' includefilename ')'
								{ debugParserpp("all right! using environment variable %s to include of %s\n",$1,$3); 
			                      ppSetIncludeStmt($1,$3,&@3); 
								}
	;
includefilename:
		varname					{$$=$1;}
	|	varname '.' varname {$$=malloc(strlen($1)+strlen($<s>2)+strlen($3)+1);
		strcpy($$,$1); strcat($$,"."); strcat($$,$3); }
	|	STR_CONSTANT	{$$=$1;}
	;
%%

void yyerror (YYLTYPE *locp,
             int unused,
             const char *msg)
{ unused=0; // to kill warning message
  char *buf=sprintfString("Preprocessor error at %s: %s\n\n",sprintf_yylloc(locp),msg);
  fprintf(stderr, "%s", buf);
  addErrorMessage(scannerContext->ppp ,buf);

} /* yyerror */


/* ===================================== */

/* yylex should return tokens from the list of tokens */
int pp_yylex (YYSTYPE *lvalp, YYLTYPE *llocp)
{	struct savedtokenlist *temp;
	if(currentToken==NULL) return 0; /* EOF */
	temp=currentToken;
	currentToken=currentToken->next;
    memcpy(llocp ,temp->locations,sizeof(YYLTYPE));
	lvalp->s = temp->string;
	return temp->token;
}

int pl1pp_parser(struct anyTokenList *list, struct ppContextAnchor *ppret)
{
	currentToken=list->head;
	
	pp_yydebug=1;
  	scannerContext=ppret;
  	
  	int unused=0;
  	
    return pp_yyparse (unused);
}

