// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace yes3
{
    using Antlr4.Runtime;
    public class Program
    {
        static void Main(string[] args)
        {
            var str = new AntlrInputStream(System.Console.In);
            var lexer = new Yes3Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new Yes3Parser(tokens);
            var tree = parser.file();
            System.Console.WriteLine("parse completed.");
        }
    }
}
