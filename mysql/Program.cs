using Antlr4.Runtime;

namespace mysql
{
    public class Program
    {
        static void Try(string input)
        {
            //var str = new AntlrInputStream(input);
            var str = new AntlrInputStream(input);
            var lexer = new MySQLLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new MySQLParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.query();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
                System.Console.WriteLine(tokens.OutputTokens());
                System.Console.WriteLine(tree.OutputTree(tokens));
            }
        }

        static void Main(string[] args)
        {
            Try("select * from foobar;");
        }
    }
}
