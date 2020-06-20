// Template generated code from Antlr4BuildTasks.Template v 7.3

using System.IO;

namespace Matlab
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new matlabLexer(str);
            var tokens = new CommonTokenStream(lexer);
            lexer.RealTokenStream = tokens;
            var parser = new matlabParser(tokens);
            lexer.Parser = parser;
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
            }

            System.Console.WriteLine(tokens.OutputTokens());
            System.Console.WriteLine(tree.OutputTree(tokens));
        }

        static void TryOctave(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new OctLexer(str);
            var tokens = new CommonTokenStream(lexer);
            lexer.RealTokenStream = tokens;
            var parser = new OctParser(tokens);
            lexer.Parser = parser;
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.input_aug();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
            }

            System.Console.WriteLine(tokens.OutputTokens());
            System.Console.WriteLine(tree.OutputTree(tokens));
        }

        static void Main(string[] args)
        {
            string input;
            if (args.Length == 0)
            {
                input = @"a;
a + b;
'a' + 'b';
a = 'A string with ''apostrophes''';
b = [ 1 2 3 ];
c = a';
d = a' + a';
e = a' + b' + c';
f = 'x' + ' + y';
";
                // a b; not legal.
                // x' + y'; not legal.

                Try(input);
                TryOctave(input);
            }
            else
            {
                foreach (var i in args)
                {
                    input = File.OpenText(i).ReadToEnd();
                    Try(input);
                }
            }
        }
    }
}
