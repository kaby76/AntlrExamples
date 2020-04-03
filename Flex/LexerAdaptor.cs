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

        public void sf_set_case_ins(bool v)
        { }

        public void sf_set_skip_ws(bool v)
        { }

        public void sf_set_dot_all(bool v)
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


        public static int bracelevel;
        public static bool didadef;
        public static bool indented_code;
        public static bool doing_rule_action = false;
        public static bool option_sense;
        public bool doing_codeblock = false;
        public int brace_depth = 0, brace_start_line = 0;
        public const int MAXLINE = 100000;
        public string nmdef;
        public int csize;
        public bool interactive;
        public bool long_align;
        public bool backing_up_report;
        public bool bison_bridge_lval;
        public bool bison_bridge_lloc;
        public bool C_plus_plus;
        public bool lex_compat;
        public bool posix_compat;
        public bool ddebug;
        public bool spprdflt;
        public bool useecs;
        public bool usemecs;
        public bool use_read;
        public bool fullspd;
        public bool fulltbl;
        public bool gen_line_dirs;
        public bool do_yywrap;
        public int performance_report;
        public bool reentrant;
        public bool reject_really_used;
        public bool do_stdinit;
        public bool use_stdout;
        public bool printstats;
        public bool nowarn;
        public bool do_yylineno;
        public bool yymore_really_used;
        public bool tablesverify;
        public bool tablesext;
        public int yyleng;
        public string nmstr;
        public int yylval;
        public int cclval;
        public void synerr(string s) { }
        public int myesc(string s) { return 0; }

        public void strncpy(string s1, string s2, int n) { }
        public void ACTION_IFDEF(string s, bool b) { }
        public void ACTION_ECHO_QSTART() { }

        public void ACTION_ECHO_QEND() { }

        public int YY_START;

        public void END_CODEBLOCK() { }
        public void START_CODEBLOCK() { }

        public void ACTION_M4_IFDEF(string s, bool b) { }
        public void sf_pop() { }
        public void sf_push() { }
        public void yyless(int i) { }
        public int _sf_top_ix;
        public char input() { return ' '; }
        public int myctoi(string s) { return 0; }
        public void free(string s) { }
        public string infilename;
        public string xstrdup(string s) { return s; }
        public int strlen(string s) { return 0; }
        public void ndinstal(string a, string b) { }
        public void yy_set_bol(int i) { }
        public void mark_prolog() { }
        public void yyterminate() { }
        public bool sf_skip_ws() { return false; }
        public bool in_rule;
        public bool continued_action;
        public void unput(char c) { }
        public bool no_section3_escape;
        public void outn(string s) { }
        public int ccllookup(string s) { return 0; }
        public int cclreuse;
        public void cclinstal(string s, int i) { }
        public int lastccl;
        public void PUT_BACK_STRING(string s, int i) { }
        public bool trlcontxt;
        public string ndlookup(string s) { return s; }
    }
}

