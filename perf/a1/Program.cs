// Template generated code from Antlr4BuildTasks.Template v 2.1
namespace a
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new aLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new aParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.file();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            System.Console.WriteLine(tokens.OutputTokens());
	    System.Console.WriteLine(tree.OutputTree(tokens));
	    System.Console.WriteLine("Times = " + lexer.times);
        }

        static void Main(string[] args)
        {
            Try("a a a ");
            Try("a b a a");
        }
    }
}
