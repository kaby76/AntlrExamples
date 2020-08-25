namespace sexpression
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Misc;
    using Antlr4.Runtime.Tree;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Reflection;

    class Visitor : sexpressionBaseVisitor<List<IParseTree>>
    {
        private Parser _parser;
        private Lexer _lexer;

        public Visitor(Parser parser, Lexer lexer)
        {
            _parser = parser;
            _lexer = lexer;
        }

        public IParseTree CreateTree(string ast_string)
        {
            IParseTree result = null;
            var ast_stream = CharStreams.fromstring(ast_string);
            var ast_lexer = new sexpressionLexer(ast_stream);
            var ast_tokens = new CommonTokenStream(ast_lexer);
            var ast_parser = new sexpressionParser(ast_tokens);
            ast_parser.BuildParseTree = true;
            IParseTree sexpr = ast_parser.sexpr();
            if (ast_parser.NumberOfSyntaxErrors > 0) throw new Exception();
            System.Console.WriteLine("parse completed.");
            var convert = Convert(sexpr);
            return convert.First();
        }

        private List<IParseTree> Convert(IParseTree tree)
        {
            var result = this.VisitSexpr(tree as sexpressionParser.SexprContext);
            return result;
        }

        public override List<IParseTree> VisitSexpr([NotNull] sexpressionParser.SexprContext context)
        {
            var items = context.item();
            var result = new List<IParseTree>();
            if (items == null) return result;
            foreach (var i in items)
            {
                var r = VisitItem(i);
                if (r.Count > 1) throw new Exception("Not returning single parse tree node.");
                if (r.Count == 1) result.Add(r.First());
            }
            return result;
        }

        public override List<IParseTree> VisitItem([NotNull] sexpressionParser.ItemContext context)
        {
            if (context.atom() != null)
            {
                // What *type* of token to use??? There is not enough information in the s-expression
                // to know what lexer type to use!!!
                // Run lexer on a bare string and see what we get.
                var str = context.atom().GetText();
                var stream = new AntlrInputStream(str);
                _lexer.SetInputStream(stream);
                var token = _lexer.NextToken();
                var new_sym = new TerminalNodeImpl(token);
                return new List<IParseTree>() { new_sym };
            }
            else if (context.list() != null)
            {
                return VisitList(context.list());
            }
            else throw new Exception("Cannot build an s-expr pair.");
        }
        
        public override List<IParseTree> VisitList([NotNull] sexpressionParser.ListContext context)
        {
            var items = context.item();
            if (items.Length == 0) throw new Exception("Does not look like a toStringTree(names) s-expr.");
            var id = items[0];
            var id_name = id.GetText().ToLower() + "context";
            var pt = _parser.GetType();
            var list = pt.GetTypeInfo().DeclaredNestedTypes.Where(t => t.Name.ToLower() == id_name);
            if (list.Count() != 1)
            {
                throw new Exception();
            }
            TypeInfo mapped_type = list.First();
            var mapped_node = Activator.CreateInstance(mapped_type, new object[] { null, 0 }) as IParseTree;
            for (int i = 2; i < context.children.Count - 1; ++i)
            {
                // Start at second "item" and end at last "item". The first item is the node
                // type, which was created above. The first and last children are parentheses.
                var c = context.children[i];
                var mcl = VisitItem(c as sexpressionParser.ItemContext);
                var mc = mcl.First();
                if (mc is TerminalNodeImpl)
                {
                    var _mc = mc as TerminalNodeImpl;
                    var _mapped_node = mapped_node as ParserRuleContext;
                    _mc.Parent = _mapped_node;
                    _mapped_node.AddChild(_mc);
                }
                else
                {
                    var _mc = mc as ParserRuleContext;
                    var _mapped_node = mapped_node as ParserRuleContext;
                    _mc.Parent = _mapped_node;
                    _mapped_node.AddChild(_mc);
                }
            }
            return new List<IParseTree>() { mapped_node };
        }

    }
}
