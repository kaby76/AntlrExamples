namespace sexpression
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Tree;
    using System.Collections.Generic;
    using System.Runtime.Serialization;
    using System.Text;

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
            var dot = OutDot(reconstructed_tree);
            System.Console.WriteLine(dot);
        }

        static string OutDot(IParseTree tree)
        {
            var sb = new StringBuilder();
            sb.AppendLine("digraph parsetree {");
            OutDot(sb, tree);
            sb.AppendLine("}");
            return sb.ToString();
        }

        static Dictionary<int, int> low_ints = new Dictionary<int, int>();
        static int gen;

        static void OutDot(StringBuilder sb, IParseTree tree)
        {
            var hc = tree.GetHashCode();
            if (low_ints.TryGetValue(hc, out int low_hc))
                hc = low_hc;
            else
            {
                low_ints[hc] = gen++;
                hc = gen - 1;
            }
            if (tree is ParserRuleContext)
            {
                var name = "\"" + hc + " " + tree.GetType().Name.Replace("Context", "") + "\"";
                for (int i = 0; i < tree.ChildCount; ++i)
                {
                    var c = tree.GetChild(i);
                    var chc = c.GetHashCode();
                    if (low_ints.TryGetValue(chc, out int low_chc))
                        chc = low_chc;
                    else
                    {
                        low_ints[chc] = gen++;
                        chc = gen - 1;
                    }
                    string cname;
                    if (c is TerminalNodeImpl)
                    {
                        cname = ("\"" + chc + " " + c.GetText() + "\"");
                    }
                    else
                    {
                        cname = ("\"" + chc + " " + c.GetType().Name.Replace("Context", "") + "\"");
                    }
                    sb.AppendLine(name + " -> " + cname);
                    OutDot(sb, c);
                }
            }
            else if (tree is TerminalNodeImpl) { }
            else { }
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }
    }
}
