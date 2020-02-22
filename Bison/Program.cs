// Template generated code from Antlr4BuildTasks.Template v 2.1

using System;
using System.Collections.Generic;
using Antlr4.Runtime.Tree;

namespace Bison
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrFileStream(input);
            var lexer = new BisonLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new BisonParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.input();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
                var visitor = new GrammarListener();
                ParseTreeWalker.Default.Walk(visitor, tree);
                foreach (Tuple<string, List<List<string>>> r in visitor.rules)
                {
                    string lhs = r.Item1;
                    System.Console.WriteLine(lhs);
                    List<List<string>> rhs = r.Item2;
                    bool first = true;
                    foreach (List<string> s in rhs)
                    {
                        System.Console.Write(first ? "  :" : "  |");
                        first = false;
                        foreach (var c in s)
                            System.Console.Write(" " + c);
                        System.Console.WriteLine();
                    }
                    System.Console.WriteLine("  ;");
                }
            } 
            System.Console.WriteLine(tokens.OutputTokens());
            System.Console.WriteLine(tree.OutputTree(tokens));
        }

        static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
