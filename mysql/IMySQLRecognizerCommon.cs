namespace mysql
{
	interface IMySQLRecognizerCommon
	{
		// For parameterizing the parsing process.
		long serverVersion { get; set; }
		SqlMode sqlMode { get; set; } // A collection of flags indicating which of relevant SQL modes are active.

		// Returns true if the given mode (one of the enums above) is set.
		bool isSqlModeActive(SqlMode mode);
		void sqlModeFromString(string modes);
	}
}
