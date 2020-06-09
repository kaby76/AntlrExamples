// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace xpath
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Try(string ffn)
        {
            System.IO.StreamReader file = new System.IO.StreamReader(ffn);
            string line;
            while ((line = file.ReadLine()) != null)
            {
                System.Console.WriteLine("===== Expression =====");
                System.Console.WriteLine(line);
                var str = new AntlrInputStream(line);
                var lexer = new XPath31Lexer(str);
                var tokens = new CommonTokenStream(lexer);
                var parser = new XPath31Parser(tokens);
                var listener = new ErrorListener<IToken>(parser, lexer, tokens);
                parser.AddErrorListener(listener);
                var tree = parser.xpath();
                if (listener.had_error)
                {
                    System.Console.WriteLine("error in parse.");
                    System.Console.WriteLine(tokens.OutputTokens());
                    System.Console.WriteLine(tree.OutputTree(tokens));
                    return;
                }
                else
                {
                    System.Console.WriteLine("parse completed.");
                }
                string xpath = "//exprsingle";
                var names = Antlr4.Runtime.Tree.Xpath.XPath.FindAll(tree, xpath, parser);
                foreach (var n in names)
                {
                    System.Console.WriteLine("match " + n.GetText());
                }
            }
        }

        static void Main(string[] args)
        {
            Try(args[0]);
        }
    }
}
