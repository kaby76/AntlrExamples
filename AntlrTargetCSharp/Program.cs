namespace Antlr
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string ffn)
        {
            var str = new AntlrFileStream(ffn);
            var lexer = new ANTLRv4Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new ANTLRv4Parser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.grammarSpec();
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
