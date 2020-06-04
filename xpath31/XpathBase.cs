namespace xpath
{
    using System;
    using System.Reflection;
    using System.IO;
    using Antlr4.Runtime;
    using Antlr4.Runtime.Misc;

    public abstract class XpathBase : Lexer
    {
        readonly ICharStream stream;
        readonly FieldInfo tokenInput = typeof(CommonToken).GetField("_type", BindingFlags.NonPublic | BindingFlags.Instance);
        protected XpathBase(ICharStream input)
             : base(input, Console.Out, Console.Error)
        {
            stream = input;
        }

        protected XpathBase(ICharStream input, TextWriter output, TextWriter errorOutput)
             : base(input, output, errorOutput)
        {
            stream = input;
        }

        protected bool NoNestingCommentCheck()
        {
            if (this.Text.Contains("(:") || this.Text.Contains(":)"))
                return false;
            return true;
        }
    }
}
