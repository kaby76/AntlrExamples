// Template generated code from Antlr4BuildTasks.Template v 7.3

using Antlr4.Runtime.Tree;

namespace Binary
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new BinaryLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new BinaryParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.expr();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
                System.Console.WriteLine(tokens.OutputTokens());
                System.Console.WriteLine(tree.OutputTree(tokens));
            }
            else
            {
                System.Console.WriteLine("parse completed.");
                System.Console.WriteLine(tokens.OutputTokens());
                System.Console.WriteLine(tree.OutputTree(tokens));
                var c = new Class1();
                ParseTreeWalker.Default.Walk(c, tree);
            }
        }

        static void Main(string[] args)
        {
            Try("((A∧B)∨((A∧B)∧B))⇒B");
        }
    }
}
