// Template generated code from Antlr4BuildTasks.Template v 2.1
namespace a
{
    using Antlr4.Runtime;
    using System;

    public class Program
    {
        static void Try(string file)
        {
            var str = new AntlrFileStream(file);
            var lexer = new aLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new aParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
        DateTime start = DateTime.Now;
            var tree = parser.file();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
//      System.Console.WriteLine(tokens.OutputTokens());
//      System.Console.WriteLine(tree.OutputTree(tokens));
            System.Console.WriteLine("Times = " + lexer.times);
            DateTime end = DateTime.Now;
            var diff = end - start;
            System.Console.WriteLine("Runtime " + diff);
			System.Console.WriteLine("Tokens " + tokens.GetTokens().Count);
        }

        static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
