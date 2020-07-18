using System.IO;
using System.Text;

namespace pl1
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Main(string[] args)
        {

            bool show_tree = false;
            bool show_tokens = false;
            bool show_input = false;
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
                }
            }
            for (int i = 0; i < args.Length; ++i)
            {
                if (args[i].StartsWith('-')) continue;
                var fn = args[i];
                var input = ReadAllInput(fn);
                if (show_input)
                {
                    System.Console.WriteLine("Input:");
                    System.Console.WriteLine(input);
                }
                var str = new AntlrInputStream(input);
                var lexer = new pl1_parserLexer(str);
                var tokens = new CommonTokenStream(lexer);
                var parser = new pl1_parserParser(tokens);
                var listener = new ErrorListener<IToken>(parser, lexer, tokens);
                parser.AddErrorListener(listener);
                //lexer.AddErrorListener(new ErrorListener<int>(parser, lexer, tokens));
                var tree = parser.pl1pgm();
                if (listener.had_error)
                    System.Console.WriteLine("error in parse.");
                else
                    System.Console.WriteLine("parse completed.");
                if (show_tokens)
                    System.Console.WriteLine(tokens.OutputTokens(lexer));
                if (show_tree)
                    System.Console.WriteLine(tree.OutputTree(tokens));
            }
        }

        static string ReadAllInput(string fn)
        {
            var sb = new StringBuilder();
            var lines = System.IO.File.ReadAllLines(fn);
            foreach (var line in lines)
            {
                if (line.Length >= 1)
                    sb.AppendLine(" " + line.Substring(1));
                else
                    sb.AppendLine();
            }
            return sb.ToString();
        }
    }
}
