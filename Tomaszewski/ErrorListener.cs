﻿// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace Tomaszewski
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Misc;
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;

    public class ErrorListener<S> : ConsoleErrorListener<S>
    {
        public bool had_error;
        private readonly Parser _parser;
        private readonly Lexer _lexer;
        private readonly CommonTokenStream _token_stream;
        private bool _first_time;

        public ErrorListener(Parser parser, Lexer lexer, CommonTokenStream token_stream)
        {
            _parser = parser;
            _lexer = lexer;
            _token_stream = token_stream;
            _first_time = true;
        }

        public override void SyntaxError(TextWriter output, IRecognizer recognizer, S offendingSymbol, int line,
            int col, string msg, RecognitionException e)
        {
            had_error = true;
            base.SyntaxError(output, recognizer, offendingSymbol, line, col, msg, e);
        }
    }
}