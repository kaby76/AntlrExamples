using System;
using System.Collections.Generic;
using System.Text;
using System;
using System.IO;
using System.Text;
using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;

namespace mysql
{
    public class MySQLBaseLexer : Lexer, IMySQLRecognizerCommon
    {
        public MySQLBaseLexer(ICharStream input, TextWriter output, TextWriter errorOutput) 
            : base(input, output, errorOutput)
        { }

        public override string[] RuleNames => throw new NotImplementedException();

        public override IVocabulary Vocabulary => throw new NotImplementedException();

        public override string GrammarFileName => throw new NotImplementedException();
    }
}
