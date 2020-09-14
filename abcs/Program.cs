// Template generated code from Antlr4BuildTasks.Template v 8.1
namespace a
{
    using Antlr4.Runtime;
    using System.Text;
    using System.Runtime.CompilerServices;
    using System.IO;

    public class Program
    {
        static bool have_files = false;

        static void Main(string[] args)
        {
            for (int i = 0; i < args.Length; ++i)
            {
                switch (args[i])
                {
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
                    TryFile(fn);
                }
            }
            else
            {
                Try("aaaa bbb cc");
            }
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new AbcLexer(str);
            var tokens = new UnbufferedTokenStream(lexer);
            var parser = new AbcParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            lexer.AddErrorListener(new ErrorListener<int>(parser, lexer, tokens));
            parser.BuildParseTree = false;
            lexer.TokenFactory = new MyCTF();
            var tree = parser.file();
            if (listener.had_error)
                System.Console.WriteLine("error in parse.");
            else
                System.Console.WriteLine("parse completed.");
        }

        static void TryFile(string fn)
        {
            var str = new UnbufferedCharStream(new StreamReader(fn));
            var lexer = new AbcLexer(str);
            var tokens = new UnbufferedTokenStream(lexer);
            var parser = new AbcParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            lexer.AddErrorListener(new ErrorListener<int>(parser, lexer, tokens));
            parser.BuildParseTree = false;
            lexer.TokenFactory = new MyCTF();
            var tree = parser.file();
            if (listener.had_error)
                System.Console.WriteLine("error in parse.");
            else
                System.Console.WriteLine("parse completed.");
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
