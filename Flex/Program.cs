// Template generated code from Antlr4BuildTasks.Template v 2.1

namespace Flex
{
    using Antlr4.Runtime;

    public class Program
    {
        private static void Try(string input)
        {
            AntlrFileStream str = new AntlrFileStream(input);
            FlexLexer lexer = new FlexLexer(str);
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            FlexParser parser = new FlexParser(tokens);
            ErrorListener<IToken> listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            FlexParser.GoalContext tree = parser.goal();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
            }
        }

        private static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
