using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Antlr4.Runtime;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;

namespace Java
{
#pragma warning disable CA1012 // Abstract types should not have constructors
	public abstract class LexerAdaptor : Lexer
#pragma warning restore CA1012 // But Lexer demands it - old 
	{
		// I copy a reference to the stream, so It can be used as a Char Stream, not as a IISStream
		readonly ICharStream stream;

		public Java9Parser Parser { get; set; }

		protected LexerAdaptor(ICharStream input, TextWriter output, TextWriter errorOutput)
			 : base(input, output, errorOutput)
		{
			stream = input;
		}

		public class Character
		{
			public static bool isJavaIdentifierPart(int c)
			{
				if (Char.IsLetter((char)c))
					return true;
				else if (c == (int)'$')
					return true;
				else if (c == (int)'_')
					return true;
				else if (Char.IsDigit((char)c))
					return true;
				else if (Char.IsNumber((char)c))
					return true;
				return false;
			}

			public static bool isJavaIdentifierStart(int c)
			{
				if (Char.IsLetter((char)c))
					return true;
				else if (c == (int)'$')
					return true;
				else if (c == (int)'_')
					return true;
				return false;
			}

			public static int toCodePoint(int high, int low)
			{
				return Char.ConvertToUtf32((char)high, (char)low);
			}
		}

		public bool SpecialContext()
		{
			RuleContext context = Parser.Context;
			string text = this.Text;
			while (context != null)
			{
				var type = context.GetType();
				if (Parser.Context is Java9Parser.CompilationUnitContext)
					return true;
				if (context is Java9Parser.ModuleDeclarationContext)
					return true;
				if (context is Java9Parser.ModuleDirectiveContext)
					return true;
				if (context is Java9Parser.PackageNameContext)
				{
					if (text == "to")
					{
						// Scan back for a ".".
						for (int i = 3; ; ++i)
						{
							var c = this.InputStream.LA(-i);
							if (c == '.')
								return false;
							if (!(c == ' ' || c == '\t' || c == '\r' || c == '\n'))
								return true;
						}
						return true;
					}
					return false;
				}
				if (context is Java9Parser.PackageDeclarationContext)
					return false;
				if (context is Java9Parser.ImportDeclarationContext)
					return false;
				context = context.Parent;
			}
			return false;
		}
	}
}

