// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace Java
{
    using Antlr4.Runtime;
    using System;
    using System.IO;
    using System.Linq;

    public class Program
    {
        static void Main(string[] args)
        {
            int i = 0;
            bool build_tree = true;
            for (; i < args.Length; ++i)
            {
                switch (args[i])
                {
                    case "-notree":
                        build_tree = false;
                        break;
                }
            }
            var input = File.OpenText(args[i-1]);
            var str = new AntlrInputStream(input);
            var lexer = new Java9Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new Java9Parser(tokens);
            parser.Lexer = lexer;
            lexer.Parser = parser;
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            parser.BuildParseTree = build_tree;
            var start = DateTime.Now;
            var tree = parser.compilationUnit();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
            }
            var end = DateTime.Now;
            System.Console.WriteLine(tokens.OutputTokens());
            if (tree != null)
            {
                System.Console.WriteLine(tree.OutputTree(tokens));
            }
            System.Console.WriteLine(end - start);
        }
    }
}
