using Antlr4.Runtime;
using System.IO;

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
