// ConsoleApplication1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <ANTLRInputStream.h>
#include "MySQLLexer.h"
#include "MySQLParser.h"
#
int main()
{
	antlr4::ANTLRInputStream input("select 2 as expected, /*!01000/**/*/ 2 as result");
	parsers::MySQLLexer lexer(&input);
	antlr4::CommonTokenStream tokens(&lexer);
	parsers::MySQLParser parser(&tokens);
	parser.query();
}

