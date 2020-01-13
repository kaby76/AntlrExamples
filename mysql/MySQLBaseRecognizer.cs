using Antlr4.Runtime;
using System;
using System.IO;

namespace mysql
{
    public abstract class MySQLBaseRecognizer : Parser
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
        public SqlMode sqlMode; // A collection of flags indicating which of relevant SQL modes are active.

        public MySQLBaseRecognizer(ITokenStream input, TextWriter output, TextWriter errorOutput)
            : base(input, output, errorOutput)
        { }


        public bool isSqlModeActive(SqlMode mode)
        {
            return (sqlMode & mode) != 0;
        }

        public void sqlModeFromString(string modes)
        {
            sqlMode = SqlMode.NoMode;
            modes = modes.ToUpper();
            string mode;
            var split = modes.Split(',');
            foreach (var s in split)
            {
                mode = s.Trim();
                if (mode == "ANSI" || mode == "DB2" || mode == "MAXDB" || mode == "MSSQL" || mode == "ORACLE" ||
                    mode == "POSTGRESQL")
                    sqlMode = (sqlMode | SqlMode.AnsiQuotes | SqlMode.PipesAsConcat | SqlMode.IgnoreSpace);
                else if (mode == "ANSI_QUOTES")
                    sqlMode = (sqlMode | SqlMode.AnsiQuotes);
                else if (mode == "PIPES_AS_CONCAT")
                    sqlMode = (sqlMode | SqlMode.PipesAsConcat);
                else if (mode == "NO_BACKSLASH_ESCAPES")
                    sqlMode = (sqlMode | SqlMode.NoBackslashEscapes);
                else if (mode == "IGNORE_SPACE")
                    sqlMode = (sqlMode | SqlMode.IgnoreSpace);
                else if (mode == "HIGH_NOT_PRECEDENCE" || mode == "MYSQL323" || mode == "MYSQL40")
                    sqlMode = (sqlMode | SqlMode.HighNotPrecedence);
            }
        }
    }
}
