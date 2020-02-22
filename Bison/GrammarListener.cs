﻿using System;
using System.Collections.Generic;
using System.Text;
using System;
using System.Collections.Generic;
using System.IO;
using Antlr4.Runtime;
using Antlr4.Runtime.Misc;
using System.Linq;

namespace Bison
{
    public class GrammarListener : BisonParserBaseListener
    {
        public List<Tuple<string,List<List<string>>>> rules = new List<Tuple<string, List<List<string>>>>();
        private string lhs;
        private List<List<string>> rhs;

        public override void EnterRules(BisonParser.RulesContext context)
        {
            lhs = context.GetChild(0).GetText();
        }

        public override void EnterRhs1(BisonParser.Rhs1Context context)
        {
            rhs = new List<List<string>>();
            rhs.Add(new List<string>());
        }

        public override void ExitRhs1(BisonParser.Rhs1Context context)
        {
            rhs.Add(new List<string>());
        }

        public override void ExitRhs2(BisonParser.Rhs2Context context)
        {
            rhs.Add(new List<string>());
        }

        public override void ExitRhs(BisonParser.RhsContext context)
        {
            if (context.ChildCount >= 2)
            {
                var c = context.GetChild(1);
                if (c is BisonParser.SymbolContext)
                {
                    var sym = c.GetText();
                    rhs.Last().Add(sym);
                }
            }
        }

        public override void ExitRules(BisonParser.RulesContext context)
        {
            rhs.RemoveAt(rhs.Count-1);
            rules.Add(new Tuple<string, List<List<string>>>(lhs, rhs));
        }
    }
}
