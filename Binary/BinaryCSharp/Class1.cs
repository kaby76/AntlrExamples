using System;
using System.Collections.Generic;
using System.Text;
using Antlr4.Runtime.Misc;

namespace Binary
{
    public class Class1 : BinaryBaseListener
    {
        private bool changed = false;

        public override void ExitParExpr(BinaryParser.ParExprContext ctx)
        {
            var input = ctx.Start.InputStream;

            if (!changed)
            {
                int a = ctx.Start.StartIndex;
                int b = ctx.Stop.StopIndex;

                var interval = new Interval(a, b);
                var branch = input.GetText(interval);

                // Simplifying value in "branch"
                // If "branch" value changes, make "changed" variable true
            }

            System.Console.WriteLine("Start "
            + ctx.Start.StartIndex
            + " Stop "
            + ctx.Stop.StopIndex
            + " "
            + input.GetText(new Interval(ctx.Start.StartIndex, ctx.Stop.StopIndex)));

        }
    }
}
