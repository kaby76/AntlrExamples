// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace Java
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Main(string[] args)
        {
            var input = File.OpenText(args[0]);
            var str = new AntlrInputStream(input);
            var lexer = new Java9Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new Java9Parser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.compilationUnit();
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
    }
}
