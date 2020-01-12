using Antlr4.Runtime;
using System;
using System.IO;

namespace mysql
{
    public class MySQLBaseRecognizer : Parser
    {
        public enum SqlMode
        {
            NoMode = 0,
            AnsiQuotes = 1 << 0,
            HighNotPrecedence = 1 << 1,
            PipesAsConcat = 1 << 2,
            IgnoreSpace = 1 << 3,
            NoBackslashEscapes = 1 << 4
        };
        public long serverVersion;

        public MySQLBaseRecognizer(ITokenStream input, TextWriter output, TextWriter errorOutput)
            : base(input, output, errorOutput)
        { }

        public override string[] RuleNames => throw new NotImplementedException();

        public override IVocabulary Vocabulary => throw new NotImplementedException();

        public override string GrammarFileName => throw new NotImplementedException();

        public bool isSqlModeActive(SqlMode mode)
        {
            throw new NotImplementedException();
        }

        public void sqlModeFromString(string modes)
        {
            throw new NotImplementedException();
        }
    }
}
