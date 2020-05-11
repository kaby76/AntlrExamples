using System;
using System.Collections.Generic;
using System.Text;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Antlr4.Runtime;
using Antlr4.Runtime.Misc;

namespace Java
{
    public abstract class ParserAdaptor : Parser
    {
        public ParserAdaptor(ITokenStream input, TextWriter output, TextWriter errorOutput)
            : base(input, output, errorOutput)
        { }

        public Java9Lexer Lexer { get; set; }
 }
}
