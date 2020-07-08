using System.IO;
using System.Text;

namespace pl1
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string fn)
        {
            var input = ReadAllInput(fn);
            System.Console.WriteLine("Input:");
            System.Console.WriteLine(input);
            var str = new AntlrInputStream(input);
            var lexer = new pl1_parserLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new pl1_parserParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            lexer.AddErrorListener(new ErrorListener<int>(parser, lexer, tokens));
            var tree = parser.pl1pgm();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
            }
            System.Console.WriteLine(tokens.OutputTokens(lexer));
            System.Console.WriteLine(tree.OutputTree(tokens));
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

        static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
