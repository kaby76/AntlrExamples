parser grammar aParser;

options {
	tokenVocab = aLexer ;
}

file : (A | B)+ EOF;
