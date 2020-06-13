// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace Java
{
    using Antlr4.Runtime;
    using System;
    using System.IO;

    public class Program
    {
        static void Main(string[] args)
        {
            bool build_tree = false;
            bool show_tree = false;
            bool group = true;
            for (int i = 0; i < args.Length; ++i)
            {
                switch (args[i])
                {
                    case "-notree":
                        build_tree = false;
                        break;
                    case "-showtree":
                        show_tree = true;
                        break;
                    case "-group":
                        group = true;
                        break;
                }
            }
            if (group)
            {
                var str = new AntlrInputStream("");
                var lexer = new Java9Lexer(str);
                var tokens = new CommonTokenStream(lexer);
                var parser = new Java9Parser(tokens);
                var listener = new ErrorListener<IToken>(parser, lexer, tokens);
                parser.AddErrorListener(listener);
                parser.BuildParseTree = build_tree;
                for (int i = 0; i < args.Length; ++i)
                {
                    if (args[i].StartsWith('-')) continue;
                    var input = File.ReadAllText(args[i]);
                    str = new AntlrInputStream(input);
                    //                  lexer.Reset();
                    parser.Reset();
                    lexer.SetInputStream(str);
                    tokens.SetTokenSource(lexer);
                    parser.TokenStream = tokens;
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
                    //                  System.Console.WriteLine(tokens.OutputTokens());
                    if (show_tree && tree != null)
                    {
                        System.Console.WriteLine(tree.OutputTree(tokens));
                    }
                    System.Console.WriteLine(end - start);
                }
            }
            else
            {
                for (int i = 0; i < args.Length; ++i)
                {
                    if (args[i].StartsWith('-')) continue;
                    var input = File.OpenText(args[i]);
                    var str = new AntlrInputStream(input);
                    var lexer = new Java9Lexer(str);
                    var tokens = new CommonTokenStream(lexer);
                    var parser = new Java9Parser(tokens);
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
 //                   System.Console.WriteLine(tokens.OutputTokens());
                    if (show_tree && tree != null)
                    {
                        System.Console.WriteLine(tree.OutputTree(tokens));
                    }
                    System.Console.WriteLine(end - start);
                }
            }
        }
    }
}
