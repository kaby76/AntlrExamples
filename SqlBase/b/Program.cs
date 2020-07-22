// Template generated code from Antlr4BuildTasks.Template v 8.1

using System;
using System.Linq;

namespace a
{
    using Antlr4.Runtime;

    public class Program
    {
        static bool show_tree = false;
        static bool show_tokens = false;
        static bool show_input = false;
        static bool have_files = false;

        static void Main(string[] args)
        {
            for (int i = 0; i < args.Length; ++i)
            {
                switch (args[i])
                {
                    case "-tree":
                        show_tree = true;
                        break;
                    case "-tokens":
                        show_tokens = true;
                        break;
                    case "-input":
                        show_input = true;
                        break;
                    default:
                        have_files = true;
                        break;
                }
            }
            if (have_files)
            {
                for (int i = 0; i < args.Length; ++i)
                {
                    if (args[i].StartsWith('-')) continue;
                    var fn = args[i];
                    var input = ReadAllInput(fn);
                    Try(input);
                }
            }
            else
            {
                Try(@"
CREATE TABLE PERSONS (
    PERSONID INT,
    LASTNAME VARCHAR(255),
    FIRSTNAME VARCHAR(255),
    ADDRESS VARCHAR(255),
    CITY VARCHAR(255)
);
");
            }
        }

        static void Try(string input)
        {
            input = string.Concat(Enumerable.Repeat(input, 100000));
            if (show_input)
            {
                System.Console.WriteLine("Input:");
                System.Console.WriteLine(input);
            }

            DateTime before = DateTime.Now;
            var str = new AntlrInputStream(input);
            var lexer = new SqlBaseLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new SqlBaseParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            lexer.AddErrorListener(new ErrorListener<int>(parser, lexer, tokens));
            var tree = parser.multipleStatement();
            DateTime after = DateTime.Now;
            if (listener.had_error)
                System.Console.WriteLine("error in parse.");
            else
                System.Console.WriteLine("parse completed.");
            if (show_tokens)
                System.Console.WriteLine(tokens.OutputTokens(lexer));
            if (show_tree)
                System.Console.WriteLine(tree.OutputTree(tokens));
            System.Console.WriteLine("time " + (after - before));
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
