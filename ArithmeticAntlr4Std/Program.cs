namespace Program
{
    using Antlr4.Runtime;

    class Program
    {
        static void Main(string[] args)
        {

            var str = new Antlr4.Runtime.AntlrInputStream("1 + 2");
            var lexer = new arithmeticLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new arithmeticParser(tokens);
            var tree = parser.file();
            System.Console.WriteLine(tree.ToStringTree(parser.RuleNames));
        }
    }
}
