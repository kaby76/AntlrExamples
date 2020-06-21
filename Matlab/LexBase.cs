using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime;
using DFA = Antlr4.Runtime.Dfa.DFA;
using System.Collections.Generic;
using System.IO;
using System.Reflection.Metadata;
using System.Text;
using System;
using System.Reflection;

namespace Matlab
{
    public abstract class LexBase : Lexer
    {
        protected LexBase(ICharStream input) : base(input)
        {
        }

        protected LexBase(ICharStream input, TextWriter output, TextWriter errorOutput) : base(input, output, errorOutput)
        {
        }

        public Parser Parser { get; set; }
        
        public CommonTokenStream RealTokenStream { get; set; }

        public bool CheckQuote(string what_rule)
        {
            var lexer_state = this.State;
            var parser_state = Parser.State;
            var ts = this.RealTokenStream;
            //System.Console.WriteLine("Rule " + what_rule);
            //System.Console.WriteLine("lexer state " + lexer_state);
            //System.Console.WriteLine("parser state " + parser_state);
            //System.Console.Write("prior tokens: ");
            //for (int i = magic; i > 0; --i)
            //{
            //    try
            //    {
            //        IToken cur = ts.LT(-i);
            //        if (cur != null)
            //            System.Console.WriteLine(cur.ToString());
            //    }
            //    catch
            //    {
            //    }
            //}
            IToken last = ts.LT(-1);
            var stop = last.StopIndex;
            CommonToken last_ct = last as CommonToken;
            var s2 = last_ct.InputStream.Index;
            IIntStream istr = this.InputStream;
            var num_chars = s2 - stop - 1;
            //System.Console.Write("prior characters to last token: ");
            //for (int i = num_chars; i > 0; --i)
            //{
            //    try
            //    {
            //        var cur = istr.LA(-i);
            //        if (cur > 0)
            //            System.Console.Write((char) cur);
            //    }
            //    catch
            //    {
            //    }
            //}

            //System.Console.WriteLine();
            //System.Console.WriteLine("Parser context:");
            //var ctx = Parser.Context;
            //while (ctx != null)
            //{
            //    System.Console.WriteLine("c = " + ctx.GetType().Name);
            //    ctx = ctx.Parent as ParserRuleContext;
            //}

            // Heuristic decision making.
            bool result = false;
            int quote_count = 0;
            int last_quote = 0;
            for (int i = 0; i < num_chars; ++i)
            {
                try
                {
                    var cur = istr.LA(-i);
                    if (cur > 0)
                    {
                        if (cur == (int) '\'')
                        {
                            quote_count++;
                            last_quote = i;
                        }
                    }
                }
                catch
                {
                }
            }

            bool is_operator = true;
            for (int i = last_quote; i < num_chars; ++i)
            {
                try
                {
                    var cur = istr.LA(-i);
                    if (cur > 0)
                    {
                        var c = (char) cur;
                        if (i == last_quote && c == '\'')
                            ;
                        else if (c == ' ' || c == '\t')
                            ;
                        else if (Char.IsLetterOrDigit(c))
                        {
                            is_operator = true;
                            break;
                        }
                        else
                        {
                            is_operator = false;
                            break;
                        }
                    }
                }
                catch
                {
                }
            }

            if (what_rule == "SQ")
            {
                result = quote_count ==1 && is_operator;
                //System.Console.WriteLine(result ? ("yes, it's a " + what_rule + " operator.") : ("no, it's not a " + what_rule + " operator."));
            }
            else
            {
                result = (quote_count > 1 && !is_operator);
                //System.Console.WriteLine(result ? ("yes, it's a " + what_rule) : ("no, it's not a " + what_rule));
            }
            //System.Console.WriteLine();
            return result;
        }
    }
}
