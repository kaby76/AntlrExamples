// Template generated code from Antlr4BuildTasks.Template v 3.0
#include <iostream>
#include "ANTLRInputStream.h"
#include "arithmeticLexer.h"
#include "arithmeticParser.h"
#include "Output.h"
#include "ErrorListener.h"

void Try(std::string str)
{
	antlr4::ANTLRInputStream input(str);
	CMakeProject1::arithmeticLexer lexer(&input);
	antlr4::CommonTokenStream tokens(&lexer);
	CMakeProject1::arithmeticParser parser(&tokens);
	json::ErrorListener listener;
	parser.addErrorListener(&listener);
	CMakeProject1::arithmeticParser::FileContext* tree = parser.file();
	std::cout << json::Output::OutputTokens(tokens);
	std::cout << json::Output::OutputTree(*tree, tokens);
}

int main()
{
	Try("1 + 2 * 3");
}

