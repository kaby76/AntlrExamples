// Template generated code from Antlr4BuildTasks.Template v 7.3
namespace Matlab
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new matlabLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new matlabParser(tokens);
            lexer.Parser = parser;
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.translation_unit();
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
            Try(@"a = 'A string with ''apostrophes''';
a = [ 1 2 3 ];
b = a';");
        }
    }
}
