// ConsoleApplication1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <ANTLRInputStream.h>
#include "MySQLLexer.h"
#include "MySQLParser.h"
#include "Output.h"

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

void Try(std::string str, int server_version = 0)
{
	antlr4::ANTLRInputStream input(str);
	parsers::MySQLLexer lexer(&input);
	lexer.serverVersion = server_version;
	antlr4::CommonTokenStream tokens(&lexer);
	parsers::MySQLParser parser(&tokens);
	parser.serverVersion = server_version;
	ErrorListener listener;
	parser.addErrorListener(&listener);
	parsers::MySQLParser::QueriesContext* tree = parser.queries();
	std::cout << mysql::Output::OutputTokens(tokens);
	std::cout << mysql::Output::OutputTree(*tree, tokens);
}

int main()
{
	Try("create table `test` (field timestamp(6));");// , 80000);
}

