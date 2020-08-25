namespace sexpression
{
    using Antlr4.Runtime;

    public class Program
    {
        static void Main(string[] args)
        {
    	    Try(@"
(expression (expression (atom (scientific 1))) + (expression (atom (scientific 2))))
");
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream("");
            var lexer = new arithmeticLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new arithmeticParser(tokens);
            var reconstructed_tree = new Visitor(parser, lexer).CreateTree(input);
            var str_2 = reconstructed_tree.ToStringTree(parser);
            System.Console.WriteLine(input);
            System.Console.WriteLine(str_2);
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
