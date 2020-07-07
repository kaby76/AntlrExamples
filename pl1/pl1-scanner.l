%option noyywrap
%option bison-bridge bison-locations
%option reentrant
%option stack
%{
	/* PL1-SCANNER.L
	 * =============
	 * 
	 * PL/I scanner
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
	 */

/* make with flex -v -s -d -p -i pl1.l */
#include <stdio.h>
#include <string.h>
#include <errno.h>


#include "PPDebugLog.h"
#include "TokenLocationStructs.h"
#include "TokenLocation.h"

#include "pl1.tab.h"
#include "pl1pp-parser.h" 

#include "ScannerUtil.h"
#include "SavedTokenStructs.h"
#include "SavedToken.h"
#include "TokenBasedLookahead.h"

#include "ppVariable.h"

#include "PLIMessage.h"
#include "PLIParser.h"

extern int error(const char *msgtext); //TODO: fix error
extern void yyerror (YYLTYPE *locp,
             yyscan_t scanner, 
             char *msg);

int includeCount=0;  /* depth of active include stack */
struct PLIParserIncludeFile *currentIncludeFile=NULL;

/* ======================= */
/* include stack ...       */
 
 struct scannerBufferList
 {
 	struct scannerBufferElement *head, *tail;
 	int count;
 };
 struct scannerBufferElement
 {
 	YY_BUFFER_STATE bufferstate;
 	int sl,sc,so,l,c,o ; /* start- line,column,offset */
 	struct PLIParserIncludeFile *includeBuffer;
 	struct scannerBufferElement *prev; /* reverse linked list */
 };
 
 struct scannerBufferList *currentScannerBufferList=NULL;

 int stackCurrentBuffer(yyscan_t yyscanner, struct PLIParserIncludeFile *currentIncludeFile);
 int switchToPreviousBuffer(yyscan_t yyscanner);
 
 int hasMoreSavedTokens(yyscan_t yyscanner,struct anyTokenList * lahSaveTokensList, int *prev_token);
 int evaluatePreprocessor(yyscan_t yyscanner
   , struct anyTokenList **ppSaveTokensList 
   , struct ppContextAnchor **ppCurrentContext
   , struct PLIParserIncludeFile **currentIncludeFile
   , int *includeCount 
   , int *l$
   , int *c$
   , int *o$
   , int *sl$
   , int *sc$
   , int *so$ 
   );

int resetCurrentContext
( struct ppContextAnchor *ppCurrentContext
);


#define PP_KEEP 0
#define PP_DISPOSE 1
struct savedtokenlist *ppScanTokensForChar(struct anyTokenList *ppSaveTokensList, int find, int dispose);
int ppDetectStmtType(struct anyTokenList *ppSaveTokensList);
int ppProcessLabelStmt(char *labelName,  struct anyTokenList *inTokensList );



/* prototypes:
 * 
 */
int evaluateEOFType
  ( yyscan_t yyscanner
  , int *includeCount
  , int lookahead
  , struct anyTokenList *ppSaveTokensList   
  , struct PLIParserIncludeFile *currentIncludeFile
  , struct ppContextAnchor *ppCurrentContext
  );
/* ====================== */
/* Utilities */

#define isPreprocessingOnly (((struct PLIParserParms *)yyget_extra(yyscanner))->preprocessOnly)

/* -----  end of flex interface ---- */

/* save token lists 
 * 
 */
int lookahead;  /* 0: not enabled, 1: enabled  */

struct anyTokenList *ppCollectedTokensList;
struct anyTokenList *ppSaveTokensList;  /* preprocessor list of tokens */
struct anyTokenList *lahSaveTokensList; /* look ahead list of tokens   */

/* ========================== */
/* prototype */

/* ========================== */
/* init of locations ...      */
int l$=1, c$=0, o$=0, sl$=-1, sc$=-1, so$=-1;
int prev_token=-1;
 

/* ========================= */
/* define the preprocessor context anchor
 * 
 * Contains, 
 * 		list of currently defined preprocessor variables
 * 		return area for parsed include file names
 * 
 */
 
struct ppContextAnchor *ppCurrentContext;

/* prototypes */
int pl1pp_parser(struct anyTokenList *list, struct ppContextAnchor *ppContext);
int ppExpandTokenText(int token, char *text, yyscan_t scanner);
/* ========================== */

/*
   dupyy 
   -----

   this macro is used to handle each token as it passes from the
   lexical stage to the parser stage.  As tokens flow by the get
   stamped with line/column positioning and a file number, which
   is a momento for find the name of the file where this token
   occured (for cross-referencing).
*/

#define dupyy(t) { \
  if(isPreprocessingOnly) \
  { if(!ppCurrentContext->ppGatherTokens) printf("%s", (yytext)); \
  } \
  c$+=(yyleng); \
  o$+=(yyleng); \
  SET_yylloc(yyget_lloc(yyscanner),currentIncludeFile,&sl$,&sc$,&so$,l$,c$,o$,(yyleng)); \
  if(ppExpandTokenText(t,(yytext),yyscanner)==0) \
  { \
  if((t)-STR_CONSTANT==0) yyget_lval(yyscanner)->s=q_strndup((yytext),(yyleng)); \
  else yyget_lval(yyscanner)->s=strdup((yytext)); \
  if(ppCurrentContext->ppGatherTokens) \
  { if (!ppSaveTokensList) ppSaveTokensList=newSaveTokenList("pp scanner");\
  	if (!savetoken(ppSaveTokensList,t,yyget_lloc(yyscanner),yyget_lval(yyscanner)->s)) return _SCANNER_ERROR_; \
  } \
  else if(lookahead) \
  { if (!lahSaveTokensList) lahSaveTokensList=newSaveTokenList("lookahead");\
  	if (!savetoken(lahSaveTokensList,t,yyget_lloc(yyscanner),yyget_lval(yyscanner)->s)) return _SCANNER_ERROR_; \
  } \
  else \
   return_token(t); \
  }\
} 

#define return_token(t)\
{ debugVerbose("%s",sprintf_yylloc(yyget_lloc(yyscanner))); \
  debugLexer("\tToken:%i\t>%s<\n",t,yyget_lval(yyscanner)->s); \
  prev_token=t; \
  return t; \
}



/** 
 * Handle keywords that require special treatment wrt. look ahead.
 * 
 * Parameters are all token constants.
 * 	a: token to use as parameter to enable_lookahead  
 * 	b: token to return if lookahead is being enabled
 * 	c: token to return if lookahead is alread active
 * 
 * For example, the rule for DECLARE should have this check:
 * 
 *   if (!(lookahead||ppGatherTokens)
 *    &&(enable_lookahead(prev_token,DECLARE))
 *	    )
 *    { lookahead=1; /-* enable token based lookahead *-/
 *      dupyy(DECLARE);
 *    }                 
 *    else               
 *    {                 
 *      dupyy(VARNAME); 
 *    }                 
 * 
 * and is done with this macro call
 * 
 * specialKeyWord(DECLARE,DECLARE,VARNAME);
 *   
 * NOTE: lookahead is not allowed to see preprocessor
 *       directive tokens, only the tokens that _result_
 *       from a preprocessor directive.  
 *       If lookahead is active, then the kw is for sure
 *       an identifier
 *  
 */
#define specialKeyWord(a,b,c)               \
{                                           \
  if (!(lookahead||ppCurrentContext->ppGatherTokens)          \
   &&(enable_lookahead(prev_token,a)) \
	 )               \
  { lookahead=1; /* enable token based lookahead */\
    dupyy(b);      \
  }                  \
  else               \
  {                  \
   dupyy(c);       \
  }                  \
}

/*  FLEX Macro 
 *  The macro `YY_USER_INIT' may be defined to provide an action which
 *  is always executed before the first scan (and before the scanner's
 *  internal initializations are done).  For example, it could be used to
 *  call a routine to read in a data table or open a logging file.
 */ 
#define YY_USER_INIT                          \
{                                             \
	/* init look ahead */                 \
	lookahead=0;                          \
	ppCollectedTokensList=NULL;           \
	ppSaveTokensList=NULL;                \
	lahSaveTokensList=NULL;               \
	                                          \
	/* init of location tracking ... */       \
	l$=1; c$=0; o$=0; sl$=-1; sc$=-1; so$=-1; \
	prev_token=-1;                            \
                                                  \
	/* prepreocessor communication area */    \
	ppCurrentContext=newppContextAnchor();    \
        ppCurrentContext->ppGatherTokens=0;       \
        ppCurrentContext->ppScanForLabel=NULL;    \
                                                  \
    /* include structures */                      \
	includeCount=0;                           \
	currentIncludeFile=NULL;                  \
	                                          \
	/* include stack */                       \
	currentScannerBufferList=NULL;            \
	                                          \
        /* ensure a state in stacked, this allows \
         * yy_top_state to be used in all contexts \
         */                                       \
	yy_push_state(INITIAL,yyscanner);         \
}

%}

SP  [ ]
TAB [\t]
HEX [\000\013\014\017\032]
WSP ({SP}|{TAB}|{HEX})*
ANY [^ \t\n\r;\"']+      
NBR [0-9][0-9_]*
LET [A-Z]+
CHR [_$#@]+
VARNAME ({CHR}|{LET})({CHR}|{LET}|[0-9])*
NBREE   (D|E|F|S|Q)[+\-]?{NBR}
		

%x QUOTE
%x QUOTE_D
%x COMMENT
%x LEXRETURNSAVEDTOKENS
%x PP_SKIP
%x _MUST_TERMINATE_
%x PP_DOLOOP
%%
<INITIAL,COMMENT>\n|\r	{ /* '" this comment stops confusing my editor */
	  /* all states but states that needs the \n or \r as part of returned token, like QUOTE */
	
	  l$++;
	  c$=0;  
	  o$+=yyleng; 
	
	  if(isPreprocessingOnly) {
	    printf("\n");
	  }
	}
A               dupyy(A);
ABNORMAL        dupyy(ABNORMAL);
ACT(IVATE)?     dupyy(ACTIVATE);
ADDBUFF         dupyy(ADDBUFF);
ALIAS           dupyy(ALIAS);
ALIGNED         dupyy(ALIGNED);
ALLOC(ATE)?     dupyy(ALLOCATE);
ANYCOND(ITION)? dupyy(ANYCONDITION);
AREA            dupyy(AREA);
ASCII           dupyy(ASCII);
ASSIGNABLE|ASGN dupyy(ASSIGNABLE);
ASM|ASSEMBLER   dupyy(ASSEMBLER);
ATTACH          dupyy(ATTACH);
ATTENTION|ATTN  dupyy(ATTENTION);
AUTO(MATIC)?    dupyy(AUTOMATIC);
B               dupyy(B);
B1              dupyy(B1);
B2              dupyy(B2);
B3              dupyy(B3);
B4              dupyy(B4);
BACKWARDS       dupyy(BACKWARDS);
BASED           dupyy(BASED);
BEGIN           dupyy(BEGIN_);
BIGENDIAN       dupyy(BIGENDIAN);
BIN(ARY)?       dupyy(BINARY);
BIT             dupyy(BIT);
BKWD            dupyy(BKWD);
BLKSIZE         dupyy(BLKSIZE);
BUF(FERED)?     dupyy(BUFFERED);
BUFF(ERS)?      dupyy(BUFFERS);
BUFFOFF         dupyy(BUFFOFF);
BUFND           dupyy(BUFND);
BUFNI           dupyy(BUFNI);
BUFSP           dupyy(BUFSP);
BUILTIN         dupyy(BUILTIN);
BY              dupyy(BY);
BYADDR		dupyy(BYADDR);
BYVALUE		dupyy(BYVALUE);
BX		dupyy(BX);
C               dupyy(C);
CALL            dupyy(CALL);
CDECL           dupyy(CDECL);
CELL            dupyy(CELL);
CHAR(ACTER)?    dupyy(CHARACTER);
CHARG(RAPHIC)?  dupyy(CHARGRAPHIC);
CHECK           dupyy(CHECK);
CLOSE           dupyy(CLOSE);
COBOL           dupyy(COBOL);
COL(UMN)?       dupyy(COLUMN);
COMPLEX|CPLX    dupyy(COMPLEX);
CONN(ECTED)?    dupyy(CONNECTED);
COND(ITION)?    dupyy(CONDITION);
CONSECUTIVE     dupyy(CONSECUTIVE);
CONST(ANT)?     dupyy(CONSTANT);
CTLASA          dupyy(CTLASA);
CTL360          dupyy(CTL360);
CONTROLLED|CTL  dupyy(CONTROLLED);
CONV(ERSION)?   dupyy(CONVERSION);
COPY            dupyy(COPY);
D               dupyy(D);
DB              dupyy(DB);
DATA            dupyy(DATA);
DATE            dupyy(DATE);
DCL|DECLARE { 
    /*
     If we see a 'dcl' inside a preprocessor directory, the
     preprocessor will handle it.
    */
      if(ppCurrentContext->ppGatherTokens)
      {
      	dupyy(DECLARE);
      }
      else
       specialKeyWord(DECLARE,DECLARE,VARNAME);
    }
DEACT(IVATE)?   dupyy(DEACTIVATE);
DEC(IMAL)?      dupyy(DECIMAL);
DFT|DEFAULT	specialKeyWord(DEFAULT,DEFAULT,VARNAME);
DELAY		dupyy(DELAY);
DELETE		dupyy(DELETE);
DEFINE		dupyy(DEFINE);
DEF(INED)?	dupyy(DEFINED);
DESCRIPTOR	dupyy(DESCRIPTOR);
DESCRIPTORS	dupyy(DESCRIPTORS);
DETACH		dupyy(DETACH);
DIM(ENSION)?	dupyy(DIMENSION);
DIRECT		dupyy(DIRECT);
DISPLAY		dupyy(DISPLAY);
DO	 	dupyy(DO);
DOWNTHRU	dupyy(DOWNTHRU)
E		dupyy(E);
EDIT	 	dupyy(EDIT);
ELSE		dupyy(ELSE);
END		{ if(!ppCurrentContext->ppGatherTokens) lookahead=1;
	/* enable lookahead. This will catch cases for named 
	   END where the name is for example a condition name, 
	   as in END finish;
	 */
		dupyy(END); /* END can be a preprocessor stmt */ 
                }
ENDFILE		dupyy(ENDFILE);
ENDPAGE		dupyy(ENDPAGE);
ENTRY		specialKeyWord(ENTRY,ENTRY,ENTRY);
ENV(IRONMENT)?  dupyy(ENVIRONMENT);
ERROR           dupyy(ERROR);
EVENT           dupyy(EVENT);
EXCL(USIVE)?    dupyy(EXCLUSIVE);
EXIT            dupyy(EXIT);
EXPORTS         dupyy(EXPORTS);
EXT(ERNAL)?     dupyy(EXTERNAL);
F               dupyy(F);
FB              dupyy(FB);
FS              dupyy(FS);
FBS             dupyy(FBS);
FETCH           dupyy(FETCH);
FETCHABLE       dupyy(FETCHABLE);
FILE            dupyy(FILE_);
FINISH          dupyy(FINISH);
FIXED           dupyy(FIXED);
FIXEDOVERFLOW|FOFL  dupyy(FIXEDOVERFLOW);
FLOAT           dupyy(FLOAT);
FLUSH           dupyy(FLUSH);
FREE            dupyy(FREE);
FOREVER         dupyy(FOREVER);
FORTRAN         dupyy(FORTRAN);
FORMAT		specialKeyWord(FORMAT,FORMAT_STMT,FORMAT);
FROM            dupyy(FROM);
FROMALIEN       dupyy(FROMALIEN);
G               dupyy(G);
GENERIC         dupyy(GENERIC);
GENKEY          dupyy(GENKEY);
GET             dupyy(GET);
GO              dupyy(GO);
GOTO            dupyy(GOTO); 
GRAPHIC         dupyy(GRAPHIC);
GX              dupyy(GX);
HANDLE		dupyy(HANDLE);
HEXADEC		dupyy(HEXADEC);
I               dupyy(I);
IEEE		dupyy(IEEE);
IF              dupyy(IF);
IGNORE          dupyy(IGNORE);
IMPORTED        dupyy(IMPORTED);
IN              dupyy(IN);
INCLUDE         dupyy(INCLUDE);
INDEXAREA       dupyy(INDEXAREA);
INDEXED         dupyy(INDEXED);
INIT(IAL)?      dupyy(INITIAL_);
INLINE          dupyy(INLINE);
INPUT           dupyy(INPUT);
INTER           dupyy(INTER);
INTERACTIVE     dupyy(INTERACTIVE);
INT(ERNAL)?     dupyy(INTERNAL);
INTO            dupyy(INTO);
INVALIDOP       dupyy(INVALIDOP);
IRRED(UCIBLE)?  dupyy(IRREDUCIBLE);
ITERATE		dupyy(ITERATE);
KEY             dupyy(KEY);
KEYED           dupyy(KEYED);
KEYFROM         dupyy(KEYFROM);
KEYLENGTH       dupyy(KEYLENGTH);
KEYLOC          dupyy(KEYLOC);
KEYTO           dupyy(KEYTO);
LABEL           dupyy(LABEL);
LEAVE           dupyy(LEAVE);
LIMITED         dupyy(LIMITED);
LIKE            dupyy(LIKE);
LINE            dupyy(LINE);
LINESIZE        dupyy(LINESIZE);
LINKAGE         dupyy(LINKAGE);
LIST            dupyy(LIST);
LITTLEENDIAN	dupyy(LITTLEENDIAN);
LOCAL           dupyy(LOCAL);
LOCATE          dupyy(LOCATE);
LOOP            dupyy(LOOP);
M               dupyy(M);
MAIN            dupyy(MAIN);
NAME            dupyy(NAME);
NCP             dupyy(NCP);
NOCHARG(RAPHIC)? dupyy(NOCHARGRAPHIC);
NOCHECK         dupyy(NOCHECK);
NOCONV(ERSION)? dupyy(NOCONVERSION);
NODESCRIPTOR    dupyy(NODESCRIPTOR);
NOEXECOPS       dupyy(NOEXECOPS);
NOF(IXEDOVERFLOW|OFL) dupyy(NOFIXEDOVERFLOW);
NOLOCK          dupyy(NOLOCK);
NONASSIGNABLE|NONASGN dupyy(NONASSIGNABLE);
NONCONN(ECTED)? dupyy(NONCONNECTED);
NONE            dupyy(NONE);
NONVAR(YING)?	dupyy(NONVARYING);
NON_QUICK       dupyy(NON_QUICK);
NO_QUICK_BLOCKS	dupyy(NO_QUICK_BLOCKS);
NOINIT          dupyy(NOINIT);
NOINLINE        dupyy(NOINLINE);
NOINVALIDOP     dupyy(NOINVALIDOP);
NOO(VERFLOW|FL) dupyy(NOOVERFLOW);
NOPRINT		dupyy(NOPRINT);
NORMAL		dupyy(NORMAL);
NOSIZE          dupyy(NOSIZE);
NOSUB(SCRIPTRANGE|RG) dupyy(NOSUBSCRIPTRANGE);
NOSTR(INGRANGE|G)     dupyy(NOSTRINGRANGE);
NOSTR(INGSIZE|Z)      dupyy(NOSTRINGSIZE);
NOTE      	dupyy(NOTE);
NOU(NDERFLOW|FL)      dupyy(NOUNDERFLOW);
NOWRITE               dupyy(NOWRITE);
NOZ(ERODIVIDE|DIV)    dupyy(NOZERODIVIDE);
OFFSET          dupyy(OFFSET);
ON              dupyy(ON);
OPEN            dupyy(OPEN)
OPTIONAL        dupyy(OPTIONAL);
OPTIONS         dupyy(OPTIONS);
OPTLINK         dupyy(OPTLINK);
ORDER           dupyy(ORDER);
ORDINAL         dupyy(ORDINAL);
OTHER(WISE)?	specialKeyWord(OTHERWISE,OTHERWISE,VARNAME);
OUTPUT		dupyy(OUTPUT);
OVERFLOW|OFL	dupyy(OVERFLOW_);
P               dupyy(P);
PACKAGE         dupyy(PACKAGE);
PACKED_DECIMAL  dupyy(PACKED_DECIMAL);
PACKED          dupyy(PACKED);
PAGE            dupyy(PAGE);
PAGESIZE        dupyy(PAGESIZE);
PAR(M|AMETER)   dupyy(PARAMETER);
PASSWORD	dupyy(PASSWORD);
PENDING		dupyy(PENDING);
PIC(TURE)?	dupyy(PICTURE);
POINTER|PTR	dupyy(POINTER);
POS(ITION)?	dupyy(POSITION);
PREC(ISION)?	dupyy(PRECISION);
PRINT	        dupyy(PRINT);
PRIORITY        dupyy(PRIORITY);
PROC(EDURE)?	specialKeyWord(PROCEDURE,PROCEDURE,VARNAME);
PUT             dupyy(PUT);
R               dupyy(R);
RANGE           dupyy(RANGE);
READ            dupyy(READ);
REAL            dupyy(REAL);
RECORD          dupyy(RECORD);
RECSIZE         dupyy(RECSIZE);
RECURSIVE       dupyy(RECURSIVE);
RED(UCIBLE)?	dupyy(REDUCIBLE);
REENTRANT       dupyy(REENTRANT);
REFER           dupyy(REFER);
REGIONAL        dupyy(REGIONAL);
RELEASE         dupyy(RELEASE);
RENAME          dupyy(RENAME);
REORDER         dupyy(REORDER);
REPEAT          dupyy(REPEAT);
REPLACE         dupyy(REPLACE);
REPLY		dupyy(REPLY);
REREAD		dupyy(REREAD);
RESERVED	dupyy(RESERVED);
RESERVES	dupyy(RESERVES);
RESIGNAL	dupyy(RESIGNAL);
RETCODE		dupyy(RETCODE);
RETURN		dupyy(RETURN);
RETURNS		dupyy(RETURNS);
REUSE		dupyy(REUSE);
REVERT		dupyy(REVERT);
REWRITE		dupyy(REWRITE);
SCALARVARYING	dupyy(SCALARVARYING);
SELECT		dupyy(SELECT);
SEPARATE_STATIC	dupyy(SEPARATE_STATIC);
SET             dupyy(SET);
SEQUENTIAL|SEQL	dupyy(SEQUENTIAL);
SIGNAL          dupyy(SIGNAL);
SIGNED          dupyy(SIGNED);
SIS             dupyy(SIS);
SIZE            dupyy(SIZE);
SKIP            dupyy(SKIP);
SNAP	      	specialKeyWord(SNAP,SNAP,VARNAME);
STATIC		dupyy(STATIC);
STDCALL		dupyy(STDCALL);
STORAGE		dupyy(STORAGE);
STOP		dupyy(STOP);
STREAM		dupyy(STREAM);
STRING	 	dupyy(STRING);
STRINGRANGE|STRG        dupyy(STRINGRANGE);
STRINGSIZE|STRZ		dupyy(STRINGSIZE);
STRINGVALUE	dupyy(STRINGVALUE);
STRUCTURE	dupyy(STRUCTURE);
SUB             dupyy(SUB);
SUBSCRIPTRANGE|SUBRG	dupyy(SUBSCRIPTRANGE);
SUPPORT		dupyy(SUPPORT);
SYSTEM		dupyy(SYSTEM);
TASK		dupyy(TASK);
THEN		dupyy(THEN);
THREAD		dupyy(THREAD);
TITLE		dupyy(TITLE);
TO              dupyy(TO);
TOTAL           dupyy(TOTAL);
TP              dupyy(TP);
TRANSIENT       dupyy(TRANSIENT);
TRANSMIT        dupyy(TRANSMIT);
TRKOFL          dupyy(TRKOFL);
TSTACK          dupyy(TSTACK);
TYPE            dupyy(TYPE);
U               dupyy(U);
UNAL(IGNED)?    dupyy(UNALIGNED);
UNBUF(FERED)?   dupyy(UNBUFFERED);
UNCONNECTED     dupyy(UNCONNECTED);
UNDEFINEDFILE|UNDF dupyy(UNDEFINEDFILE);
UNDERFLOW|UFL   dupyy(UNDERFLOW_);
UNION           dupyy(UNION);
UNLOCK          dupyy(UNLOCK);
UNS(IGNED)?     dupyy(UNSIGNED);
UNTIL           dupyy(UNTIL);
UPDATE          dupyy(UPDATE);
UPTHRU          dupyy(UPTHRU)
V               dupyy(V);
VALIDATE        dupyy(VALIDATE);
VALUE           dupyy(VALUE);
VARIABLE        dupyy(VARIABLE);
VAR(YING)?      dupyy(VARYING);
VAR(YING)?Z     dupyy(VARYINGZ);
VB              dupyy(VB);
VBS             dupyy(VBS);
VS              dupyy(VS);
VSAM            dupyy(VSAM);
WAIT            dupyy(WAIT);
WHEN            dupyy(WHEN);
W(IDE)?CHAR     dupyy(WIDECHAR);
WINMAIN         dupyy(WINMAIN);
WHILE           dupyy(WHILE);
WRITE           dupyy(WRITE);
WX              dupyy(WX);
X               dupyy(X);
XN              dupyy(XN);
XU              dupyy(XU);

ZERODIVIDE|ZDIV dupyy(ZERODIVIDE);


"/*"			{ /**/

  BEGIN COMMENT; 
  sl$=l$; 
  sc$=c$; 
  so$=o$; 
  c$+=yyleng; 
  o$+=yyleng; 
}

"'"			{ 

  BEGIN  QUOTE;	

  yymore(); 

  /* store start line,column,offset */ 

  sl$=l$; 
  sc$=c$; 
  so$=o$;
}

"\""			{ 

  BEGIN QUOTE_D;

  yymore(); 

  /* store start line,column,offset */

  sl$=l$;
  sc$=c$;
  so$=o$;
}

{NBR}			dupyy(NUM);
"."{NBR}{NBREE}	        |
"."{NBR}	        |
{NBR}{NBREE}	   	|
{NBR}"."	        |
{NBR}"."{NBREE}	        |
{NBR}"."{NBR}{NBREE}	|
{NBR}"."{NBR}	dupyy(NUMFLOAT); /* consider to let pl1.y handle these combinations */
"||"|"!!"	dupyy(CONCAT);
"**"		dupyy(POWER);
"&"             dupyy(AND);
"|"|"!"         dupyy(OR);
"\xAC"|"^"|"~"      {

  /* 
     NOTE: the character symbol -. is not supported by all editors 
     and debuggers.  In the debugger I use (DDD a very popular Linux
     debugger), this symbol causes the rest of the file to not
     be displayed.   This symbol isn't even on US standard keyboards :(
     Obviously we should support it, but placing in this file makes 
     it impossible to run in a debugger, since DDD won't show the 
     whole file (nothing after the point where this symbol is found
     in the input).

     To get around this I've replaced it with a hex character string
     "\xAC" which is effectively the very same thing, only it allows
     editors/debuggers which don't support that character to keep 
     working.

  */

  dupyy(NOT);
}

"\xAC<"|"^<"|"~<"       dupyy(GE);
">="  	                dupyy(GE);
"\xAC>"|"^>"|"~>"	dupyy(LE);
"<="	                dupyy(LE);

"<>"|"\xAC="|"^="|"~="	{

  /* 
     NOTE: NE is also exlusive or and assign in the context
     of a self referencing assignment statement.  See note 
     below.
  */

  dupyy(NE);
}

"->"                dupyy(PTR);
"=>"                dupyy(HANDLEPTR);
[+\-*/\|!&]=        dupyy(SELFOP);
"||="|"**="|"!!="   dupyy(SELFOP);
[,.()<>=\-+*/]	    dupyy(*yytext);

":"			{  /* C O L O N */

  dupyy(*yytext);

  if (!ppCurrentContext->ppGatherTokens&&lookahead) 
  { /*  Generally solve
	
            kw:kw:kw-stmt;
				
         Problem: at the first kw, the lookahead gets enabled, 
         and at the second kw the rule for the kw will gladly 
         convert the token to VARNAME.

         Generally speaking, the token preceeding a ':' is always
         a VARNAME.  So if lookahead is enabled, then when the ':'
         is read, change the previous token to a varname, and 
         disable the lookahead, and return any saved lookahead 
         tokens, just as varnames.

         Syntax that uses ':'

           dcl a(-1:4) fixed bin(15,0);
	       default range(A:G) fixed bin(31,0);
	       (zdiv):a=1/0;
	       a:b:i=0;
	       a(1):b:labels;
	       dcl:format:entry:proc:entry;
           dcl(1):; /-* Solved in checkstmt *-/
      */

      if(lahSaveTokensList->count==2)
      { /* ':' is the very first token to follow the kw.
         * This basically means if ':' is the second token, then
         * the first token is a VARNAME, so stop the look ahead, 
         * return the tokens.
         */ 
        lahSaveTokensList->head->token=VARNAME;
        BEGIN LEXRETURNSAVEDTOKENS;
      }
    } /* end if !ppGatherTokens&&lookahead */
 }


";"			{  /* S E M I   C O L O N  */

  dupyy(*yytext); 

  /* 
     NOTE: lookahead is not allowed to see preprocessor
     directive tokens, only the tokens that _result_
     from a preprocessor directive.  
  */

  if(ppCurrentContext->ppGatherTokens) 
  { int i=evaluatePreprocessor(yyscanner
		, &ppSaveTokensList 
		, &ppCurrentContext
		, &currentIncludeFile
		, &includeCount 
		, &l$
		, &c$
		, &o$
		, &sl$
		, &sc$
		, &so$ 
		);
debugVerbose("$$$ evaluatePreprocessor returns %i \n",i);
     switch(i)
     { 
       case 0: ppCurrentContext->ppGatherTokens=0;
               break ;
       case 1: BEGIN INITIAL ;
               ppCurrentContext->ppGatherTokens=0;
               break ;
       case 2: ppCurrentContext->ppGatherTokens=1;
               break;
       case 4:
               ppCurrentContext->ppGatherTokens=0;
               ppCurrentContext->loopCurrentToken = NULL ;
               BEGIN PP_DOLOOP ;
               /*
               if(ppDoLoop(ppCurrentContext->loopVarname
                         , ppCurrentContext->loopStartValue    
                         , ppCurrentContext->loopEndValue
                         , ppCollectedTokensList
                         , yyscanner
                         )<0)
                 {
                   BEGIN _MUST_TERMINATE_ ;
                   return _SCANNER_ERROR_; 
                 };
                 */
               break;
       default: /* error */  
               BEGIN _MUST_TERMINATE_ ;
               return _SCANNER_ERROR_; 
               break; /* keep scanning, keep storing tokens */
     }
  }
  else 
  if (lookahead) 
  { 

    if(isDebugLevel(DL_LEXER))
  	showTokenList(lahSaveTokensList);

      /* 
       *  check if the first token is kw or identifier
       *  and set the token accordingly.
       */
    fixKeywordTokens(lahSaveTokensList->head,prev_token);

    BEGIN LEXRETURNSAVEDTOKENS;

    debugLexer("Scanner returning saved tokens");
  } 
}


<LEXRETURNSAVEDTOKENS>.|\n|\r {  
  unput(*yytext);
  
  if(hasMoreSavedTokens(yyscanner,lahSaveTokensList,&prev_token)<0)
  {   lookahead=0; /* Note, if EOF is met, then the lookahead is used 
                    * by then <<EOF>> rule, to determine if LEXRETURNSAVEDTOKENS
                    * is still active.
                    */
  	  BEGIN INITIAL;
  }
  else
    return prev_token;
}

<PP_DOLOOP>.|\n|\r {
    int i ;
    /* as long we are in this scanner state, put the character back on the stack */
    unput(*yytext);
    if(ppCurrentContext->loopCurrentToken==NULL)
    { // start of iteration
      ppSetIntValue(ppCurrentContext->loopVarname, ppCurrentContext->loopStartValue, yyget_lloc(yyscanner));
      // check initial condition
      if (ppCurrentContext->loopStartValue<=ppCurrentContext->loopEndValue)
          ppCurrentContext->loopCurrentToken=ppCollectedTokensList->head;
    }
    else
    { // next token within same iteration
      ppCurrentContext->loopCurrentToken=ppCurrentContext->loopCurrentToken->next;
    }
    // if loopCurentToken is NULL here, then the loop is done.
    // and a new iteration should be started.
    if(ppCurrentContext->loopCurrentToken==NULL)
    { // increment loop variable with one
      // compare to loopendvalue
      // if still true, set loopCurrentToken to head of saved list
      i = ppGetIntValue(ppCurrentContext->loopVarname, yyget_lloc(yyscanner));
      i++;
      ppSetIntValue(ppCurrentContext->loopVarname, i, yyget_lloc(yyscanner));
      if (i<=ppCurrentContext->loopEndValue)
      {  ppCurrentContext->loopCurrentToken=ppCollectedTokensList->head;
      }
      else
      {  // Loop is completely done.
         // clean up, and BEGIN INITIAL;
         BEGIN INITIAL ;
      }
    } /* current token==NULL */
      
    /*
     * Return token to parser.
     * ensure pp variables get expanded.
     * if the token gets expanded, then the function ppExpandToken will 
     * allocate a new buffer that will be processed by flex
     * 
     */
    if(ppCurrentContext->loopCurrentToken)
    { 
      if(*ppCurrentContext->loopCurrentToken->string =='%')
      {
          /*
           * the sequence of tokens are for the preprocessor.
           */
        
          /* 
           * get the preprocessor statement as text and process it 
           */
        char *work=savedtokenListStmtAsString(ppCurrentContext->loopCurrentToken);
        /* ppCurrentContext->loopCurrentToken to the last token in the converted list */
        for(;ppCurrentContext->loopCurrentToken;ppCurrentContext->loopCurrentToken=ppCurrentContext->loopCurrentToken->next)
        {
          if (*ppCurrentContext->loopCurrentToken->string==';') break;
        }
        /* look at ppExpandText */
        /* ok, we got the value, now return it to the scanner */
        /* push the new buffer, and simulate each,
         * macro expansion as an include file.
         * The buffer will be popped by the <<EOF>> rule.
         */
        struct PLIParserIncludeFile *tmpIncludeFile = currentIncludeFile;
        currentIncludeFile=addIncludeFile(ppCurrentContext->ppp->includefilelist
                                             , INCTYPE_PPVAR
                                             , work
                                             , tmpIncludeFile
                                             , yyget_lloc(yyscanner)); /* check location of text variable */
        stackCurrentBuffer(yyscanner,tmpIncludeFile); 
        includeCount++;
        /* notes
        * -----
        *    yy_scan_string, copies the parameter, and do yy_switch_to_buffer() 
        *    The delete of the buffer returned by yy_scan_string is completely
        *    handled in the <<EOF>> scanner rule.
        */
        yy_scan_string (work, yyscanner);
        yy_push_state(INITIAL,yyscanner);
      }
      else
      if(ppExpandTokenText(ppCurrentContext->loopCurrentToken->token,ppCurrentContext->loopCurrentToken->string,yyscanner)==0)
      {  // no expansion
        memcpy(yyget_lloc(yyscanner),ppCurrentContext->loopCurrentToken->locations,sizeof(YYLTYPE));
        yyget_lval(yyscanner)->s=strdup(ppCurrentContext->loopCurrentToken->string);
        debugVerbose("%s",sprintf_yylloc(yyget_lloc(yyscanner)));
        debugLexer("\tToken:%i\t>%s<\n",ppCurrentContext->loopCurrentToken->token,yyget_lval(yyscanner)->s);
        return ppCurrentContext->loopCurrentToken->token;
      }
      else
      {
        /*
         * The buffer has been allocated, and flex is ready to scan the text.
         * Now we have stack the state PP_DOLOOP, and set the current state to INITIAL
         * 
         */
        yy_push_state(INITIAL,yyscanner);
      }
   }
}

  
{VARNAME}		dupyy(VARNAME);

{WSP}+			{ 

  c$+=yyleng; 
  o$+=yyleng; 

  if(isPreprocessingOnly) {
    printf("%s", yytext);
  }
}


"%"		        {   /* P R E P R O C E S S O R */
  if(!ppCurrentContext->ppGatherTokens)
  {  debugLexer("scanner: enabling preprocessor scanning of tokens.\n");
     ppCurrentContext->ppGatherTokens=1;
  }
  dupyy(*yytext);
}


^"*"{SP}*"PROCESS"	{ yymore(); BEGIN PP_SKIP; }

.		{   /* default rule: return UNKNOWN */ 
		  yyerror(NULL,yyscanner
		                 , sprintfString("Unmatched character met in input stream hex value is %x\n",*yytext)
		                 );
		  dupyy(UNKNOWN); 
		}
		
<PP_SKIP>{ANY}      yymore();
<PP_SKIP>{WSP}      yymore();
<PP_SKIP>\"|\'      yymore(); /* '" */

<PP_SKIP>";"		{ 

  c$+=yyleng; 
  o$+=yyleng;

  debugLexer("SCANNER: Preprocessor directive \"%s\", ignored.\n",yytext);

  BEGIN INITIAL;

  SET_yylloc(yyget_lloc(yyscanner),currentIncludeFile,&sl$,&sc$,&so$,l$,c$,o$,yyleng);
}

<COMMENT>"*"+"/"	{ BEGIN INITIAL; 
	                  c$+=yyleng; 
                      o$+=yyleng;
                      SET_yylloc(yyget_lloc(yyscanner),currentIncludeFile,&sl$,&sc$,&so$,l$,c$,o$,yyleng); 
                    }
<COMMENT>[^*/\n\r]* { c$+=yyleng; o$+=yyleng; }
<COMMENT>.          { c$+=yyleng; o$+=yyleng; }
<QUOTE>"''"         yymore();
<QUOTE>[^\'\n\r]*   yymore();
<QUOTE>\n|\r        { yymore(); l$++; c$=0; }
<QUOTE>"'"          { BEGIN INITIAL; 
	              dupyy(STR_CONSTANT); 
	            }
<QUOTE_D>"\"\""     yymore();
<QUOTE_D>[^\"\n\r]* yymore();
<QUOTE_D>\n|\r      { yymore(); l$++; c$=0; }
<QUOTE_D>"\""       { BEGIN INITIAL; 
	              dupyy(STR_CONSTANT); 
	            }
<<EOF>>			    { debugLexer("<<EOF>> met, include count %i\n",includeCount);
  /*
   *  The <<EOF>> rule serves several purposes
   *  	1: detect EOF during preprocessor scan
   *  	2: EOF of an %INCLUDE file or preprocessor expansion
   *  	3: EOF while returning saved tokens
   *  	4: Really EOF of main file 
   */
	switch(evaluateEOFType(yyscanner, &includeCount, lookahead
            , ppSaveTokensList, currentIncludeFile
            , ppCurrentContext
        ))
      { case 1: /* EOF during preprocessor scan */
        /* if the parser request another token, ensure that we are in a error state */
        BEGIN _MUST_TERMINATE_;
        /* Let the parser deal with the error */
        return _SCANNER_ERROR_;
        break;
        case 2: /* EOF detected included file or buffer */
        if ( !YY_CURRENT_BUFFER )
          { debugLexer("ok really end of file ");
            yyterminate();
          }
        /*
         * Restore scanner state to previous, if the do_loop was active.
         * This means EOF met while expanding an preprocessor token, and
         * now return to the processing of the %DO ... %END, as done by
         * the state PP_DOLOOP
         * 
         */
        debugLexer("$$$ EOF rule, top state is %i, PP_DOLOOP is %i\n",yy_top_state(yyscanner),PP_DOLOOP);
        if(yy_top_state(yyscanner)==PP_DOLOOP) yy_pop_state(yyscanner);
        break;
        case 3: /* EOF while returning saved tokens */
        /* unput a pseudo ' ', to ensure scanner
         * continues to return the saved tokens.
         * Note the ' '  will just get eaten by
         * the scanner.
         */
        unput(' ');
        BEGIN LEXRETURNSAVEDTOKENS;
        break;
        case 4: /* Really EOF of main file */
        yyterminate();
        break;
      }

    /* if we make it through to here, then it means
     * the scanner is ready to continue scanning from
     * a stacked input file 
     */
}

<_MUST_TERMINATE_>.|\n 	{
	addErrorMessage((struct PLIParserParms *)yyget_extra(yyscanner),
        sprintfString("SCANNER: Parser requested another token but scanner is in error. Processing stops.\n"));
		yyterminate();
	}

%%


/* ======================== */
/* preprocessor expansion 
 * ppExpandTokenText
 * newppContextAnchor
 */
 
 /* 0: expansion did not change input text
  * 1: expansion did change input text
  * 
  * Note
  * ====
  *   wanted to move ppExpandTokenText to ppVariable.c, but it
	  depends on the pl1.tab.h, and contains the switch to the
	  new include buffer. The switch is, of course, very scanner
	  specific, and should not be done in ppVariable. 
	  At some point should probably separate the functionality,
	  but for now kept it in pl1-scanner.l
  * 
  */
 int ppExpandTokenText(int token, char *text,yyscan_t yyscanner)
 {	struct ppDCLelement *w;
 	if(ppCurrentContext->ppGatherTokens) return 0; /* dont expand during preprocessor scan */
 	if(!ppCurrentContext->ppDCLhead) 
 	  /* no preprocessor DCL statement has been met */
 	  return 0;
 	if(/* dont bother expanding any of these tokens */
 	   token == STR_CONSTANT
 	 ||token == NUM
 	 ||token == NUMFLOAT
 	 ||token == POWER
 	 ||token == CONCAT
 	 ||token == AND
 	 ||token == OR
 	 ||token == NOT
 	 ||token == GE
 	 ||token == LE
 	 ||token == NE
 	 ||token == PTR
 	 ||token == SELFOP
 	 ||token == HANDLEPTR
 	 ||index(",.()<>=-+*/%:;",*text)
 	 ) return 0;
 	
 	/* Ok. now lets see if the yytext actually is a
 	 * preprocessor variable
 	 */
 	 
 	w=ppFindDCLNameInList(ppCurrentContext->ppDCLhead,text);
 	if(!w) return 0; /*  it wasnt */
 	if(w->active!=LIT_DCL_ACTIVE) return 0; /* variable found, but inactive */
 	if(w->type==LIT_DCL_TYPE_LABEL) return 0; /* dont expand % LABELs */
 	
	/* get the value as char */
 	char *value=ppGetValueAsString(w,NULL); /* TODO: add location information */
 	
 	if(!value
 	||*value=='\0'
 	) 
 	{ debugVerbose("Expanding variable %s returned null or empty string",text);
 	return 0; /* weird error happend retrieving string value */
 	}
 	
 	/* ok, we got the value, now return it to the scanner */
 	/* push the new buffer, and simulate each,
 	 * macro expansion as an include file.
 	 * The buffer will be popped by the <<EOF>> rule.
 	 */
 	debugLexer("Expanding %s as %s\n",text,value);
 	struct PLIParserIncludeFile *tmpIncludeFile = currentIncludeFile;
 	currentIncludeFile=addIncludeFile(ppCurrentContext->ppp->includefilelist
 	                                         , INCTYPE_PPVAR
                                             , text
                                             , tmpIncludeFile
                                             , yyget_lloc(yyscanner)); /* check location of text variable */
 	
    stackCurrentBuffer(yyscanner,tmpIncludeFile); 
    includeCount++;
    /* notes
     * -----
     *    yy_scan_string, copies the parameter, and do yy_switch_to_buffer() 
     *    The delete of the buffer returned by yy_scan_string is completely
     *    handled in the <<EOF>> scanner rule.
     *    The next invocation of yylex, will read tokens from the string.
     */
 	yy_scan_string (value, yyscanner);

    return 1; /* yes we made it! */
 }
 
/* ======================= */
/* include stack ...       */
/*  stackCurrentBuffer()
 *  switchToPreviousBuffer()
 */
 int stackCurrentBuffer(yyscan_t yyscanner, struct PLIParserIncludeFile *currentIncludeFile) /* TODO: Add origin of buffer: file or expansion of pp-variable */
 { struct scannerBufferElement *temp;
   struct yyguts_t * yyg = (struct yyguts_t*)yyscanner; /* TODO: only until YY_CURRENT_BUFFER is prober externalised */
 	debugLexer("stacking current scanner buffer\n");
 	temp=malloc(sizeof(struct scannerBufferElement));
 	temp->bufferstate=YY_CURRENT_BUFFER;
 	temp->sl=sl$;
 	temp->sc=sc$;
 	temp->so=so$;
 	temp->l=l$;
 	temp->c=c$;
 	temp->o=o$;
 	temp->includeBuffer=currentIncludeFile;
 	temp->prev=NULL;
 	/* TODO: reference to include file numbering */
 	
 	if(currentScannerBufferList==NULL) /* first element in new list */
 	{ currentScannerBufferList=malloc(sizeof(struct scannerBufferList));
 	  currentScannerBufferList->head=temp;
 	  currentScannerBufferList->tail=temp;
 	  currentScannerBufferList->count=0;
 	}
 	else 
 	if(currentScannerBufferList->tail==NULL) /* first element */
 	{
 	  currentScannerBufferList->head=temp;
 	  currentScannerBufferList->tail=temp;
 	  currentScannerBufferList->count=0;
 	}
 	
 	else
 	{ /* insert element at end of list, and update prev accordingly */
 	  temp->prev=currentScannerBufferList->tail;
 	  currentScannerBufferList->tail=temp;
 	  currentScannerBufferList->count++;
 	}

    /* set to initial values */
    l$=1, c$=0, o$=0, sl$=-1, sc$=-1, so$=-1;
    
 	
 	return 0;
 }
 
 /**
  * switchToPreviousBuffer
  * will do three things:
  * 1) delete current buffer.
  * 2) read last element from the list currentScannerBufferList
  * 2.1) swich to the last saved buffer
  * 2.2) restore location tracking to the point of the switch
  * 2.3) restore currentIncludeBuffer information
  * 3) set last element of list to the previous element
  * 3.1) free the last element
  * 
  **/
 int switchToPreviousBuffer(yyscan_t yyscanner)
 {  struct scannerBufferElement *temp;
 	struct yyguts_t * yyg = (struct yyguts_t*)yyscanner; /* TODO: only until YY_CURRENT_BUFFER is prober externalised */
	debugLexer("switching current scanner buffer to stored buffer on stack.\n");
	
 	yy_delete_buffer( YY_CURRENT_BUFFER, yyscanner );
 	
 	temp=currentScannerBufferList->tail;
 	
 	yy_switch_to_buffer(temp->bufferstate, yyscanner);
 	sl$=temp->sl;
 	sc$=temp->sc;
 	so$=temp->so;
 	l$=temp->l;
 	c$=temp->c;
 	o$=temp->o;
 	currentIncludeFile=temp->includeBuffer;
 	
 	/* now set tail to previous element and dispose the temp element */
 	if(temp->prev==NULL) /* last element in list */
 	{	currentScannerBufferList->head=NULL;
 		currentScannerBufferList->tail=NULL;
 		currentScannerBufferList->count=0;
 	}
 	else
 	{  currentScannerBufferList->tail=temp->prev;
 	   currentScannerBufferList->count--;
 	}
 	
 	free(temp);
 	
 	return 0;
 }
 
/*
 * hasMoreSavedTokens, checks if the list of tokens still contains any tokens.
 * Returns -1: End of list
 *          1: Token found
 * The first token of the list is used, and the lloc and lval are set accordingly,
 * the token value is passed in the output parameter out_token.
 * If there is a token, it is removed from the head of the list, and the head
 * pointer is moved to the next token.
 * Note if the list is empty, the out_token is left unchanged.
 */
int hasMoreSavedTokens(yyscan_t yyscanner, struct anyTokenList * lahSaveTokensList, int *out_token)
{ struct savedtokenlist *work;  
  if (lahSaveTokensList->head==NULL) { 
    /* We are done, now back to normal */
    lahSaveTokensList->count=0;
    return -1;
  } else {
    /* simulate the dupyy macro */
    /*
       set yylval,yylloc and token to saved
       free saved token, and return to parser
       when last token, then BEGIN(INITIAL)
    */
    memcpy(yyget_lloc(yyscanner),lahSaveTokensList->head->locations,sizeof(YYLTYPE));
    yyget_lval(yyscanner)->s=strdup(lahSaveTokensList->head->string);
    *out_token=lahSaveTokensList->head->token;
    
    /* now dispose the first element and move forward to next element */
    work=lahSaveTokensList->head;
    lahSaveTokensList->head=lahSaveTokensList->head->next;
    free(work);
    debugLexer("%s",sprintf_yylloc(yyget_lloc(yyscanner))); 
    debugLexer("\tToken:%i\t>%s<\n",*out_token,yyget_lval(yyscanner)->s);
    return 1;
  }
}

/* detect which kind of <<EOF>> that is actually active.
 *  The <<EOF>> rule serves several purposes
 *	  	1: detect EOF during preprocessor scan
 *	  	2: EOF of an %INCLUDE file
 *	  	3: EOF while returning saved tokens
 *	  	4: Really EOF of main file
 */
int evaluateEOFType(yyscan_t yyscanner, int *includeCount, int lookahead,
    struct anyTokenList *ppSaveTokensList,
    struct PLIParserIncludeFile *currentIncludeFile,
    struct ppContextAnchor *ppCurrentContext)
  {
    int rc;

    if (ppCurrentContext->ppGatherTokens)
      {
        rc=1;
        if (ppCurrentContext->ppScanForLabel==NULL)
          {
            addErrorMessage((struct PLIParserParms *)yyget_extra(yyscanner),
                sprintfString(
                    "SCANNER: preprocessor EOF met while scanning for ';'"
                      " Preprocessor starting at line,col,offset %d,%d,%d \n",
                    ppSaveTokensList->head->locations->first_line,
                    ppSaveTokensList->head->locations->first_column,
                    ppSaveTokensList->head->locations->first_offset));
          }
        else
          {
            addErrorMessage(
                (struct PLIParserParms *)yyget_extra(yyscanner),
                sprintfString(
                    "SCANNER: preprocessor EOF met while scanning for preprocessor label %s \n",
                    ppCurrentContext->ppScanForLabel));
          }
      }
    else if (*includeCount>0)
      {
        rc=2;
        debugLexer("<<EOF>> popping buffer\n", *includeCount);

        /* remove all the defined labels */
        if (currentIncludeFile->type==INCTYPE_FILE)
          ppCurrentContext->ppDCLLabelTail
              =ppPopDCLLabelStack(ppCurrentContext->ppDCLLabelTail);

        (*includeCount)--;
        switchToPreviousBuffer(yyscanner);
        
      }
    else if (lookahead)
      {
        rc=3;
      }
    else
      rc=4;
    
   debugLexer("evaluateEOFType returns %i\n",rc);
    return rc;
  }


/*---------------------------
 * evaluatePreprocessor is called from a scanner rule.
 * 
 * Return
 *  -1: scanner rule should do BEGIN _MUST_TERMINATE_; return _SCANNER_ERROR_ ;
 *   0: preprocessor ended ok, no action needed
 *   1: scanner rule should do BEGIN INITIAL;
 *   2: preprocessor ended ok, continue scanning for preprocessor tokens
 *   4: %END detected. Scanner should call ppDoLoop
 *  
 * 
 * --------------------------
 */
int evaluatePreprocessor(yyscan_t yyscanner,
    struct anyTokenList **ppSaveTokensList,
    struct ppContextAnchor **ppCurrentContext,
    struct PLIParserIncludeFile **currentIncludeFile, int *includeCount,
    int *l$, int *c$, int *o$, int *sl$, int *sc$, int *so$)
  {
    struct yyguts_t * yyg = (struct yyguts_t*)yyscanner; /* TODO: only until YY_CURRENT_BUFFER is prober externalised */
    /* 
     * This procedure check many of the different preprocessor
     * source code constellations. 
     * The processing can be viewed as a pre- and postprocessing of
     * the saved tokens.
     * This procedure will set the scanner in a special mode, that are
     * useful for the PL/I preprocessor.
     * 
     * TODO: restructure this function so the pre/post processing is clear.
     * 
     * 
     * 1) looking for a preprocessor label
     * 2) invoke preprocessor
     * 3) analyse result of preprocessor
     * 
     * 1) looking for a preprocessor label
     *    When looking for a preprocessor label, then a previous %GOTO label
     *    has been met, and the scanner will now discard tokens, until the 
     *    label is found.
     *    If during this discard processing a %label: statement is found, 
     *    then the preprocessor label is added to the list of found labels.
     *    This will allow for a subsequent %GOTO the label. Note only the
     *    %label:; is passed to the preprocessor. The full statement will 
     *    be passed once control is passed to the statement.
     * 
     * 
     * 3) analyse result of preprocessor
     *    The preprocessor can detect a number of legal preprocessor statements, 
     *    and will set the returntype accordingly.
     *    LIT_INCLUDE_FILE_NAME 
     *    LIT_PREPROCESSOR_ERROR
     *    LIT_PREPROCESSOR_GOTO_LABEL
     *    LIT_PREPROCESSOR_GOTO_LOCATION
     *    LIT_PREPROCESSOR_LOOP_DO
     *    LIT_PREPROCESSOR_LOOP_END
     * 
     */

    int ppStmtType=ppDetectStmtType(*ppSaveTokensList);
    debugLexer(" detecting preprocessor statementtype %i\n", ppStmtType );
    int pl1pprc;

    if ((*ppCurrentContext)->ppScanForLabel) /* if preprocessor discard processing is active */
      {
        debugLexer(" preprocessor discarding is active looking for label %s\n",
            (*ppCurrentContext)->ppScanForLabel);

        if (ppStmtType>=100) /* ppstmt contains a label */
          {
            debugLexer(" checking if statement is preprocessor label %s\n", (*ppCurrentContext)->ppScanForLabel);
            // analyze the gatheredtokens
            int checkThePPStmt=ppProcessLabelStmt((*ppCurrentContext)->ppScanForLabel, *ppSaveTokensList);
            if (checkThePPStmt==1)
              { /* found the label
               * Continue with normal preprocessing
               */
                debugLexer(
                    " found GOTO to (forwards) label %s, disabling preprocessor discarding\n",
                    (*ppCurrentContext)->ppScanForLabel);
                free((*ppCurrentContext)->ppScanForLabel);
                (*ppCurrentContext)->ppScanForLabel=NULL;
              }
            else if (checkThePPStmt==2)
              { /* Continue the preprocessor discard scanning */
                debugLexer(" Adding label during preprocessor discard processing\n");
                emptyAnyTokenList(*ppSaveTokensList);
                resetCurrentContext( *ppCurrentContext ) ;
                goto out_two;
                /* Continue preprocessor scan */
              }
            else
              {
                debugLexer(" an error happend in the ppProcessLabel\n");
                emptyAnyTokenList(*ppSaveTokensList);
                resetCurrentContext( *ppCurrentContext) ;
                goto out_error;
              }
          }
        else
          {
            debugLexer(" preprocessor statement does not contain a label\n");
            emptyAnyTokenList(*ppSaveTokensList);
            resetCurrentContext( *ppCurrentContext) ;
            goto out_two;
            /* Continue normal scanning */

          }
      }

    if (ppStmtType < 0 /* not a preprocessor statement */
    ||(ppStmtType == 0&& (*ppCurrentContext)->dolevel>0) /* stmt was a ppstmt, but we are in a %do ... %end */
    )
      {
        if (!ppCollectedTokensList)
          ppCollectedTokensList=newSaveTokenList("pp CollectedTokens");

        appendAnyTokenList(ppCollectedTokensList, *ppSaveTokensList);

        emptyAnyTokenList(*ppSaveTokensList);
        resetCurrentContext( *ppCurrentContext ) ;
        goto out_two;
        /* stmt is not a preprocessor stmt. Continue gathering preprocessor tokens */
      }

    if (isDebugLevel(DL_LEXER))
      showTokenList(*ppSaveTokensList);

    /* TODO: put processing of preprocessor result in separate function */
    (*ppCurrentContext)->ppp=(struct PLIParserParms *)yyget_extra(yyscanner);

    /* Call the PLI preprocessor, with the list of saved tokens */
    debugVerbose("invoking preprocessor via pl1pp_parser\n");

    pl1pprc=pl1pp_parser(*ppSaveTokensList, *ppCurrentContext);

    /* Analyze result of preprocessor */

    if (pl1pprc)
      { /* Preprocessor error */
        goto out_error;
      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_INCLUDE_FILE_NAME)
      {
        debugLexer("preprocessor parser returned filename to include %s\n", (*ppCurrentContext)->ppreturn->string);
        struct PLIParserIncludeFile *tmpIncludeFile = *currentIncludeFile;
        *currentIncludeFile=addIncludeFile((*ppCurrentContext)->ppp->includefilelist, INCTYPE_FILE, (*ppCurrentContext)->ppreturn->string, tmpIncludeFile, (*ppCurrentContext)->ppreturn->location);

        yyset_in(fopen((*ppCurrentContext)->ppreturn->string, "r"), yyscanner);

        if ( !yyget_in(yyscanner) )
          {
            yyerror((*ppCurrentContext)->ppreturn->location, yyscanner,
                sprintfString("%s could not open %include file %s\n",
                    strerror(errno), (*ppCurrentContext)->ppreturn->string));
            goto out_error;
            /* ensure scanner stops if parser request another token */
          }
        else
          {
            stackCurrentBuffer(yyscanner, tmpIncludeFile);
            yy_switch_to_buffer(yy_create_buffer(yyget_in(yyscanner),
                YY_BUF_SIZE, yyscanner ), yyscanner);

            /* add a new stack element for the %LABELs */
            (*ppCurrentContext)->ppDCLLabelTail=ppPushDCLLabelStack((*ppCurrentContext)->ppDCLLabelTail);

            (*includeCount)++;
            emptyAnyTokenList(*ppSaveTokensList);
            resetCurrentContext( *ppCurrentContext ) ;
            goto out_one;
            /* ensure scanner continues with state INITIAL */
          }

      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_PREPROCESSOR_ERROR)
      {
        yyerror((*ppCurrentContext)->ppreturn->location, yyscanner, sprintfString(
            "pl1 preprocessor returned error%s\n", (*ppCurrentContext)->ppreturn->string));
        goto out_error;
        /* ensure scanner stops if parser request another token */
      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_PREPROCESSOR_GOTO_LABEL) /* skip until label is met ... */
      {
        debugLexer(
            " GOTO (forwards) label %s, enabling preprocessor discarding\n", (*ppCurrentContext)->ppreturn->string);
        (*ppCurrentContext)->ppScanForLabel=strdup((*ppCurrentContext)->ppreturn->string);
        emptyAnyTokenList(*ppSaveTokensList);
        resetCurrentContext( *ppCurrentContext ) ;
        goto out_two;
      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_PREPROCESSOR_GOTO_LOCATION) /* reposition scanner to a previous pos. */
      {
        debugLexer(sprintfString(" GOTO (backwards) label %s (location %s)\n",
            (*ppCurrentContext)->ppreturn->string, sprintf_yylloc((*ppCurrentContext)->ppreturn->location)));

        yy_flush_buffer((YY_CURRENT_BUFFER), yyscanner);
        if (fseek(yyget_in(yyscanner), (*ppCurrentContext)->ppreturn->location->first_offset, SEEK_SET))
          {
            yyerror(NULL,yyscanner
            ,sprintfString("%s, could not do fseek to location %i\n",strerror(errno),(*ppCurrentContext)->ppreturn->location->first_offset ));
            goto out_error;
            /* ensure scanner stops if parser request another token */
          }
        else
          { /* set current location to match location of label */
            *l$=(*ppCurrentContext)->ppreturn->location->first_line;
            *c$=(*ppCurrentContext)->ppreturn->location->first_column;
            *o$=(*ppCurrentContext)->ppreturn->location->first_offset;
            *sl$=-1;
            *sc$=-1;
            *so$=-1;
          }

        emptyAnyTokenList(*ppSaveTokensList);
        resetCurrentContext( *ppCurrentContext );
        goto out_zero;

      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_PREPROCESSOR_LOOP_DO) /* %DO - %END  INITIALLY TRUE  */
      {
        debugParser(sprintfString(
            " preprocessor DO .. END at DO (location %s)\n", sprintf_yylloc((*ppCurrentContext)->ppreturn->location)));
        /* 
         * The %DO has been analysed by the preprocessor, and the loop 
         * conditions have been set in the ppCurrenContext structure.  
         * 
         * Reset the current list of preprocessor tokens, but keep 
         * the gathering of tokens active. (out_two)
         */
        emptyAnyTokenList(*ppSaveTokensList);
        resetCurrentContext( *ppCurrentContext ) ;
        goto out_two;
      }
    else if ((*ppCurrentContext)->ppreturn->type==LIT_PREPROCESSOR_LOOP_END) /* %DO - %END  INITIALLY FALSE */
      {
        debugParser(sprintfString(
            " preprocessor DO .. END at END (location %s)\n", sprintf_yylloc((*ppCurrentContext)->ppreturn->location)));
        /*
         * Now at %END, the tokens saved away must be returned to the parser.
         * Convert the saved tokens to a new scanner buffer, and let the scanner
         * do its job again, end eventually return the tokens to the parser.
         */
        emptyAnyTokenList(*ppSaveTokensList);
        resetCurrentContext( *ppCurrentContext ) ;
        goto out_four;
      }
    else
      {
        debugLexer("pl1 preprocessor returned unhandled information. Scanning continues.\n");
      }

    /* the preprocessing handling is done, now free the 
     * saved tokenlist, and initialize the return variable
     * Note this label is used when scanning for specific
     * preprocessor tokens and when the ppGatherTokens flag
     * should be kept active.
     */

    emptyAnyTokenList(*ppSaveTokensList);
    resetCurrentContext( *ppCurrentContext ) ;
    goto out_zero;

    out_zero: return 0; /* preprocessor ended ok, and no action is needed    */
    out_one: return 1; /* scanner should continue with INITIAL              */
    out_two: return 2; /* scanner should keep preprocessing scanning active */
    out_four: return 4; /* preprocessor %END met. Scanner should call ppDoLoop */
    out_error: return -1; /* ensure scanner stops if parser request another token */

  }

/* helper function for evaluatePreprocessor */
int resetCurrentContext
( struct ppContextAnchor *ppCurrentContext
)
{  debugLexer("$$$ resetCurrentContext\n");
   ppCurrentContext->ppreturn->type=-1;

 return 0;	
}


/* 
 * Analyse the tokens to detect the preprocessor 
 * statement type
 * Return
 *    -1 : Not a pp statement
 *     0 : pp statement
 *   100 : % label : pp statement
 *     2 : % DO
 *   102 : % label : DO
 *     3 : % END 
 *   103 : % label : END
 * 
 * TODO: named %END statement
 *     4 : % END label 
 *   104 : % label : END label
 * 
 * 
 * 
 */ 
int ppDetectStmtType(struct anyTokenList *ppSaveTokensList)
{
	
	struct savedtokenlist *workTokens,*workTokensPct;
    int rc;

	/* this will work as long as ':' only can be used as
	 * as label indicator
	 */
	workTokensPct=ppScanTokensForChar(ppSaveTokensList,'%',PP_KEEP);
	if(!workTokensPct) { rc= -1; goto out; }
 
	workTokens=ppScanTokensForChar(ppSaveTokensList,':',PP_KEEP);
	if(workTokens) { rc=100; workTokens=workTokens->next; }
	else           { rc=  0; workTokens=workTokensPct->next; /* skip '%' */ }
	
	debugLexer("ppDetectStmtType: token=%i (DO %i) (END %i)\n",workTokens->token,DO,END);
	
	     if(workTokens->token==DO ) rc+=2;
	else if(workTokens->token==END) rc+=3;
	
	out:;
	
	return rc;
}

/* 
 * Look at the list of tokens for the start and scan for 
 * a token that equals the char
 */
struct savedtokenlist *ppScanTokensForChar(
    struct anyTokenList *ppSaveTokensList, int find, int dispose)
  {
    struct savedtokenlist *workTokens, *work;

    /* look for ch */
    for (workTokens=ppSaveTokensList->head; workTokens;)
      {
        if (workTokens->token==find)
          break;

        work=workTokens;
        workTokens=workTokens->next;
        
        if (dispose==PP_DISPOSE)
        {
          debugVerbose("disposing token %i: %s\n",work->token,work->string);
          free(work);
          /* decrease list counter */
          ppSaveTokensList->count--;
        }
      }

    if (dispose==PP_DISPOSE)
    {
      /* set head of list to current workTokens */
      ppSaveTokensList->head=workTokens;
    }
    return workTokens;
  }


/**
 * ppProcessLabelStmt is invoked from the scanner, to check if the label on a 
 * preprocessor statement matches the one being looked for.
 * This function is called from the scanner when a ';' has been met, and 
 * if the preprocessor statement has a label
 *  
 * returns -1: internal processing error detected, scanner should stop
 *          1: statement is a preprocessor label statement and the label matches
 *          2: statement is a preprocessor label statement but the label doesnt match
 */
int ppProcessLabelStmt(char *labelName, struct anyTokenList *inTokensList)
  {
    struct savedtokenlist *savedtemp;
    int xLabelFound, xColonFound;

    if (!labelName)
      {
        debugLexer("ppCheckLabel: called from illegal context, labelName not allocated");
        goto out_error;
      }

    /* now match the following sequence of tokens
     *  
     * '%' any ( ',' any )* ':' ppStmt ';'
     *  
     */
    savedtemp=ppScanTokensForChar(inTokensList, '%',PP_DISPOSE);
    
    for (xLabelFound=0, xColonFound=0, savedtemp=savedtemp->next /* skip '%' */
    ; savedtemp; savedtemp=savedtemp->next)
      { /* create a copy of the token */

        if (savedtemp->token==',') /* NOP */
          ;
        else if (savedtemp->token==':')
          {
            xColonFound=1;
            break;
          }
        else
          {
            if (strcasecmp(savedtemp->string, labelName)==0)
              { /* label found, now continue looking at tokens to ensure the ':' is found as well */
                xLabelFound=1;
              }

            /* Add label to internal structure */
            if (!ppDefineVariable(savedtemp->string, LIT_DCL_TYPE_LABEL,
                savedtemp->locations))
              goto out_error;
          }
      }

    if (!xColonFound)
      {
        debugLexer("ppCheckLabel: called from illegal context, statement isnt '\%' any ( ',' any )* ':' ppStmt ';' ");
        goto out_error;
      }
    if (xLabelFound)
      goto out_one;

    /* statement has a label */
    goto out_two;

    /* internal processing error detected */
    out_error: return -1;

    /* statement is sought preprocessor label statement */
    out_one: return 1;

    /* statement is a preprocessor label statement */
    out_two: return 2;
  }

