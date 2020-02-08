using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Antlr4.Runtime;

namespace a
{
    public abstract class BaseLexer : Lexer
    {
	    public int times;
	    bool _allow_b = false;
	    public bool allow_b {
		    get { times++; return _allow_b; }
		    set { _allow_b = value; }
	    }

        protected BaseLexer(ICharStream input) : base(input)
        {
        }

        protected BaseLexer(ICharStream input, TextWriter output, TextWriter errorOutput) : base(input, output, errorOutput)
        {
        }
    }
}
