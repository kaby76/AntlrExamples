namespace fluent
{
	using System;
	using System.Reflection;
	using System.IO;
	using Antlr4.Runtime;
	using Antlr4.Runtime.Misc;

#pragma warning disable CA1012 // Abstract types should not have constructors
	public abstract class LexAdapt : Lexer
#pragma warning restore CA1012 // But Lexer demands it - old 
	{
		ICharStream _input;

		protected LexAdapt(ICharStream input)
			: base(input, Console.Out, Console.Error)
		{
			_input = input;
		}
		protected LexAdapt(ICharStream input, TextWriter output, TextWriter errorOutput)
			: base(input, output, errorOutput)
		{
			_input = input;
		}


	}

}
