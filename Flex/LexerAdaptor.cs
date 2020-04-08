namespace Flex
{
    using Antlr4.Runtime;

    public abstract class LexerAdaptor : Lexer
    {
        public const int MAXLINE = 100000;
        public static int bracelevel;
        public static bool didadef;
        public static bool doing_rule_action = false;
        public static bool indented_code;
        public static bool option_sense;
        public int _sf_top_ix;
        public bool backing_up_report;
        public bool bison_bridge_lloc;
        public bool bison_bridge_lval;
        public int brace_depth = 0, brace_start_line = 0;
        public bool C_plus_plus;
        public int cclreuse;
        public int cclval;
        public bool continued_action;
        public int csize;
        public bool ddebug;
        public bool do_stdinit;
        public bool do_yylineno;
        public bool do_yywrap;
        public bool doing_codeblock = false;
        public bool fullspd;
        public bool fulltbl;
        public bool gen_line_dirs;
        public bool in_rule;
        public string infilename = "";
        public bool interactive;
        public int lastccl;
        public bool lex_compat;
        public int linenum;
        public bool long_align;
        public string nmdef = "";
        public string nmstr = "";
        public bool no_section3_escape;
        public bool nowarn;
        public int performance_report;
        public bool posix_compat;
        public bool printstats;
        public bool reentrant;
        public bool reject_really_used;
        public int sectnum;
        public bool spprdflt;
        public bool tablesext;
        public bool tablesverify;
        public bool trlcontxt;
        public bool use_read;
        public bool use_stdout;
        public bool useecs;
        public bool usemecs;
        public int YY_START;
        public int yyleng;
        public int yylval;
        public bool yymore_really_used;
        public string yytext = "";
        public bool yytext_is_array;
        protected int percent_percent_count;
        private readonly ICharStream _input;
        private int _currentRuleType = TokenConstants.InvalidType;

        public LexerAdaptor(
                            Antlr4.Runtime.ICharStream input,
                    System.IO.TextWriter output,
                    System.IO.TextWriter errorOutput)
                : base(input, output, errorOutput)
        {
            _input = input;
            PushMode(FlexLexer.INITIAL);
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
        public void ACTION_ECHO()
        { }

        public void ACTION_ECHO_QEND()
        {
        }

        public void ACTION_ECHO_QSTART()
        {
        }

        public void ACTION_IFDEF(string s, bool b)
        {
        }

        public void ACTION_M4_IFDEF(string s, bool b)
        {
        }

        public void add_action(string v)
        { }

        public void BEGIN(int type)
        {
            PushMode(type);
        }

        public void cclinstal(string s, int i)
        {
        }

        public int ccllookup(string s)
        {
            return 0;
        }

        public void ECHO()
        {
        }

        public void END_CODEBLOCK()
        {
        }

        public void FLEX_EXIT(int ret)
        { }

        public void format_synerr(string f)
        { }

        public void free(string s)
        {
        }

        public int getCurrentRuleType()
        {
            return _currentRuleType;
        }

        public char input()
        {
            return ' ';
        }

        public void line_directive_out(string a, int b)
        { }

        public void mark_defs1()
        { }

        public void mark_prolog()
        {
        }

        public int myctoi(string s)
        {
            return 0;
        }

        public int myesc(string s)
        {
            return 0;
        }

        public void ndinstal(string a, string b)
        {
        }

        public string ndlookup(string s)
        {
            return s;
        }

        public void outn(string s)
        {
        }

        public void PUT_BACK_STRING(string s, int i)
        {
        }

        public void RETURNCHAR()
        { }

        public void RETURNNAME()
        { }

        public void setCurrentRuleType(int ruleType)
        {
            _currentRuleType = ruleType;
        }

        public void sf_pop()
        {
        }

        public void sf_push()
        {
        }

        public void sf_set_case_ins(bool v)
        { }

        public void sf_set_dot_all(bool v)
        { }

        public void sf_set_skip_ws(bool v)
        { }

        public bool sf_skip_ws()
        {
            return false;
        }

        public void START_CODEBLOCK(bool x)
        {
            /* Emit the needed line directive... */
            if (indented_code == false)
            {
                linenum++;
                line_directive_out(null, 1);
            }
            add_action("[[");
            yy_push_state(FlexLexer.CODEBLOCK);
            indented_code = x;
            if (indented_code) ACTION_ECHO();
        }

        public int strlen(string s)
        {
            return 0;
        }

        public void strncpy(string s1, string s2, int n)
        {
        }

        public void synerr(string s)
        {
        }

        public void unput(char c)
        {
        }

        public string xstrdup(string s)
        {
            return s;
        }

        public void yy_pop_state()
        {
            PopMode();
        }

        public void yy_push_state(int v)
        {
            PushMode(v);
        }

        public void yy_set_bol(int i)
        {
        }

        public void yyless(int i)
        {
        }

        public void yyterminate()
        {
        }

        protected void handleEndAction()
        {
        }
    }
}