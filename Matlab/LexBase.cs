using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime;
using DFA = Antlr4.Runtime.Dfa.DFA;
using System.Collections.Generic;
using System.IO;
using System.Reflection.Metadata;
using System.Text;
using System;

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

        public matlabParser Parser { get; set; }

        public bool CanBeTranspose()
        {
            IIntStream istr = this.InputStream;
            var cur = istr.LA(0);
            var m1 = istr.LA(-1);
            var m2 = istr.LA(-2);
            var m3 = istr.LA(-3);
            System.Console.WriteLine("m1 " + m1);
            System.Console.WriteLine("m2 " + m2);
            System.Console.WriteLine("m3 " + m3);
            var ctx = Parser.Context;

            while (ctx != null)
            {
                System.Console.WriteLine("c = " + ctx.GetType().Name);
                if (ctx is matlabParser.Unary_expressionContext)
                    return true;
                ctx = ctx.Parent as ParserRuleContext;
            }
            return false;
        }

    }
}
