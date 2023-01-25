parser grammar SybaseParser;

options { tokenVocab=SybaseLexer; }

import TSqlParser;

execute_var_string
: LOCAL_ID (OUTPUT | OUT)? ('+' LOCAL_ID ('+' execute_var_string)?)?
| STRING ('+' LOCAL_ID ('+' execute_var_string)?)?
| DOUBLE_QUOTED_STRING ('+' LOCAL_ID ('+' execute_var_string)?)?
;
