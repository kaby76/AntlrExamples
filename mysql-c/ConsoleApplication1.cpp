// ConsoleApplication1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <ANTLRInputStream.h>
#include "MySQLLexer.h"
#include "MySQLParser.h"

class ErrorListener : public antlr4::ConsoleErrorListener
{
	bool had_error;
public:
	void syntaxError(antlr4::Recognizer* recognizer, antlr4::Token* offendingSymbol, size_t line, size_t col, const std::string& msg, std::exception_ptr e) override
	{
		had_error = true;
		antlr4::ConsoleErrorListener::syntaxError(recognizer, offendingSymbol, line, col, msg, e);
	};
};

int main()
{
	antlr4::ANTLRInputStream input("select 2 as expected, /*!01000/**/*/ 2 as result");
	parsers::MySQLLexer lexer(&input);
	antlr4::CommonTokenStream tokens(&lexer);
	parsers::MySQLParser parser(&tokens);
	ErrorListener listener;
	parser.addErrorListener(&listener);
	parser.query();
}

