// Template generated code from Antlr4BuildTasks.Template v 8.4
namespace consoleapp
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Tree;
    using Antlr4.Runtime.Misc;
    using System;
    using System.Text;
    using System.Linq;
    using System.Collections.Generic;

    public class Program
    {
        static bool have_files = false;
        static void Main(string[] args)
        {
            have_files = args.Length > 0;
            if (have_files)
            {
                for (int i = 0; i < args.Length; ++i)
                {
                    if (args[i].StartsWith('-')) continue;
                    var fn = args[i];
                    var input = ReadAllInput(fn);
                    Try(input);
                }
            }
            else
            {
                Try(" /* hi there */ 1 /* more stuff */ + 2 + 3");
            }
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
//            System.Console.WriteLine(input);
            var lexer = new Dart2Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new Dart2Parser(tokens);
            var listener_lexer = new ErrorListener<int>();
            var listener_parser = new ErrorListener<IToken>();
            lexer.AddErrorListener(listener_lexer);
            parser.AddErrorListener(listener_parser);
            var tree = parser.compilationUnit();
	        if (listener_lexer.had_error || listener_parser.had_error)
	        {
		        System.Console.WriteLine("error in parse.");
		        for (int i = 0; ; ++i)
                {
                    var token = tokens.Get(i);
                    System.Console.WriteLine(token.ToString());
                    if (token.Type == Antlr4.Runtime.TokenConstants.EOF) break;
                }
	        }
            else
            System.Console.WriteLine("parse completed.");
//            System.Console.WriteLine(tree.ToStringTree());
//            Decorate(tree, parser);
//            System.Console.WriteLine(tree.ToStringTree());
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }

        static void Decorate(IParseTree tree, Parser parser)
        {
            // DFS walk, add in nodes bottom up.
            if (tree is ParserRuleContext internal_node)
            {
                var old_children = internal_node.children.ToArray();
                for (int i = 0; i < old_children.Length; ++i)
                {
                    var c = old_children[i];
                    var as_terminal_node = c as TerminalNodeImpl;
                    if (as_terminal_node != null)
                    {
                        var interval = as_terminal_node.SourceInterval;
                        var stream = parser.TokenStream as CommonTokenStream;
                        IList<IToken> inter = null;
                        if (as_terminal_node.Symbol.TokenIndex >= 0)
                            inter = stream?.GetHiddenTokensToLeft(as_terminal_node.Symbol.TokenIndex);
                        if (inter != null)
                        {
                            foreach (var t in inter.Reverse())
                            {
                                var new_child = new TerminalNodeImpl(t);
                                internal_node.children.Insert(i, new_child);
                            }
                        }
                    }
                    Decorate(c, parser);
                }
            }
            else if (tree is TerminalNodeImpl terminal_node)
            {
            }
            else throw new Exception();
        }
    }
}
