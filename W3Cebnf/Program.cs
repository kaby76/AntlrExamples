// Template generated code from Antlr4BuildTasks.Template v 8.1
namespace W3Cebnf
{
    using Antlr4.Runtime;
    using System.Text;
    using System.Runtime.CompilerServices;

    public class Program
    {
        static bool show_tree = false;
        static bool show_tokens = false;
        static bool show_input = false;
        static bool have_files = false;
        static bool raw = false;

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
                    case "-raw":
                        raw = true;
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
        }

        static void Try(string input)
        {
            if (show_input)
            {
                System.Console.WriteLine("Input:");
                System.Console.WriteLine(input);
            }
            var str = new AntlrInputStream(input);
            var lexer = new W3CebnfLexer(str);
            var tokens = new CommonTokenStream(lexer);

            if (raw)
            {
                for (; ; )
                {
                    var token = lexer.NextToken();
                    System.Console.WriteLine(token.ToString());
                    if (token.Type == -1) break;
                }
                return;
            }


            var parser = new W3CebnfParser(tokens);
            var tree = parser.prods();
            if (parser.NumberOfSyntaxErrors > 0)
                System.Console.WriteLine("error in parse.");
            else
                System.Console.WriteLine("parse completed.");
            if (show_tokens)
                System.Console.WriteLine(tokens.OutputTokens(lexer));
            if (show_tree)
                System.Console.WriteLine(tree.OutputTree(tokens));
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
