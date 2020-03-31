namespace Flex
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Misc;

    public abstract class LexerAdaptor : Lexer
    {
        private readonly ICharStream _input;
        protected int percent_percent_count;

        public LexerAdaptor(
                    Antlr4.Runtime.ICharStream input,
                    System.IO.TextWriter output,
                    System.IO.TextWriter errorOutput)
                : base(input, output, errorOutput)
        {
            _input = input;
        }

        /**
			 * Track whether we are inside of a rule and whether it is lexical parser. _currentRuleType==Token.INVALID_TYPE
			 * means that we are outside of a rule. At the first sign of a rule name reference and _currentRuleType==invalid, we
			 * can assume that we are starting a parser rule. Similarly, seeing a token reference when not already in rule means
			 * starting a token rule. The terminating ';' of a rule, flips this back to invalid type.
			 *
			 * This is not perfect logic but works. For example, "grammar T;" means that we start and stop a lexical rule for
			 * the "T;". Dangerous but works.
			 *
			 * The whole point of this state information is to distinguish between [..arg actions..] and [charsets]. Char sets
			 * can only occur in lexical rules and arg actions cannot occur.
			 */
        private int _currentRuleType = TokenConstants.InvalidType;

        public int getCurrentRuleType()
        {
            return _currentRuleType;
        }

        public void setCurrentRuleType(int ruleType)
        {
            _currentRuleType = ruleType;
        }

        protected void handleEndAction()
        {
        }

        public void BEGIN(int type)
        { }

        public void FLEX_EXIT(int ret)
        { }

        public void ACTION_ECHO()
        { }

        public void RETURNCHAR()
        { }

        public void sf_set_case_ins(int v)
        { }

        public void sf_set_skip_ws(int v)
        { }

        public void sf_set_dot_all(int v)
        { }

        public void yy_pop_state()
        { }


        public int linenum;

        public string yytext;

        public void add_action(string v)
        { }

        public void RETURNNAME()
        { }

        public void START_CODEBLOCK(bool v)
        { }

        public bool yytext_is_array;

        public void yy_push_state(int v)
        { }

        public int sectnum;

        public void mark_defs1()
        { }

        public void line_directive_out(string a, int b)
        { }

        public void format_synerr(string f)
        { }


        public static int bracelevel, didadef, indented_code;
        public static bool doing_rule_action = false;
        public static int option_sense;
        public bool doing_codeblock = false;
        public int brace_depth = 0, brace_start_line = 0;
        public const int MAXLINE = 100000;
        public char[] nmdef = new char[MAXLINE];

    }
}

