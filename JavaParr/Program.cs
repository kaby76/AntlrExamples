// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace JavaParr
{
    using Antlr4.Runtime;
    using System.IO;

    public class Program
    {
        static void Main(string[] args)
        {
            var input = File.OpenText(args[0]);
            var str = new AntlrInputStream(input);
            var lexer = new JavaLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new JavaParser(tokens);
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
