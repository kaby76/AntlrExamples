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
    }
}

