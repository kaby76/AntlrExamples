%error-verbose
%pure-parser
%lex-param {yyscan_t scanner}
%parse-param {yyscan_t scanner}
%locations
%token-table
%{ 
	/* PL1-PARSER.Y
	 * ============ 
%expect 3
	 *
	 * PL/I parser 
	 *
	 * Copyright 2002, 2003-2005 Henrik Sorensen
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
	/* make with bison -v -d -t -g pl1.y  */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "PPDebugLog.h"
#include "TokenLocationStructs.h"
#include "parseMisc.h"
#include "parseParserStack.h"
#include "parseScopeNode.h"
#include "parseProcGroupList.h"
#include "parseProcOptionList.h"
#include "parseDclOptionList.h"
#include "parseDclStmt.h"
#include "PLIParser.h"
#include "TokenLocation.h"

extern int error(const char *msgtext); //TODO: fix error

/* prototypes */
struct ListOfNames *newListOfNames(char *);
struct ListOfNames *addName(struct ListOfNames *, char *);

char *allocFullLabelName(struct ListOfNames *l);

/* ======================= */

struct ScopeNode *currentScope;

/* ==================== */


#define SHOWSTMT(i) \
switch(i) \
{ case BEGIN_	 : debugParser("stmt is begin\n");          break; \
  case DO	 : debugParser("stmt is do\n");             break; \
  case END	 : debugParser("stmt is end\n");            break; \
  case ENTRY_STMT: debugParser("stmt is entry\n");            break; \
  case ON	 : debugParser("stmt is on\n");             break; \
  case PACKAGE	 : debugParser("stmt is package\n");        break; \
  case PROCEDURE : debugParser("stmt is proc\n");           break; \
  case SELECT    : debugParser("stmt is select\n");         break; \
  default	 : debugParser("stmt is stmt\n");           break; \
}


%}
/* keep the 0x0000 values in sync with preprocessorv2/pl1pp-parser.y */
%token ACTIVATE 0x3000 DEACTIVATE 0x3001 INCLUDE 0x3002 NOPRINT 0x3005 NOTE 0x3010 REPLACE 0x3015 


/* Currently the numbers higher than 0x3000 is reserved for the preprocessor
 * but this is an artificial limit, not a technical limit. 
 * Can easily be changed.
 */
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

%token _ASSIGN_ 0x1266 _EMPTY_ 0x1269 _ROOT_ 0x126c _STMT_ 0x126f
%token _SCANNER_ERROR_ 0x1273 _KEEP_SCANNING_ 0x1276
%token ENTRY_STMT 0x1279



/* to remove shift/reduce conflicts:*/
%nonassoc DELAY DISPLAY GET IF VARNAME PUT OTHERWISE RETURN SELECT SKIP UNTIL WAIT WHEN WHILE
%nonassoc CHECK CONVERSION FIXEDOVERFLOW OVERFLOW_ SIZE STRINGRANGE STRINGSIZE SUBSCRIPTRANGE
%nonassoc UNDERFLOW_ ZERODIVIDE NOCHECK NOCONVERSION NOFIXEDOVERFLOW NOOVERFLOW NOSIZE
%nonassoc NOSUBSCRIPTRANGE NOSTRINGRANGE NOSTRINGSIZE NOUNDERFLOW NOZERODIVIDE

%nonassoc NUM
%nonassoc PTR '.' ',' '(' ')'


%left '-' '+' OR CONCAT
%left '*' '/' AND
%nonassoc '=' '<' '>' LE GE NE
%left POWER
%nonassoc UMINUS
%nonassoc UPLUS
%right NOT

%nonassoc THEN
%nonassoc ELSE

%left REPEAT TO BY
%union  { 
  char *s;
  struct ParserStack *ps;
  int i;
  struct ListOfNames *l;
  struct ProcGroupList *pgl;
  struct ProcOptionList *pol;
  struct DclOptionList *dol;
  struct DeclareElement *dem;
  struct DeclareElementList *del;
  struct StatementElement *stmtelem;
 }

%type <l> prestmtlist
%type <i> pl1stmt stmt
%type <ps> stmtscope stmtscopeend
%type <pgl> procgrouplist entrygrouplist
%type <pol> procoptionlist
%type <dol> dcloptionlist dclfactor
%type <dem> dclnamebase
%type <del> dclterm dcltermcommalist
%type <i> dclnumericNUM
%type <l> varnamecommalist
%type <s> varname
%type <ps> beginstmt dostmt endstmt entrystmt packagestmt procedurestmt selectstmt


%start pl1pgm

%{
/* Definitions that are dependend on generated types */
//static void yyprint(FILE *, int, YYSTYPE);
//#define YYPRINT(file, type, value)   yyprint (file, type, value)

#include "yyFlex.h"
#include "PLIParserStructs.h"
#include "PLIMessage.h"

void yyerror (YYLTYPE *locp,
             yyscan_t scanner, 
             const char *msg);


int processParserStackProcedure(struct ScopeNode *current,struct ParserStack *ps, struct ListOfNames *scopeName,YYLTYPE *locp);
int defineProcedure(struct ScopeNode *current, struct ProcGroupList *pgl);

char *pl1parserGetTokenText(int token);


/* misc missing prototypes */
int addDclDeclareElementList(struct ScopeNode *current, struct DeclareElementList *elementList,yyscan_t scanner);
int addDclDeclareElement(struct DeclareElementList *elementlist, struct DeclareElement *element);
int addDclImplied(struct ScopeNode *current,char *name, int dclattrinfo);
struct DeclareElement * findDclName(struct ScopeNode *current, char * name, struct DeclareElement *structureParent);


%}


%%
pl1pgm:		{ /* scopeRoot is set in function pl1_parser*/ 
	          currentScope=((struct PLIParserParms *)yyget_extra(scanner))->scopeRoot;
	        }
		pl1stmtlist
		   { debugParser("pl1pgm: Statements ranges from lines (%i,%i) to (%i,%i), offset (%i to %i) \n"
		     , @2.first_line, @2.first_column /* TODO: use sprintf_yylloc */
		     , @2.last_line,@2.last_column
		     , @2.first_offset,@2.last_offset);

		     if(isDebugLevel(DL_PARSER)) {
 		       debugParser("Showing scope structure.\n");
		       showScopeTree(((struct PLIParserParms *)yyget_extra(scanner))->scopeRoot);
		     }
		
		     debugParser("\tNumber of statements:%i\n",$<i>2);
		     /* write infomsg */
		     addInfoMessage((struct PLIParserParms *)yyget_extra(scanner)
		     , sprintfString("Number of statements:%i in program\n",$<i>2));
		     @$=@2;
		  }
	|     { /* EMPTY */
		    addInfoMessage((struct PLIParserParms *)yyget_extra(scanner)
		    , sprintfString("Program does not contain any statements.\n"));  
		  }
	;

pl1stmtlist:
        pl1stmt ';'                { $<i>$=1; /* count stmts */ }
	|   pl1stmtlist pl1stmt ';'	   { $<i>$=$<i>1+1; /* count stmts */ }
	;

preconditioncommalist:
		precondition
	|	preconditioncommalist ',' precondition
	;

prestmtlist:	
         varnamequal                    { $$=newListOfNames($<s>1); }
	|	'(' preconditioncommalist ')'	{ $$=NULL; }
	|	prestmtlist ':' varnamequal     { if($1) $$=addName($1,$<s>3); else $$=newListOfNames($<s>3); }
	|	prestmtlist ':' '(' preconditioncommalist ')' { $$=$1; }
	;

pl1stmt:   	
        stmt
	|	prestmtlist ':' stmt { $$=$3; }
    |   stmtscope
			{ currentScope=newScope(currentScope,NULL,$1);
			}
	|	prestmtlist ':' stmtscope
			{ 
			  switch(($3)->i)
			  { 
			  	case ENTRY_STMT: 
			  	     if(processParserStackProcedure(currentScope,$3,$1,&@3)<0) YYERROR; 
			  	  break;
			  	case PROCEDURE:
			  	     currentScope=newScope(currentScope,$1,$3); 
			  	     if(processParserStackProcedure(currentScope,$3,$1,&@3)<0) YYERROR; 
			  	  break;
			  	default:
			  	currentScope=newScope(currentScope,$1,$3);
			  	 break;
			  } 
			 }
    |   stmtscopeend
			{ currentScope=endScope(currentScope,$1,((struct PLIParserParms *)yyget_extra(scanner))->scopeRoot);
			}
	|	prestmtlist ':' stmtscopeend
			{ /* TODO: what happend to the label on END statement? */
  			  currentScope=endScope(currentScope,$3,((struct PLIParserParms *)yyget_extra(scanner))->scopeRoot);
			}
	|   UNKNOWN {$$=UNKNOWN; /* this indicates an error in the scanner, or invalid input character */}
	;

stmtscopeend:
		endstmt		
	;

/* stmtscope: all statements that need an END statement or special scope handling */
stmtscope:
		beginstmt 
	|	dostmt		
	|	entrystmt
	|	packagestmt
	|	procedurestmt	
	|	selectstmt	
	;
stmt:/* empty */	{ $$=_EMPTY_ ; }
    |	allocatestmt { $$= ALLOCATE; }
	|	assignstmt	{ $$= _ASSIGN_; }
	|	attachstmt	{ $$= ATTACH; }
	|	callstmt	{ $$= CALL; }
	|	closestmt	{ $$= CLOSE; }
	|	dclstmt		{ $$= DECLARE; }
	|	defaultstmt	{ $$= DEFAULT; }
	|	definealiasstmt { $$= DEFINE; }
	|	defineordinalstmt { $$= DEFINE; }
	|	definestructurestmt { $$= DEFINE ; }
	|	delaystmt	{ $$= DELAY; }
	|	deletestmt	{ $$= DELETE; }
	|	detachstmt	{ $$= DETACH; }
	|	displaystmt	{ $$= DISPLAY; }
	|	elsestmt	{ $$= ELSE; }
	|	exitstmt	{ $$= EXIT; }
	|	fetchstmt	{ $$= FETCH; }
	|	flushstmt	{ $$= FLUSH; }
	|	formatstmt	{ $$= FORMAT; }
	|	freestmt	{ $$= FREE; }
	|	getstmt		{ $$= GET; }
	|	gotostmt	{ $$= GOTO; }
	|	ifstmt		{ $$= IF; }
	|	iteratestmt	{ $$= ITERATE; }
	|	leavestmt	{ $$= LEAVE; }
	|	locatestmt	{ $$= LOCATE; }
	|	onstmt		{ $$= ON; }
	|	openstmt	{ $$= OPEN; }
	|	otherwisestmt	{ $$= OTHERWISE; }
	|	putstmt		{ $$= PUT; }
	|	readstmt	{ $$= READ; }
	|	releasestmt	{ $$= RELEASE; }
	|	resignalstmt { $$= RESIGNAL; }
	|	returnstmt	{ $$= RETURN; }
	|	revertstmt	{ $$= REVERT; }
	|	rewritestmt	{ $$= REWRITE; }
	|	signalstmt	{ $$= SIGNAL; }
	|	stopstmt	{ $$= STOP; }
	|	waitstmt	{ $$= WAIT; }
	|	whenstmt	{ $$= WHEN; }
	|	writestmt	{ $$= WRITE; }
	|	unlockstmt	{ $$= UNLOCK; }
	;

allocatestmt:	ALLOCATE allocateoptionlist
	;
allocateoptionlist:
		allocateoption
	|	allocateoptionlist ',' allocateoption
	;
allocateoption:	
        varnameref
	|	varnameref IN  '(' varnameref ')'
	|	varnameref SET '(' varnameref ')'
	|	varnameref IN  '(' varnameref ')' SET '(' varnameref ')'
	|	varnameref SET '(' varnameref ')' IN  '(' varnameref ')'
	|	NUM varnameref
	|	varnameref ctloptionlist
	|	NUM varnameref ctloptionlist
	;

attachstmt:
		ATTACH varnameref
	|	ATTACH varnameref THREAD '(' varnameref ')'
	|	ATTACH varnameref THREAD '(' varnameref ')' ENVIRONMENT '(' ')'
	|	ATTACH varnameref THREAD '(' varnameref ')' ENVIRONMENT '(' TSTACK '(' expr ')' ')'
	|	ATTACH varnameref ENVIRONMENT '(' ')'
	|	ATTACH varnameref ENVIRONMENT '(' TSTACK '(' expr ')' ')'
	|	ATTACH varnameref ENVIRONMENT '(' ')' 	THREAD '(' varnameref ')'
	|	ATTACH varnameref ENVIRONMENT '(' TSTACK '(' expr ')' ')' 	THREAD '(' varnameref ')'
	;
	

/* dimension is part of the varnameref */
ctloptionlist:	
        ctlvarattribute
	|	ctlvarattribute dclinit
	|	dclinit
	;

ctlvarattribute:
		CHARACTER '(' expr ')'
	|	BIT  '(' expr ')'
	|	GRAPHIC '(' expr ')'
	|	AREA '(' expr ')'
	;

beginstmt:	
		BEGIN_  { $$=newStackScopeNode(BEGIN_); }
	|	BEGIN_ OPTIONS '(' beginstmtoptionlist ')'  { $$=newStackScopeNode(BEGIN_); /*setStatementOptions($$,$4);*/ }
	;

beginstmtoptionlist:
		beginstmtoption
	|	beginstmtoptionlist beginstmtoption
	|	beginstmtoptionlist ',' beginstmtoption
	;
	
beginstmtoption:
		ORDER
	|	REORDER
	|	NOCHARGRAPHIC
	|	CHARGRAPHIC
	|	NOINLINE
	|	INLINE
	|	NON_QUICK
	|	NO_QUICK_BLOCKS
	|	SUPPORT
	;

delaystmt:	DELAY '(' expr ')' ;

callstmt:	CALL calloptionlist	;
closestmt:	CLOSE closegrouplist	;

defaultstmt:	
		DEFAULT defaultitemcommalist 
	|	DEFAULT NONE
	;
definealiasstmt: DEFINE ALIAS varname dcloptionlist;
defineordinalstmt: 
		DEFINE ORDINAL varname 	'(' ordinalmembercommalist  ')'
	|	DEFINE ORDINAL varname 	'(' ordinalmembercommalist  ')' ordinaloptionlist
	;
definestructurestmt:
		DEFINE STRUCTURE dclstructurecommalist
	;
dclstructurecommalist:
		dclstructure
	|	dclstructurecommalist ',' dclstructure
	;
	
dclstructure: 	
		NUM varname
	|	NUM varname CELL
	|	NUM varname UNION
	|	NUM varname dclfactor
	|	NUM '*'
	|	NUM '*' CELL
	|	NUM '*' UNION
	|	NUM '*' dclfactor
	;

ordinalmembercommalist: 
		ordinalmember
	|	ordinalmembercommalist ',' ordinalmember
	;
ordinalmember:	
		varname
	|	varname VALUE '(' NUM ')'
	;
ordinaloptionlist:
		ordinaloption
	|	ordinaloptionlist ordinaloption
	;
ordinaloption:
		PRECISION '(' NUM ')'
	|	SIGNED
	|	UNSIGNED
	;

displaystmt:
        DISPLAY '(' expr ')'
	|	DISPLAY '(' expr ')' REPLY '(' varnameref ')'
	|	DISPLAY '(' expr ')' REPLY '(' varnameref ')' EVENT '(' varnameref ')'
	|	DISPLAY '(' expr ')' EVENT '(' varnameref ')' REPLY '(' varnameref ')'
	;

deletestmt:	DELETE deleteoptionlist	;
detachstmt: DETACH THREAD '(' varnameref ')'
	;
elsestmt:	ELSE pl1stmt
	;
endstmt:	
        END { $$=newParserStack(END);}
	|	END varname 
	          { debugParser("END>%s<\n",$<s>2);
		        $$=newParserStack(END); $$->l=newListOfNames($<s>2);
              }
	;

entrystmt:
        ENTRY_STMT entrygrouplist { $<ps>$=newParserStack(ENTRY_STMT); ($<ps>$)->pgl=$2; }
	|	ENTRY_STMT { $<ps>$=newParserStack(ENTRY_STMT) }
	;
exitstmt:	EXIT 			;

fetchstmt:	FETCH fetchoptioncommalist ;

fetchoptioncommalist:
		fetchoption
	|	fetchoptioncommalist ',' fetchoption
	;
fetchoption:
		varnameref
	|	varnameref SET   '(' varnameref ')'
	|	varnameref TITLE '(' expr ')'
	|	varnameref SET   '(' varnameref ')' TITLE '(' expr ')'
	|	varnameref TITLE '(' expr ')' SET   '(' varnameref ')'
	;
flushstmt:	FLUSH FILE_ '(' varnameref ')'
	|		FLUSH FILE_ '(' '*' ')'
	;
formatstmt:	FORMAT_STMT formatgrouplist
	;
freestmt:	FREE freeoption;

freeoption:	
        varnameref
	|	varnameref IN '(' varnameref ')'
	|	freeoption ',' varnameref
	|	freeoption ',' varnameref IN '(' varnameref ')'
	;

getstmt:
        GET getoptionlist
	|	GET '(' varnamedimensioncommalist ')' /* check that varnamedimensioncommalist doesnt contain '*' */
	|	GET '(' varnamedimensioncommalist ')' getoptionlist
	;

gotostmt:
        GO TO varnameref { debugParser("GOTO>%s<\n",$<s>3);}
	|	GOTO varnameref  { debugParser("GOTO>%s<\n",$<s>2);}
	;
iteratestmt:
		ITERATE
	|	ITERATE varnameref
	;
leavestmt:
        LEAVE
	|	LEAVE varnameref { debugParser("LEAVE>%s<\n",$<s>2);}
	;
locatestmt:	LOCATE varnameref locateoptionlist	;

onstmt:
		ON onconditioncommalist SYSTEM
	|	ON onconditioncommalist SNAP SYSTEM
	|	ON onconditioncommalist SNAP pl1stmt
	|	ON onconditioncommalist pl1stmt
	;

openstmt:	OPEN opengrouplist	;

packagestmt: 
		PACKAGE    { $$=newStackScopeNode(PACKAGE); }
	|	PACKAGE packagegrouplist { $$=newStackScopeNode(PACKAGE); } 
	;
	
packagegrouplist:
		packagegroup
	|	packagegrouplist packagegroup
	;
packagegroup:
		EXPORTS '(' '*' ')'
	|	EXPORTS '(' packagevarnamecommalist ')'
	|	RESERVES '(' '*' ')'
	|	RESERVES '(' varnamecommalist ')'
	|	OPTIONS '(' ')'
	|	OPTIONS '(' packageoptionlist ')'
	;
packagevarnamecommalist:
		packagevarname
	|	packagevarnamecommalist ',' packagevarname
	;
packagevarname:
		varname
	|	varname EXTERNAL '(' STR_CONSTANT ')'
	;
packageoptionlist:
		packageoption
	|	packageoptionlist packageoption
	|	packageoptionlist ',' packageoption
	;
packageoption: 
		NOCHARGRAPHIC
	|	CHARGRAPHIC
	|	ORDER
	|	REORDER
	|	REENTRANT
	;
putstmt:
		PUT putoptionlist
	|	PUT '(' varnamedimensioncommalist ')' /* check that varnamedimensioncommalist doesnt contain '*' */
	|	PUT '(' varnamedimensioncommalist ')'  putoptionlist
	;
procedurestmt:
        PROCEDURE procgrouplist	{ $<ps>$=newParserStack(PROCEDURE); ($<ps>$)->pgl=$2; }
	|	PROCEDURE { $<ps>$=newParserStack(PROCEDURE); }
	;
	
readstmt:	READ readoptionlist	;
releasestmt:	
		RELEASE varnamecommalist
	|	RELEASE '*'
	;
resignalstmt:	RESIGNAL ;
returnstmt:	RETURN
	|	RETURN '(' expr ')'
	;
rewritestmt:	REWRITE rewriteoptionlist;

revertstmt:	REVERT onconditioncommalist	;

signalstmt:	SIGNAL oncondition	;
stopstmt:	STOP			;

unlockstmt:	UNLOCK unlockoptionlist	;

waitstmt:
        WAIT '(' varnamedimensioncommalist ')' /* varnamedimensioncommalist has to be varnameref's */
	|	WAIT '(' varnamedimensioncommalist ')' '(' expr ')'
	|	WAIT THREAD '(' varnameref ')'
	;
writestmt:	WRITE writeoptionlist	;

readoptionlist:
        readoption
	|	readoptionlist readoption
	;

rewriteoptionlist:
		rewriteoption
	|	rewriteoptionlist rewriteoption
	;

selectstmt:
        SELECT { $$=newStackScopeNode(SELECT); }
	|	SELECT '(' expr ')' { $$=newStackScopeNode(SELECT); }
	;

whenstmt:	WHEN '(' varnamedimensioncommalist ')' pl1stmt /* TODO: varnamedimensioncommalist has to be expr */
	;

otherwisestmt:	OTHERWISE pl1stmt
	;

writeoptionlist:
		writeoption
	|	writeoptionlist writeoption
	;
deleteoptionlist:
		deleteoption
	|	deleteoptionlist deleteoption
	;
unlockoptionlist:
		unlockoption
	|	unlockoptionlist unlockoption
	;
locateoptionlist:
		locateoption
	|	locateoptionlist locateoption
	;

calloptionlist:	
		varnameref
	|	varnameref callmultitaskoptionlist
	;

callmultitaskoptionlist:
		callmultitaskoption
	|	callmultitaskoptionlist callmultitaskoption
	;
callmultitaskoption:
		TASK
	|	TASK '(' varnameref ')'
	|	EVENT '(' varnameref ')'
	|	PRIORITY '(' varnameref ')'
	;
closegrouplist:	closegroup
	|	closegrouplist ',' closegroup
	;

defaultitemcommalist:
		defaultitem
	|	defaultitemcommalist ',' defaultitem
	;
	
defaultitem:
		defaultpredicateexpr
	|	defaultpredicateexpr dcloptionlist
	|	defaultpredicateexpr dcloptionlist VALUE '(' dcloptionlist ')'
	|	'(' defaultitemcommalist ')'
	|	'(' defaultitemcommalist ')' dcloptionlist
	|	'(' defaultitemcommalist ')' dcloptionlist  VALUE '(' dcloptionlist ')'
	|	'(' defaultitemcommalist ')' ERROR
	;

defaultrangespec:
		varname
	|	varname ':' varname
	|	defaultrangespec ',' varname
	|	defaultrangespec ',' varname ':' varname
	;


defaultpredicateexpr: 
		defaultpredicateexpr AND defaultpredicateexpr
	|	defaultpredicateexpr OR  defaultpredicateexpr
	|	NOT defaultpredicateexpr %prec NOT
	|	'(' defaultpredicateexpr ')' 
	|	RANGE '(' '*' ')'
	|	RANGE '(' defaultrangespec ')'
	|	DESCRIPTORS
 	|	{$<dol>$=newDclOptionList();} dcloption { free($<dol>1); $<dol>$=NULL; } 
	;

procgrouplist:
        { $<pgl>$=newProcGroupList(); } procgroup { $$=$<pgl>1; }
	|	procgrouplist procgroup { $$=$1; }
	;
entrygrouplist:
        { $<pgl>$=newProcGroupList(); } entrygroup { $$=$<pgl>1; }
	|	entrygrouplist entrygroup { $$=$1; }
	;
formatgrouplist:
		'(' editformatlist ')'
	;

iooption:
        FILE_ '(' varnameref ')'
	|	EVENT '(' varnameref ')'
	;

readoption:
        INTO   '(' varnameref ')'
	|	SET    '(' varnameref ')'
	|	IGNORE '(' expr ')'
	|	KEY    '(' expr ')'
	|	KEYTO  '(' varnameref ')'
	|	NOLOCK
	|	iooption
	;

writeoption:
        FROM    '(' varnameref ')'
	|	KEYFROM '(' expr ')'
	|	KEYTO   '(' varnameref ')'
	|	iooption
	;

rewriteoption:
        FROM    '(' varnameref ')'
	|	KEY '(' expr ')'
	|	iooption
	;

deleteoption:
        KEY '(' expr ')'
	|	iooption
	;

unlockoption:
        FILE_ '(' varnameref ')'
	|	KEY   '(' expr ')'
	;

locateoption:
        FILE_ '(' varnameref ')'
	|	SET   '(' varnameref ')'
	|	KEYFROM '(' expr ')'
	;

opengrouplist:
        opengroup
	|	opengrouplist ',' opengroup
	;

opengroup:
        FILE_ '(' varnameref ')' openoptionlist
	|	FILE_ '(' varnameref ')'
	;

openoptionlist:
        openoption
	|	openoptionlist openoption
	;

openoption:
        STREAM
	|	RECORD
	|	INPUT
	|	OUTPUT
	|	UPDATE
	|	DIRECT
	|	SEQUENTIAL
	|	TRANSIENT
	|	BUFFERED
	|	UNBUFFERED
	|	BACKWARDS
	|	EXCLUSIVE
	|	KEYED
	|	PRINT
	|	TITLE '(' expr ')'
	|	LINESIZE '(' expr ')'
	|	PAGESIZE '(' expr ')'
	|	ENVIRONMENT '(' environmentspeclist ')'
	;

closegroup:
        FILE_ '(' varnameref ')' ENVIRONMENT '(' LEAVE ')'
	|	FILE_ '(' varnameref ')' ENVIRONMENT '(' REREAD ')'
	|	FILE_ '(' varnameref ')'
	;


putoptionlist:
        putoption
	|	putoptionlist putoption
	;

putoption:
        FILE_ '(' varnameref ')'
	|	PAGE
	|	SKIP
	|	SKIP '(' expr ')'
	|	LINE '(' expr ')'
	|	STRING '(' varnameref ')'
	|	dataspecification
	;

entrygroup:
        '(' varnamecommalist ')' { if(setProcGroupListParameterNameList($<pgl>0,$2)<0) {yyerror(&@1,scanner,"setting parameterlist"); YYERROR;}}
	|	RETURNS '(' entryparmcommalist ')' 
	                             {/* TODO: only ok when a structure is commalist entryparmcommalist is for now a struct DclOptionList
	                               */
	                             	
	                               if(setProcGroupListReturnsList($<pgl>0,$<dol>3)<0) {yyerror(&@1,scanner,"setting RETURNS list"); YYERROR;}
	                             }
	|	REDUCIBLE { if(setTristateAttribute(&($<pgl>0)->reducible,1)<0) {yyerror(&@1,scanner,"setting REDUCIBLE"); YYERROR;}}
	|	IRREDUCIBLE { if(setTristateAttribute(&($<pgl>0)->reducible,0)<0) {yyerror(&@1,scanner,"setting IRREDUCIBLE"); YYERROR;}}
	|	OPTIONS '(' procoptionlist ')' { if(setProcGroupListOptionList($<pgl>0,$3)<0) {yyerror(&@1,scanner,"setting OPTIONS list"); YYERROR;}}
	|	'(' ')' { if(setProcGroupListParameterNameList($<pgl>0,NULL)<0) {yyerror(&@1,scanner,"setting empty parameterlist"); YYERROR;}}
	;

procgroup:
        '(' varnamecommalist ')'	{ if(setProcGroupListParameterNameList($<pgl>0,$2)<0) {yyerror(&@1,scanner,"setting parameterlist"); YYERROR;}}
	|	RETURNS '(' entryparmcommalist ')'	
	                             {/* TODO: only ok when a structure is commalist entryparmcommalist is for now a struct DclOptionList
	                               */
	                             	
	                               if(setProcGroupListReturnsList($<pgl>0,$<dol>3)<0) {yyerror(&@1,scanner,"setting RETURNS list"); YYERROR;}
	                             }
	|	OPTIONS '(' procoptionlist ')' { if(setProcGroupListOptionList($<pgl>0,$3)<0) {yyerror(&@1,scanner,"setting OPTIONS list"); YYERROR;}}
	|	REDUCIBLE 	{ if(setTristateAttribute(&($<pgl>0)->reducible,1)<0) {yyerror(&@1,scanner,"setting REDUCIBLE"); YYERROR;}}
	|	IRREDUCIBLE	{ if(setTristateAttribute(&($<pgl>0)->reducible,0)<0) {yyerror(&@1,scanner,"setting IRREDUCIBLE"); YYERROR;}}
	|	RECURSIVE	{ if(setTristateAttribute(&($<pgl>0)->recursive,1)<0) {yyerror(&@1,scanner,"setting RECURSIVE"); YYERROR;}}
	|	ORDER		{ if(setTristateAttribute(&($<pgl>0)->order,1)<0) {yyerror(&@1,scanner,"setting ORDER"); YYERROR;}}
	|	REORDER		{ if(setTristateAttribute(&($<pgl>0)->order,0)<0) {yyerror(&@1,scanner,"setting REORDER"); YYERROR;}}
	|	CHARGRAPHIC	{ if(setTristateAttribute(&($<pgl>0)->chargraphic,1)<0) {yyerror(&@1,scanner,"setting CHARGRAPHIC"); YYERROR;}}
	|	NOCHARGRAPHIC	{ if(setTristateAttribute(&($<pgl>0)->chargraphic,0)<0) {yyerror(&@1,scanner,"setting NOCHARGRAPHIC"); YYERROR;}}
	|	'(' ')'		{ if(setProcGroupListParameterNameList($<pgl>0,NULL)<0) {yyerror(&@1,scanner,"setting empty parameterlist"); YYERROR;}}
	;

procoptionlist:
        { $<pol>$=newProcOptionList(); } procoption {$$=$<pol>1;}
	|	procoptionlist procoption {$$=$1;}
	|	procoptionlist ',' {$$=$1;} procoption {$$=$<pol>3;}
	;

procoption:
        MAIN { if(setTristateAttribute(&($<pol>0)->main,1)<0) {yyerror(&@1,scanner,"setting MAIN"); YYERROR;}
               if(currentScope->parent!=NULL) {yyerror(&@1,scanner,"MAIN invalid"); YYERROR;}
        }
	|	REENTRANT
	|	NOEXECOPS
	|	TASK { if(setTristateAttribute(&($<pol>0)->task,1)<0) {yyerror(&@1,scanner,"setting TASK"); YYERROR;}}
	|	VARIABLE
	|	NON_QUICK
	|	NO_QUICK_BLOCKS
	|	PACKED_DECIMAL
	|	SEPARATE_STATIC
	|	SUPPORT
	|	RENAME '(' renamepaircommalist ')'
	|	VALIDATE
	|	VALIDATE '(' varname ')'
	;

renamepaircommalist:
		renamepair
	|	renamepaircommalist ',' renamepair
	;
	
renamepair: '(' varname ',' varname ')'
	;

getoptionlist:
        getoption
	|	getoptionlist getoption
	;


getoption:
        FILE_ '(' varnameref ')'
	|	COPY  '(' varnameref ')'
	|	PAGE
	|	SKIP
	|	SKIP   '(' expr ')'
	|	STRING '(' expr ')'
	|	dataspecification
	;

dataspecification:
		LIST listdataspec
	|	DATA datadataspec
	|	DATA
	|	EDIT editdataspec
	;
listdataspec:	'(' datalist ')'
	;
datadataspec:	'(' datalist ')'
	;
editdataspec:	'(' datalist ')' '(' editformatlist ')'
	|	editdataspec '(' datalist ')' '(' editformatlist ')'
	;
editformatexpr:
        A
	|	A '(' expr ')'
	|	B
	|	B '(' expr ')'
	|	C '(' realformatexpr ')'
	|	C '(' realformatexpr ',' realformatexpr ')'
	|	realformatexpr
	|	G
	|	G '(' expr ')'
	|	P STR_CONSTANT
	|	R '(' varnameref ')'
	|	X '(' expr ')'
	|	LINE '(' expr ')'
	|	COLUMN '(' expr ')'
	|	PAGE
	|	SKIP
	|	SKIP '(' expr ')'
	;

realformatexpr:	
		E '(' expr ')'
	|	E '(' expr ',' expr ')'
	|	E '(' expr ',' expr ',' expr ')'
	|	F '(' expr ')'
	|	F '(' expr ',' expr ')'
	|	F '(' expr ',' expr ',' expr ')'
	;


editformatitem:	
        editformatexpr
	|	NUM editformatexpr
	|	'(' NUM ')' editformatexpr
	;

editformatlist:
        editformatitem
	|	NUM '(' editformatlist ')'
	|	'(' NUM ')' '(' editformatlist ')'
	|	editformatlist ',' editformatitem
	|	editformatlist ',' NUM '(' editformatlist ')'
	|	editformatlist ',' '(' NUM ')' '(' editformatlist ')'
	;

datalist:
        expr
	|	'(' datalist do_type_3 ')'
	|	datalist ',' expr
	|	datalist ',' '(' datalist do_type_3 ')'
	;

dostmt:	do_type_1 { $$=newStackScopeNode(DO); }
	|	do_type_2 { $$=newStackScopeNode(DO); }
	|	do_type_3 { $$=newStackScopeNode(DO); }
	;

do_type_1:	DO ;
do_type_2:	DO do_spec_2 ;

do_spec_2:	WHILE '(' expr ')'
	|	WHILE '(' expr ')' UNTIL '(' expr ')'
	|	UNTIL '(' expr ')'
	|	UNTIL '(' expr ')' WHILE '(' expr ')'
	|	LOOP
	|	FOREVER
	;

do_type_3:	DO varnameref '=' do_spec_3list
	;

do_spec_3list:
        do_spec_3
	|	do_spec_3 do_spec_2
	|	do_spec_3list ',' do_spec_3
	|	do_spec_3list ',' do_spec_3 do_spec_2
	;

do_spec_3:
		expr
	|	expr do_spec_3_exprlist
	;

do_spec_3_exprlist:
		do_spec_3_expr
	|	do_spec_3_exprlist do_spec_3_expr
	;

do_spec_3_expr:
		TO expr
	|	BY expr
	|	REPEAT expr
	|	UPTHRU expr
	|	DOWNTHRU expr
	;


ifstmt: 	ifprestmt THEN pl1stmt
	;
ifprestmt: 	
        IF expr
	|	IF '(' expr ')' '=' expr 
	;

assignstmt:
        varnamerefcommalist '=' expr
	|	varnamerefcommalist '=' expr ',' BY NAME
	|	IF '(' expr ')' '=' expr
	|	IF '(' expr ')' '=' expr ',' BY NAME
	;

assignstmt:
        varnamerefcommalist SELFOP expr
	|	varnamerefcommalist SELFOP expr ',' BY NAME
	|	IF '(' expr ')' SELFOP expr
	|	IF '(' expr ')' SELFOP expr ',' BY NAME
	;

expr:	exprbase
	|	exprnested
	;
exprnested: 
		'(' expr ')'
	|	'(' expr ')' exprstrconst /* repetition factor: expr can only be NUM */
	;
exprbase:
		expr '+' expr
	|	expr '-' expr
	|	expr '*' expr
	|	expr '/' expr
	|	expr AND expr
	|	expr OR  expr
	|	expr CONCAT expr
	|	expr POWER  expr
	|	expr '=' expr
	|	expr '<' expr
	|	expr '>' expr
	|	expr LE  expr
	|	expr GE  expr
	|	expr NE  expr
	|	varnameref
	|	exprconst
	|	'-' expr %prec UMINUS
	|	'+' expr %prec UPLUS
	|	NOT expr
	;
	
exprconst:
        exprnumconst
	|	exprstrconst
	;

exprstrconst:
        STR_CONSTANT
	|	STR_CONSTANT B
    |   STR_CONSTANT B1
	|	STR_CONSTANT B2
	|	STR_CONSTANT B3
	|	STR_CONSTANT B4
	|	STR_CONSTANT BX
	|	STR_CONSTANT G
	|	STR_CONSTANT GX
	|	STR_CONSTANT M
	|	STR_CONSTANT WX
	|	STR_CONSTANT X
	|	STR_CONSTANT XN
	|	STR_CONSTANT XU
	;

exprnumconst:	
		NUM
	|	NUM I
	|	NUMFLOAT
	|	NUMFLOAT I
	;

exprnumconst:	
		NUM B
	|	NUM B I
    |   NUM B1
    |   NUM B1 I
	| 	NUM B2
	|	NUM B2 I
	| 	NUM B3
	|	NUM B3 I
	| 	NUM B4
	|	NUM B4 I
	|	NUMFLOAT B
	|	NUMFLOAT B I
    |   NUMFLOAT B1
    |   NUMFLOAT B1 I
	|	NUMFLOAT B2
	|	NUMFLOAT B2 I
	|	NUMFLOAT B3
	|	NUMFLOAT B3 I
	|	NUMFLOAT B4
	|	NUMFLOAT B4 I
	;

varnamerefcommalist:
		varnameref
	|	varnamerefcommalist ',' varnameref
	;


varnameref:
        varnamequal
	|	varnameref '.' varnamequal
	|	varnameref PTR varnamequal
	|	varnameref HANDLEPTR varnamequal
	;

/* note: the '(' varnamedimensioncommalist ')' following varname, can be either indexes to array or parameter list for procedure */
varnamequal:	
		varname
	|	varname '(' varnamedimensioncommalist ')'
	|	varname '(' varnamedimensioncommalist ')' '(' varnamedimensioncommalist ')'
	|	varname '(' ')'
	|	varname '(' varnamedimensioncommalist ')' '(' ')' 
	;


/* Factoring out keywords  */
varnamequal:
        DELAY '(' '*'  ',' varnamedimensioncommalist ')'
	|	DELAY '(' '*'  ')'
	|	DELAY '(' expr ',' varnamedimensioncommalist ')'
	|	DELAY '(' expr ')'
	|	DISPLAY '(' '*' ',' varnamedimensioncommalist ')'
	|	DISPLAY '(' '*' ')'
	|	DISPLAY '(' expr ',' varnamedimensioncommalist ')'
	|	DISPLAY '(' expr  ')'
	|	GET '(' varnamedimensioncommalist ')'
	|	IF '(' '*'  ',' varnamedimensioncommalist ')'
	|	IF '(' '*'  ')'
	|	IF '(' expr ',' varnamedimensioncommalist ')'
	|	IF '(' expr ')' 
	|	PUT '(' varnamedimensioncommalist ')'
/*	|	OTHERWISE '(' varnamedimensioncommalist ')' */
	|	RETURN '(' '*'  ',' varnamedimensioncommalist ')'
	|	RETURN '(' '*'  ')'
	|	RETURN '(' expr ',' varnamedimensioncommalist ')'
	|	RETURN '(' expr ')'
	|	SELECT '(' '*'  ',' varnamedimensioncommalist ')'
	|	SELECT '(' '*'  ')'
	|	SELECT '(' expr ',' varnamedimensioncommalist ')'
	|	SELECT '(' expr ')'
	|	UNTIL '(' '*'  ')'
	|	UNTIL '(' '*'  ',' varnamedimensioncommalist ')'
	|	UNTIL '(' expr ',' varnamedimensioncommalist ')'
	|	UNTIL '(' expr ')'
	|	WHEN '(' varnamedimensioncommalist ')'
	|	WAIT '(' varnamedimensioncommalist ')'
	|	WHILE '(' '*'  ')'
	|	WHILE '(' '*'  ',' varnamedimensioncommalist ')'
	|	WHILE '(' expr ',' varnamedimensioncommalist ')'
	|	WHILE '(' expr ')'
	;

varnamedimensioncommalist:
		varnamedimension
	|	varnamedimensioncommalist ',' varnamedimension
	|	varnamedimensioncommalist ':' varnamedimension
	;

varnamedimension:
		expr
	|	'*'
	|	NUM SUB
	;

varnamecommalist:
		varname                       { $$=newListOfNames($1); }
	|	varnamecommalist ',' varname  { $$=addName($1,$3); }
	;


varname:
        VARNAME            { $$=$<s>1 ; }
	|	varname_kw         { $$=$<s>1 ; }
        |       varname_kwpp       { $$=$<s>1 ; }
	|	varname_conditions { $$=$<s>1 ; }
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
/*	| DECLARE */
	| DECIMAL
	| DEFINE
	| DEFINED
/*	| DEFAULT */
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
/*	| OTHERWISE */
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
/*	| PROCEDURE */
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
/*	| SNAP */
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
onconditioncommalist:
		oncondition
	|	onconditioncommalist ',' oncondition
	;
	
oncondition:
		AREA
	|	ATTENTION
	|	ANYCONDITION
	|	CHECK
	|	CHECK '(' varnamerefcommalist ')'
	|	CONDITION '(' varnameref ')'
	|	CONVERSION
	|	ENDFILE '(' varnameref ')'
	|	ENDPAGE '(' varnameref ')'
	|	ERROR
	|	FINISH
	|	FIXEDOVERFLOW
	|	INVALIDOP
	|	KEY '(' varnameref ')'
	|	NAME '(' varnameref ')'
	|	OVERFLOW_
	|	PENDING '(' varnameref ')'
	|	RECORD '(' varnameref ')'
	|	SIZE
	|	STORAGE
	|	STRINGRANGE
	|	STRINGSIZE
	|	SUBSCRIPTRANGE
	|	TRANSMIT '(' varnameref ')'
	|	UNDEFINEDFILE '(' varnameref ')'
	|	UNDERFLOW_
	|	ZERODIVIDE
	|	VARNAME
	|	varname_kw
	;

precondition:
        CHECK
	|	CHECK '(' varnamerefcommalist ')'
	|	CONVERSION
	|	FIXEDOVERFLOW
	|	INVALIDOP
	|	OVERFLOW_
	|	SIZE
	|	STRINGRANGE
	|	STRINGSIZE
	|	SUBSCRIPTRANGE
	|	UNDERFLOW_
	|	ZERODIVIDE
	|	NOCHECK
	|	NOCONVERSION
	|	NOFIXEDOVERFLOW
	|	NOINVALIDOP
	|	NOOVERFLOW
	|	NOSIZE
	|	NOSUBSCRIPTRANGE
	|	NOSTRINGRANGE
	|	NOSTRINGSIZE
	|	NOUNDERFLOW
	|	NOZERODIVIDE
	;

dclstmt:
        DECLARE dcltermcommalist    { if(checkStructureLevels($2,(struct PLIParserParms *)yyget_extra(scanner))<0){yyerror(&@2,scanner,"checking structure level"); YYERROR;}
        	                          if(addDclDeclareElementList(currentScope,$2,scanner)<0){yyerror(&@2,scanner,"add declared names to current scope"); YYERROR;}
                                    }
	|	DECLARE
	;

dcltermcommalist:
        dclterm                          { $$=$1;if(!$$){yyerror(&@1,scanner,"assigning list"); YYERROR;}}
    |   dclnamebase                      { $$=newDeclareElementList($1); if(!$$) {yyerror(&@1,scanner,"initialising list with dclnamebase"); YYERROR;}}
	|	dcltermcommalist ',' dclterm     { $$=addElementList2List($1,$3); if(!$$){yyerror(&@3,scanner,"adding declare list to list"); YYERROR;}}
	|	dcltermcommalist ',' dclnamebase { $$=addElement2List($1,$3); if(!$$){yyerror(&@3,scanner,"adding declare element to list"); YYERROR;}}
	;

dclterm:
		'(' dcltermcommalist ')' {$$=$2;}
	|	'(' dcltermcommalist ')' dclfactor  { if(mergeDeclareElements($2,$4,-1,-1,scanner)<0) 
		                                      { yyerror(&@4,scanner,"merging declare element"); 
		                                      	YYERROR;
		                                      }
		                                      $$=$2;
		                                    }
	|	NUM '(' dcltermcommalist ')'  { if(mergeDeclareElements($3,NULL,atoi($<s>1),-1,scanner)<0) 
		                                { yyerror(&@4,scanner,"merging structure level"); 
		                                  YYERROR;
		                                }
		                                $$=$3;
		                              }
	|	NUM '(' dcltermcommalist ')' dclfactor { if(mergeDeclareElements($3,$5,atoi($<s>1),-1,scanner)<0) 
		                                         { yyerror(&@5,scanner,"merging declare element with structure level"); 
		                                           YYERROR;
		                                         }
	                                             $$=$3; } 
	|	NUM '(' dcltermcommalist ')' CELL  {$$=$3; /* is this valid?*/}
	|	NUM '(' dcltermcommalist ')' UNION {$$=$3; /* is this valid?*/}
	;

dclnamebase:
       varname			 { $$=setNewDeclareElement($1,NULL,-1,-1,&@1); if(!$$) {yyerror(&@1,scanner,"adding declare element"); YYERROR;}}
    |  varname dclfactor { $$=setNewDeclareElement($1,$2,-1,-1,&@1); if(!$$) {yyerror(&@1,scanner,"adding declare element with dclfactor"); YYERROR;}}
    |   NUM varname      { $$=setNewDeclareElement($2,NULL,atoi($<s>1),-1,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element with structure level"); YYERROR;}}
    |   NUM varname dclfactor { $$=setNewDeclareElement($2,$3,atoi($<s>1),-1,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element with structure level"); YYERROR;}}
    |   NUM varname CELL { $$=setNewDeclareElement($2,NULL,atoi($<s>1),CELL,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element with structure level and CELL"); YYERROR;}}
    |   NUM varname UNION { $$=setNewDeclareElement($2,NULL,atoi($<s>1),UNION,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element with structure level and UNION"); YYERROR;}}
    |   NUM '*'           { $$=setNewDeclareElement($<s>2,NULL,atoi($<s>1),-1,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element '*' with structure level"); YYERROR;}}
    |   NUM '*' dclfactor { $$=setNewDeclareElement($<s>2,$3,atoi($<s>1),-1,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element '*' with structure level"); YYERROR;}}
    |   NUM '*' CELL      { $$=setNewDeclareElement($<s>2,NULL,atoi($<s>1),CELL,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element '*' with structure level and CELL"); YYERROR;}}
    |   NUM '*' UNION     { $$=setNewDeclareElement($<s>2,NULL,atoi($<s>1),UNION,&@2); if(!$$) {yyerror(&@1,scanner,"adding declare element '*' with structure level and UNION"); YYERROR;}}
	;
	
dclfactor:
		'(' dclarrayboundcommalist ')'               { $<dol>$=NULL; }
	|	'(' dclarrayboundcommalist ')' dcloptionlist { showStructDclOptionList($4); $<dol>$=$4; }
	|	dcloptionlist                                { showStructDclOptionList($1); $<dol>$=$1; }
	;

dclarrayboundcommalist:
		dclarraybound
	|	dclarraybound ':' dclarraybound
	|	dclarrayboundcommalist ',' dclarraybound
	|	dclarrayboundcommalist ',' dclarraybound ':' dclarraybound
	;

dclarraybound:	
		expr
	|	expr REFER '(' varnameref ')'
	|	'*'
	;

dcloptionlist:
       {$$=newDclOptionList();} dcloption {$$=$<dol>1; }
	|	dcloptionlist dcloption
	;

dcloption:
      { if(initDclOptionNumeric($<dol>0)<0)
        { yyerror(&@0,scanner,"unexpected parsing of DECLARE statement"); YYERROR;}
        $<dol>$=$<dol>0;      
      }
         dclnumeric
	| {$<dol>$=$<dol>0; } dclio
	| { if(initDclOptionChar($<dol>0)<0)
        { yyerror(&@0,scanner,"unexpected parsing of DECLARE statement"); YYERROR;}
        $<dol>$=$<dol>0;      
      }
	     dclchar
	| {$<dol>$=$<dol>0; } dclstg
	| { if(initDclOptionPgm($<dol>0)<0)
        { yyerror(&@0,scanner,"unexpected parsing of DECLARE statement"); YYERROR;}
        $<dol>$=$<dol>0;      
      }
 	     dclpgm
	| {$<dol>$=$<dol>0; } dclmisc
	|	dclinit
	;

dclnumeric:	
		FIXED                       { if(setTristateAttribute(&($<dol>0)->dclnum->base,1)<0) {yyerror(&@1,scanner,"setting FIXED"); YYERROR;}} 
	|	FIXED '(' dclnumericNUM ')' { if(setTristateAttribute(&($<dol>0)->dclnum->base,1)<0) {yyerror(&@1,scanner,"setting FIXED"); YYERROR;}
		                              if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting fixed precision"); YYERROR;}
	                                }
	|	FIXED '(' dclnumericNUM ',' dclnumericNUM ')'
	                                { if(setTristateAttribute(&($<dol>0)->dclnum->base,1)<0) {yyerror(&@1,scanner,"setting FIXED"); YYERROR;}
		                              if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting fixed precision"); YYERROR;}
		                              if(setIntegerAttribute(&($<dol>0)->dclnum->scale,$5)<0) {yyerror(&@5,scanner,"setting fixed scale"); YYERROR;}
	                                }
	|	FLOAT                       { if(setTristateAttribute(&($<dol>0)->dclnum->base,0)<0) {yyerror(&@1,scanner,"setting FLOAT"); YYERROR;}}
	|	FLOAT '(' dclnumericNUM ')' { if(setTristateAttribute(&($<dol>0)->dclnum->base,0)<0) {yyerror(&@1,scanner,"setting FLOAT"); YYERROR;}
		                              if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting float precision"); YYERROR;}
	                                }
	|	DECIMAL                     { if(setTristateAttribute(&($<dol>0)->dclnum->type,0)<0) {yyerror(&@1,scanner,"setting DECIMAL"); YYERROR;}}
	|	DECIMAL '(' dclnumericNUM ')'
	                                { if(setTristateAttribute(&($<dol>0)->dclnum->type,0)<0) {yyerror(&@1,scanner,"setting DECIMAL"); YYERROR;}
	                                  if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting decimal precision"); YYERROR;}
	                                } 
	|	DECIMAL '(' dclnumericNUM ',' dclnumericNUM ')' 
	                                { if(setTristateAttribute(&($<dol>0)->dclnum->type,0)<0) {yyerror(&@1,scanner,"setting DECIMAL"); YYERROR;}
                                      if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting decimal precision"); YYERROR;}
		                              if(setIntegerAttribute(&($<dol>0)->dclnum->scale,$5)<0) {yyerror(&@5,scanner,"setting decimal scale"); YYERROR;}
	                                }	                                
	|	BINARY                      { if(setTristateAttribute(&($<dol>0)->dclnum->type,1)<0) {yyerror(&@1,scanner,"setting BINARY"); YYERROR;}
	                                }
	|	BINARY '(' dclnumericNUM ')' 
	                               { if(setTristateAttribute(&($<dol>0)->dclnum->type,1)<0) {yyerror(&@1,scanner,"setting BINARY"); YYERROR;}
	                                 if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting binary precision"); YYERROR;}
	                               }
	|	BINARY '(' dclnumericNUM ',' dclnumericNUM ')'
	                               { if(setTristateAttribute(&($<dol>0)->dclnum->type,1)<0) {yyerror(&@1,scanner,"setting BINARY"); YYERROR;}
	                                 if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting binary precision"); YYERROR;}
		                             if(setIntegerAttribute(&($<dol>0)->dclnum->scale,$5)<0) {yyerror(&@5,scanner,"setting binary scale"); YYERROR;}
	                               }
	|	REAL                       { if(setTristateAttribute(&($<dol>0)->dclnum->domain,0)<0) {yyerror(&@1,scanner,"setting REAL"); YYERROR;}
	                               }
	|	COMPLEX                    { if(setTristateAttribute(&($<dol>0)->dclnum->domain,1)<0) {yyerror(&@1,scanner,"setting COMPLEX"); YYERROR;}
	                               }
	|	COMPLEX '(' dclnumericNUM ')'
	                               { if(setTristateAttribute(&($<dol>0)->dclnum->domain,1)<0) {yyerror(&@1,scanner,"setting COMPLEX"); YYERROR;}
	                               	 if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting COMPLEX precision"); YYERROR;}
	                               }
	|	PRECISION /* used by defaultpredicateexpr */
	|	PRECISION '(' dclnumericNUM ')'
		                           { if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting precision"); YYERROR;}
	                               }
	|	PRECISION '(' dclnumericNUM ':' dclnumericNUM ')' /* used as range selector in genericwhenoption */
	|	PRECISION '(' dclnumericNUM ',' dclnumericNUM ')'	
		                           { if(setIntegerAttribute(&($<dol>0)->dclnum->precision,$3)<0) {yyerror(&@3,scanner,"setting precision"); YYERROR;}
		                             if(setIntegerAttribute(&($<dol>0)->dclnum->scale,$5)<0) {yyerror(&@5,scanner,"setting scale"); YYERROR;}
	                               }
	;

dclnumericNUM:
		    NUM {$$=atoi($<s>1);}
	|	'-' NUM {$$=0-atoi($<s>2);}
	|	'+' NUM {$$=atoi($<s>2);}
	;

dclio:	BACKWARDS
	|	BUFFERED
	|	DIRECT
	|	ENVIRONMENT '(' environmentspeclist ')'
	|	EXCLUSIVE
	|	FILE_
	|	INPUT
	|	KEYED
	|	LINESIZE '(' expr ')'
	|	OUTPUT
	|	PAGESIZE '(' expr ')'
	|	PRINT
	|	RECORD
	|	SEQUENTIAL
	|	STREAM
	|	TITLE '(' expr ')'
	|	TRANSIENT
	|	UNBUFFERED
	|	UPDATE
	;

dclchar:
        AREA charspec { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,0)<0) {yyerror(&@1,scanner,"setting AREA"); YYERROR;} } 
	|	BIT charspec  { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,1)<0) {yyerror(&@1,scanner,"setting BIT"); YYERROR;} }
	|	CHARACTER charspec { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,2)<0) {yyerror(&@1,scanner,"setting CHAR"); YYERROR;} }
	|	GRAPHIC charspec { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,3)<0) {yyerror(&@1,scanner,"setting GRAPHIC"); YYERROR;} }
	|	G charspec { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,3)<0) {yyerror(&@1,scanner,"setting GRAPHIC"); YYERROR;} /* short for GRAPHIC */ }
	|	PICTURE STR_CONSTANT { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,4)<0) {yyerror(&@1,scanner,"setting PICTURE"); YYERROR;} }
	|	WIDECHAR charspec { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,5)<0) {yyerror(&@1,scanner,"setting WIDECHAR"); YYERROR;} }
	|	DATE { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,6)<0) {yyerror(&@1,scanner,"setting DATE"); YYERROR;} }
	|	DATE '(' STR_CONSTANT ')' { if(setNstateAttribute(&($<dol>0)->dclchar->chartype,6)<0) {yyerror(&@1,scanner,"setting DATE"); YYERROR;} }
	;

dclstg:	ALIGNED
	|	AUTOMATIC { if(setNstateAttribute(&($<dol>0)->storageclass,0)<0) {yyerror(&@1,scanner,"setting AUTOMATIC"); YYERROR;}}
	|	BASED { if(setNstateAttribute(&($<dol>0)->storageclass,1)<0) {yyerror(&@1,scanner,"setting BASED"); YYERROR;}}
	|	BASED '(' varnameref ')' { if(setNstateAttribute(&($<dol>0)->storageclass,1)<0) {yyerror(&@1,scanner,"setting BASED"); YYERROR;}}
	|	BYADDR
	|	BYVALUE
	|	CONNECTED
	|	CONSTANT
	|	CONTROLLED { if(setBooleanAttribute(&($<dol>0)->storageclass,2)<0) {yyerror(&@1,scanner,"setting CONTROLLED"); YYERROR;}}
	|	DEFINED varnameref { if(setBooleanAttribute(&($<dol>0)->storageclass,3)<0) {yyerror(&@1,scanner,"setting DEFINED"); YYERROR;}}
	|	DEFINED '(' varnameref ')' { if(setBooleanAttribute(&($<dol>0)->storageclass,3)<0) {yyerror(&@1,scanner,"setting DEFINED"); YYERROR;}}
	|	DIMENSION '(' dclarrayboundcommalist ')'
	|	EXTERNAL { if(setTristateAttribute(&($<dol>0)->internal,1)<0) {yyerror(&@1,scanner,"setting EXTERNAL"); YYERROR;}}
	|	EXTERNAL '(' STR_CONSTANT ')' { if(setTristateAttribute(&($<dol>0)->internal,1)<0) {yyerror(&@1,scanner,"setting EXTERNAL with name"); YYERROR;}}
	|	INTERNAL { if(setTristateAttribute(&($<dol>0)->internal,0)<0) {yyerror(&@1,scanner,"setting INTERNAL"); YYERROR;}}
	|	LIKE varnameref
	|	LOCAL
	|	NONCONNECTED
	|	STATIC { if(setNstateAttribute(&($<dol>0)->storageclass,4)<0) {yyerror(&@1,scanner,"setting STATIC"); YYERROR;}}
	|	OFFSET
	|	OFFSET '(' varnameref ')'
	|	OPTIONAL
	|	PARAMETER { if(setNstateAttribute(&($<dol>0)->storageclass,5)<0) {yyerror(&@1,scanner,"setting PARAMETER"); YYERROR;}
	              }
	|	POSITION '(' expr ')'
	|	RESERVED
	|	RESERVED '(' IMPORTED ')'
	|	UNALIGNED
	|	UNCONNECTED
	|	STRUCTURE
	; 

dclpgm:	ENTRY
	|	ENTRY '(' entryparmcommalist ')'
	|	RETURNS '(' entryparmcommalist ')' /* only when a structure is commalist ok */
	|	LABEL
	|	CONDITION
	|	GENERIC '(' genericspeccommalist ')'
	|	TASK
	|	LIMITED
	|	FROMALIEN
	|	FETCHABLE
	|	CDECL
	|	OPTLINK
	|	STDCALL
	|	WINMAIN
	|	FORTRAN
	|	DESCRIPTOR
	|	NODESCRIPTOR
	|	LINKAGE '(' STR_CONSTANT ')'
	|	REDUCIBLE  { if(setTristateAttribute(&($<dol>0)->dclpgm->reducible,0)<0) {yyerror(&@1,scanner,"setting REDUCIBLE"); YYERROR;}
                   }
	|	IRREDUCIBLE { if(setTristateAttribute(&($<dol>0)->dclpgm->reducible,1)<0) {yyerror(&@1,scanner,"setting IRREDUCIBLE"); YYERROR;}
                    }
	;

dclmisc:VARIABLE
	|	VARYING
	|	NONVARYING
	|	VARYINGZ
	|	SYSTEM
	|	BUILTIN
	|	POINTER
	|	ABNORMAL
	|	NORMAL
	|	ASSIGNABLE
	|	NONASSIGNABLE
	|	HEXADEC
	|	IEEE
	|	BIGENDIAN
	|	LIST
	|	LITTLEENDIAN
	|	SIGNED
	|	UNSIGNED
	|	NOINIT
	|	HANDLE varnameref
	|	HANDLE '(' varnameref ')'
	|	TYPE varnameref
	|	TYPE '(' varnameref ')'
	|	ORDINAL varnameref
	|	OPTIONS '(' entryoptionlist ')'
	|	FORMAT
	;

environmentspeclist:
		environmentspec
	|	environmentspeclist environmentspec
	|	environmentspeclist ',' environmentspec
	;
	
environmentspec:
		F	
	|	F '(' NUM ')'
	|	FB
	|	FS
	|	FBS
	|	V
	|	VB
	|	VS
	|	VBS
	|	ADDBUFF
	|	ASCII

	|	BKWD
	|	BLKSIZE '(' environmentspecparm ')'
	|	BUFFERS '(' environmentspecparm ')'
	|	BUFFOFF '(' environmentspecparm ')'
	|	BUFND '(' environmentspecparm ')'
	|	BUFNI '(' environmentspecparm ')'
	|	BUFSP '(' environmentspecparm ')'

	|	COBOL
	|	CONSECUTIVE
	|	CTLASA
	|	CTL360

	|	D
	|	DB

	|	GENKEY

	|	INDEXAREA '(' environmentspecparm ')'
	|	INDEXED
	|	INTERACTIVE

	|	KEYLENGTH '(' environmentspecparm ')'
	|	KEYLOC '(' environmentspecparm ')'

	|	LEAVE

	|	NCP '(' environmentspecparm ')'
	|	NOWRITE

	|	RECSIZE '(' environmentspecparm ')'
	|	REGIONAL '(' environmentspecparm ')'
	|	REREAD
	|	REUSE

	|	PASSWORD

	|	SCALARVARYING
	|	SIS
	|	SKIP
	|	STRINGVALUE

	|	TOTAL
	|	TP '(' M ')'
	|	TP '(' R ')'
	|	TRKOFL

	|	U

	|	VSAM
	;
	
environmentspecparm: 
		NUM
	|	VARNAME
	;

entryparmcommalist:
		entryparm
	|	entryparmcommalist ',' entryparm
	;
entryparm:	/* empty */
	|	dcloptionlist
	|	'*'
	|	'*' dcloptionlist
	|	NUM dcloptionlist
	|	NUM
	|   '(' entryarrayspeccommalist ')' dcloptionlist
	|   NUM '(' entryarrayspeccommalist ')' dcloptionlist
	|   NUM '(' entryarrayspeccommalist ')' 
	;
	
entryarrayspec: 
	  '*'
	| NUM
	| NUM ':' NUM
	| NUM ':' '*'
	| '*' ':' NUM
	| '*' ':' '*'
	;
	
entryarrayspeccommalist:
        entryarrayspec
	|   entryarrayspeccommalist ',' entryarrayspec
	;
	
entryoptionlist:
		entryoption
	|	entryoptionlist entryoption
	|	entryoptionlist ',' entryoption
	;

entryoption:
    	ASSEMBLER
	|	COBOL
	|	FORTRAN
	|	INTER
	|	RETCODE
	|	CONSTANT
	|	VARIABLE
	|	PACKED
	|	SUPPORT
	;

genericspeccommalist:
		genericspec
	|	genericspeccommalist ',' genericspec
	;

genericspec:
	    varname WHEN '(' genericwhenoptionlist ')'
	;

genericwhenoptionlist:
		genericwhenoption
	|	genericwhenoptionlist ',' genericwhenoption
	;

genericwhenoption:
		/* EMPTY */
	|	'*'
	|	dcloptionlist
	;

charspec:	/* EMPTY */
	|	'(' '*' ')'
	|	'(' expr ')'
	|	'(' expr REFER '(' varnameref ')' ')'
	;

dclinit:
		INITIAL_ '(' inititemcommalist ')'
	|	INITIAL_ CALL varnameref
	|	INITIAL_ TO '(' initialtospec ')' '(' inititemcommalist ')'
	;
	
initialtospec: 
		VARYING
	|	VARYINGZ
	|	NONVARYING
	;


inititemcommalist:
		inititem
	|	inititemcommalist ',' inititem
	;

inititem:
		exprbase
	|	'*'
	|	inititerationfactorlist 
	|	inititerationfactorlist '*'
	|	inititerationfactorlist exprbase
	|	inititerationfactorlist '(' inititemcommalist ')' 
	;

inititerationfactorlist:
		'(' exprbase ')'
	|	inititerationfactorlist '(' exprbase ')'
	;



%%

void yyerror (YYLTYPE *locp,
             yyscan_t scanner, 
             const char *msg)
{
  char *buf=sprintfString("Error at %s: %s",sprintf_yylloc(locp),msg);
  fprintf(stderr, "%s", buf);
  if(scanner)
  addErrorMessage((struct PLIParserParms *)(yyget_extra(scanner)) ,buf);
} /* yyerror */

/*
 * Use YYPRINT in pl1-parser.y to add the value of a token:
 * The debugging information normally gives the token type of each token
 * read, but not its semantic value.  You can optionally define a macro
 * named `YYPRINT' to provide a way to print the value.  If you define
 * `YYPRINT', it should take three arguments.  The parser will pass a
 * standard I/O stream, the numeric code for the token type, and the token
 * value (from `yylval').
 */
/*
static void
  yyprint (FILE *file, int type, YYSTYPE value)
  { switch(type)
    { default:
       if (value.s) fprintf (file, "%s", value.s);
    }
  } // yyprint
*/

/*
 * Functions for label lists.
 * 
 *   newListOfNames
 *   addName
 */


/* 
 * newListOfNames 
 * -----------
 * 
 * Allocates a stuct ListOfNames, and add the name as the first entry in the list.
 * 
 * 
 * Parameter
 *   char *name: name of first label in the new label list.
 * 
 * Returns
 *   struct ListOfNames
 * 
 * 
 */
struct ListOfNames *newListOfNames(char *name)
{ struct ListOfNames *l;

  l=malloc(sizeof(struct ListOfNames));
  if (l==NULL) error("Internal compiler error: out of memory, newListOfNames");

  l->labelno=0;
  l->labellen=0;
  l->head=NULL;
  l->tail=l->head;

  return addName(l,name);
} // newListOfNames


/*
 * addName
 * --------
 * 
 * Adds a label to the end of a ListOfNames
 * 
 * 
 * Parameters
 * 
 * struct ListOfNames l: ListOfNames to extend.
 * char *name: name to add to the tail of the ListOfNames
 * 
 * 
 * Returns
 * 
 * The head of the label list is returned. 
 * Possible unchanged.
 * 
 * 
 */

struct ListOfNames *addName(struct ListOfNames *l,char *name)
{ struct NameNode * n;

  n=malloc(sizeof(struct NameNode));
  if (l==NULL) error("Internal compiler error: addName called with NULL ListOfNames");
  if (n==NULL) error("Internal compiler error: out of memory, addName");
  n->name=name;
  n->next=NULL;
  if(name) l->labellen+=strlen(name);
  if (l->head==NULL)
  { /* first label node */
    l->head=n;
    l->tail=n;
    l->labelno=1;
  }
  else
  { /* nodes are already allocated */
    /* set old tail.next to new node, and list.tail to new node */
    l->tail->next=n;
    l->tail=n;
    l->labelno++;
  }
  return l;
} // addName

/*
 * allocFullLabelName
 * ------------------
 * 
 * Allocates a string buffer with the full name of a ListOfNames, 
 * with the individual names concatenated together, only separated
 * by a ':'.
 * 
 * Parameters
 * 
 * struct ListOfNames *l: label list to allocate the full name for
 * 
 * Returns
 * 
 * string buffer with full name.
 * 
 * 
 */

/* allocates buffer and returns pointer to all labels concatenated */
char *allocFullLabelName(struct ListOfNames *l)
{ char *buf;
  struct NameNode *n;
  if(l==NULL) return NULL;
  
  buf=malloc((l->labellen+l->labelno)*sizeof(char)); /* also allocate space for the separators */
  if (buf==NULL) error("Internal compiler error: allocFullLabelName: out of memory");

  *buf='\0';
  for(n=l->head;n;n=n->next)
  { if (*buf) strcat(buf,":"); /* Not the first label to concat */
    strcat(buf,n->name);
   }
  return buf;

} /* allocFullLabelName */


/* 
 * functions for scope handling
 * 
 * 	showScopeTree
 * 	showScopeTreeWhole
 * 
 * 	lookUpMatchingNode
 * 	checkNameInLabelList
 * 
 * functions for labels:
 * 
 * 	newListOfNames
 *	addName
 *	allocFullLabelName
 * 
 */
 



/* ======================= */

#define DCLATTR_PARAMETER 0
#define DCLATTR_ENTRY_INTERNAL 1

#define SYNTAX_ERROR_DUPLICATE_NAME -1
#define SYNTAX_ERROR -2

/**
 * 
 * called from setScope()...
 */
int processParserStackProcedure
( struct ScopeNode *current
, struct ParserStack *ps
, struct ListOfNames *scopeName
, YYLTYPE *locp
)
{	debugParser("processParserStackProcedure invoked\n");
	debugParser("alright! we have parsed a procedure header\n");
	int i;
	
	if(ps==NULL) 
	{
		error ("get real ... ParserStack has to be allocated");
		return -1;
	}

	if( !(ps->i==PROCEDURE 
	   || ps->i==ENTRY_STMT)) 
	{ error("get real ... ParserStack element is not PROCEDURE, ENTRY_STMT");
	  return -1;
	}

	/*
	printf("ps %s\n",(ps?"not null":"null"));
	printf("ps->pgl %s\n",(ps->pgl?"not null":"null"));
	printf("current %s\n",(current?"not null":"null"));
	printf("current->parent %s\n",(current->parent?"not null":"null"));
	printf("current->parent->dcl %s\n",(current->parent->dcl?"not null":"null"));
	printf("scopeName %s\n",(scopeName?"not null":"null"));
	printf("scopeName->head %s\n",(scopeName->head?"not null":"null"));
	printf("scopeName->head->name %s\n",(scopeName->head->name?"not null":"null"));
	*/

	
	/* 
	 * 1) 
	 * add the name of the procedure to the parent scope as entry reference,
	 * with attribute DCLATTR_ENTRY_INTERNAL
	 * 
	 * 
	 * 2)
	 * if the procedure header is defined with parameters, then
	 * add all the parameters to the current scope with the attribute
	 * PARAMETER, and when the DCL eventually is met, then the parameter
	 * is already there.
	 * 
	 */
	
    showStructProcGroupList(current,ps->pgl);
    i=defineProcedure(current,ps->pgl); /* at current level */
	if(i<0)
	{ error("error defining procedure parameters ...");
	  return SYNTAX_ERROR ;
	} 
	struct DeclareElement *dclElem;
	struct DclOptionList  *dol;
	struct DclOptionPgm   *dop;
	
	dclElem=newDeclareElement();
	dol=newDclOptionList();
	dop=newDclOptionPgm();
	
	//dclElem->dclName=scopeName->head->name ;
	dclElem->implied=1;
	dclElem->dclAttr=dol;
	
	if(locp) 
	{ dclElem->dclLocation=malloc(sizeof(YYLTYPE));
	  if(dclElem->dclLocation==NULL) error("setScope: out of mem...");
      memcpy(dclElem->dclLocation,locp,sizeof(YYLTYPE));
	}
	
	dol->uniontype=DCL_UNIONTYPE_DCLPGM;
	dol->dclpgm=dop;
	dol->internal=1;
    if(ps->i==PROCEDURE) dop->pgmtype=0;
    else 
    if(ps->i==ENTRY_STMT) dop->pgmtype=1;
	
	if(ps->pgl)
	{
	  dop->optionlist=ps->pgl->optionlist   ;
	  dop->returnsList=ps->pgl->returnsList ;
	  dop->reducible=ps->pgl->reducible ;
	/* TODO:
        int chargraphic ; /-* tristate: CHARGRAPHIC/NOCHARGRAPHIC *-/
        int order       ; /-* tristate: ORDER/REORDER             *-/
        int recursive   ; /-* boolean:  RECURSIVE                 *-/
	 */ 
	}
	
	
	/* create the declare element list if necessary */
	if(current->parent->dcl==NULL)
	 current->parent->dcl=newDeclareElementList(NULL);
 
	/* Add all the names in "scopeName->head->name" */
	struct NameNode *nameList;
	for(nameList=scopeName->head; nameList; nameList=nameList->next)
	{ dclElem->dclName=nameList->name;
	  i=addDclDeclareElement(current->parent->dcl,dclElem);
	  if(i<0) 
	  { error("Duplicate entry/procedure name ...");
  	    return SYNTAX_ERROR_DUPLICATE_NAME;
	  } 
	}
	/* cleanup */ 
	//free(dclElem);
	return 0;
}

/**
 * Define the procedure are current level, and add the parameters to
 * the declare list as well.
 * 
 */
int defineProcedure(struct ScopeNode *current, struct ProcGroupList *pgl)
{   int i;
	int rc;
	struct NameNode * work;
	if(pgl==NULL) return 0; 
	if( pgl->parameters==NULL
 	 || pgl->parameters->head==NULL
	  ) return 0; /* no parameters */
	debugParser("defineProcedure invoked\n");
	for(rc=0,i=1,work=pgl->parameters->head;work&&rc==0;work=work->next,i++)
	{
		rc=addDclImplied(current,work->name,DCLATTR_PARAMETER);
	}
	debugParser("defineProcedure invoked ... is done\n");
	return rc;	
}

/**
 * return -1: error when adding name : already exists.
 */
int addDclImplied(struct ScopeNode *current,char *name, int dclattrinfo)
{	struct DeclareElement *dclElem;
	struct DeclareElement *findElem;
	int ok;
	debugParser(">>> addDclImplied invoked %s\n",name);
	if(current==NULL) error("get real ... current scope cannot be null.");
	
	/* Check name does exists within current scope */
	findElem=findDclName(current,name,NULL);
	if(findElem) 
	{  if(dclattrinfo==DCLATTR_PARAMETER) //TODO: set parameter attribute ? 
		  return 0; /* OK parameter already declared */
	   return -1; /* TODO: -ENAMEDUP, meaning name is already defined */
	}

	dclElem=newDeclareElement();
	
	dclElem->dclName=name;
	dclElem->implied=1; /* implicit defined (without declare) */
	/* allocate a dclOption, and set attributes accordingly */
	dclElem->dclAttr=newDclOptionList();
	if(dclattrinfo==DCLATTR_PARAMETER) dclElem->dclAttr->storageclass=5; //PARAMETER
	else
	if(dclattrinfo==DCLATTR_ENTRY_INTERNAL) dclElem->dclAttr->internal=1;

	/* create the declare element list if necessary */
	ok=0;
	if(current->dcl==NULL)
	 current->dcl=newDeclareElementList(dclElem);
	else
  	  ok=addDclDeclareElement(current->dcl, dclElem);
		
	return ok;	
}

int addDclDeclareElementList(struct ScopeNode *current, struct DeclareElementList *elementList,yyscan_t scanner)
{   struct DeclareElement *work;
    struct DeclareElement *findElem;
	int ok;
    char *buf;

	debugParser(">>> addDclDeclareElementList invoked within scope %s\n",current->name->head->name);
	if(current==NULL) error("get real ... current scope cannot be null.");
	
	ok=1;
	for(work=elementList->head;ok>=0 && work;work=work->next)
	{  
		/* Check name does exists within current scope */
	    findElem=findDclName(current, work->dclName, work->structureParent);
	    if(findElem)
	    { showDeclareElement(findElem);
		  showDeclareElement(work);
	     
	      if(findElem->implied==1)
	      { findElem->implied=0; /* explicit declared */
	      	findElem->dclLocation=work->dclLocation;
	      	if(work->dclAttr) /* set attributes if any */
	    	  ok=setDclElementAttr(findElem->dclAttr,work->dclAttr);
	    	if(ok<0)
	    	{
		      buf=sprintfString("Variablename %s, was defined as implied, but attributes did not match"
		                     ,work->dclName);
		      yyerror(work->dclLocation,scanner,buf);
		      return ok;
	    	}
	      }
	      else
	      { 
		    buf=sprintfString("Variablename %s, is already defined at the same scope %s"
		                     ,work->dclName,current->name->head->name);
		    yyerror(work->dclLocation,scanner,buf);
		    return  0; /* Ok, we found a duplicate, but keep parsing */
	    	//return -1; /* TODO: -ENAMEDUP, meaning name is already defined */
	      }
	    }
	    else
	    {
	      if(current->dcl==NULL) /* First declare within scope */
		  { struct DeclareElementList *work2=malloc(sizeof(struct DeclareElementList));
			if (work2==NULL) error("out of mem. addDclDeclareElementList: malloc struct DeclareElementList");
			work2->head=NULL;
			work2->tail=NULL;
			current->dcl=work2;
	      }
	    	
		  ok=addDclDeclareElement(current->dcl, work);
	    }
	}
	return ok;
}

int addDclDeclareElement(struct DeclareElementList *elementlist, struct DeclareElement *element)
{   debugParser(">>> addDclDeclareElement invoked %s\n",element->dclName);
	if(elementlist==NULL) error("get real ... element list cannot be null.");
	if(element==NULL) error("get real ... element cannot be null.");
	
	struct DeclareElement *work;
	/* copy the element and set next to NULL */
	work=malloc(sizeof(struct DeclareElement));
	if (work==NULL) error("out of mem. addDclDeclareElement: malloc struct DeclareElement");
	
	memcpy(work,element,sizeof(struct DeclareElement));
	work->next=NULL;
	
    /* add new dclElem to declare list */
	if(elementlist->head==NULL) /* first element */
	{ elementlist->head=work;
	  elementlist->tail=work;;
	}
	else /* add to ->tail */
	{ elementlist->tail->next=work; /* link next to new element */
	  elementlist->tail=work; /* move tail of list to new element */
	}
	debugParser("... is ok ...");
	return 0;
}

/**
 * returns 
 *  NULL: not found
 *  struct DeclareElement of found entry
 */
 struct DeclareElement * findDclName(struct ScopeNode *current, char * name, struct DeclareElement *structureParent)
{   struct DeclareElement *work;
	debugParser("findDclName invoked for %s \n",name);
	if (structureParent) 
	  debugParser("findDclName ... looking within structure %s level %i \n"
	             , structureParent->dclName
	             , structureParent->structureLevel
	             );

	if(current==NULL) 
	{ error("get real ... ScopeNode not allocated."); 
	  return NULL; 
	}
	
	/* list not allocated: name not found */
	if (current->dcl==NULL) return NULL; 
	
	
	for(work=current->dcl->head; work; work=work->next)
	{// debugParser("findDclName ... checking %s level %i \n",work->dclName, work->structureLevel);
		if(structureParent)
		{ if( work->structureParent==structureParent 
		   && strcmp(name,work->dclName)==0
		    )
		    return work; /* found within structure */
		}
		else
		if( work->structureLevel<= 1  /* must be wo. structure of first level of structure */
		 && strcmp(name,work->dclName)==0
		  ) 
		  return work; /* found */
    }
	return NULL; /* not found */
}




/* helper function to expose some of bisons internal function */
char *pl1parserGetTokenText(int token)
{ return sprintfString("%s",yytname[yytranslate[token]]);
}

