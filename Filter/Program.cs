namespace Filter
{
    using Antlr4.Runtime;
    using System.Text;

    public class Program
    {
        static bool have_files = false;
        static void Main(string[] args)
        {
            Try("A and B");
            Try("A B");
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            System.Console.WriteLine(input);
            var lexer = new FilterLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new FilterParser(tokens);
            var listener_lexer = new ErrorListener<int>();
            var listener_parser = new ErrorListener<IToken>();
            lexer.AddErrorListener(listener_lexer);
            parser.AddErrorListener(listener_parser);
            var tree = parser.filter();
            if (listener_lexer.had_error || listener_parser.had_error)
                System.Console.WriteLine("error in parse.");
            else
                System.Console.WriteLine("parse completed.");
            foreach (var t in tokens.GetTokens())
            {
                System.Console.WriteLine(t);
            }
            System.Console.WriteLine(TreeOutput.OutputTree(tree, lexer, parser, tokens));
	}

	

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
