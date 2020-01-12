using Antlr4.Runtime;
using System;
using System.IO;

namespace mysql
{
    public class MySQLBaseRecognizer : Parser
    {
        public MySQLBaseRecognizer(ITokenStream input, TextWriter output, TextWriter errorOutput)
            : base(input, output, errorOutput)
        { }

        public override string[] RuleNames => throw new NotImplementedException();

        public override IVocabulary Vocabulary => throw new NotImplementedException();

        public override string GrammarFileName => throw new NotImplementedException();

        public bool isSqlModeActive(ulong mode)
        {
            throw new NotImplementedException();
        }

        public void sqlModeFromString(string modes)
        {
            throw new NotImplementedException();
        }
    }
}
