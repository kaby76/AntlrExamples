// Template generated code from Antlr4BuildTasks.Template v 2.1
namespace Bison
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrFileStream(input);
            var lexer = new BisonLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new BisonParser(tokens);
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

        static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
