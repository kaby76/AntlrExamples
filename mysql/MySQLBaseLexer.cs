using Antlr4.Runtime;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Antlr4.Runtime.Atn;

namespace mysql
{
    public class MySQLBaseLexer : Lexer
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

        // For parameterizing the parsing process.
        long serverVersion;
        SqlMode sqlMode; // A collection of flags indicating which of relevant SQL modes are active.
        HashSet<string> charsets; // Used to check repertoires.
        bool inVersionComment;
        List<IToken> _pendingTokens;
        Dictionary<string, uint> _symbols; // A list of all defined symbols for lookup.

        public override string[] RuleNames => throw new NotImplementedException();

        public override IVocabulary Vocabulary => throw new NotImplementedException();

        public override string GrammarFileName => throw new NotImplementedException();

        public bool isSqlModeActive(SqlMode mode)
        {
            throw new NotImplementedException();
        }

        public void sqlModeFromString(string modes)
        {
            throw new NotImplementedException();
        }

        public MySQLBaseLexer(ICharStream input, TextWriter output, TextWriter errorOutput)
            : base(input, output, errorOutput)
        {
            serverVersion = 0;
            sqlMode = SqlMode.NoMode;
            inVersionComment = false;
        }


        public override void Reset()
        {
            inVersionComment = false;
            base.Reset();
        }

        /**
         * Returns true if the given token is an identifier. This includes all those keywords that are
         * allowed as identifiers when unquoted (non-reserved keywords).
         */
        bool isIdentifier(int type)
        {
            if ((type == MySQLLexer.IDENTIFIER) || (type == MySQLLexer.ACK_TICK_QUOTED_ID))
                return true;

            // Double quoted text represents identifiers only if the ANSI QUOTES sql mode is active.
            if (((sqlMode & SqlMode.AnsiQuotes) != 0) && (type == MySQLLexer.DOUBLE_QUOTED_TEXT))
                return true;

            string symbol = Vocabulary.GetSymbolicName(type);
            if (!string.IsNullOrEmpty(symbol) && !MySQLSymbolInfo.isReservedKeyword(symbol, MySQLSymbolInfo.numberToVersion(serverVersion)))
                return true;

            return false;
        }

        uint keywordFromText(string name)
        {
            // (My)SQL only uses ASCII chars for keywords so we can do a simple downcase here for comparison.
            string transformed;
            transformed = name.ToLower();

            if (!MySQLSymbolInfo.isKeyword(transformed, MySQLSymbolInfo.numberToVersion(serverVersion)))
                return INVALID_INDEX - 1; // INVALID_INDEX alone can be interpreted as EOF.

            // Generate string -> enum value map, if not yet done.
            if (! _symbols.Any())
            {
                var vocabulary = this.Vocabulary;
                uint max = vocabulary.getMaxTokenType();
                for (uint i = 0; i <= max; ++i)
                    _symbols[vocabulary.getSymbolicName(i)] = i;
            }

            // Here we know for sure we got a keyword.
            var symbol = _symbols.find(transformed);
            if (symbol == _symbols.end())
                return INVALID_INDEX - 1;
            return symbol->second;
        }


        /**
         *  Helper for the query type determination.
         */
        IToken nextDefaultChannelToken()
    {
        do
        {
            IToken token = nextToken();
            if (token.Channel == ParserToken::DEFAULT_CHANNEL)
                return token;
        } while (true);
    }


        /**
         *  Skips over a definer clause if possible. Returns true if it was successful and points to the
         *  token after the last definer part.
         *  On entry the DEFINER symbol has been already consumed.
         *  If the syntax is wrong false is returned and the token source state is undetermined.
         */
        bool skipDefiner(ref IToken token)
    {
        token = nextDefaultChannelToken();
        if (token.Type != MySQLLexer.EQUAL_OPERATOR)
            return false;

        token = nextDefaultChannelToken();
        if (token.Type == MySQLLexer.CURRENT_USER_SYMBOL)
        {
            token = nextDefaultChannelToken();
            if (token.Type == MySQLLexer.OPEN_PAR_SYMBOL)
            {
                token = nextDefaultChannelToken();
                if (token.Type != MySQLLexer.CLOSE_PAR_SYMBOL)
                    return false;
                token = nextDefaultChannelToken();
                if (token.Type == TokenConstants.EOF)
                    return false;
            }
            return true;
        }

        if (token.Type == MySQLLexer.SINGLE_QUOTED_TEXT || isIdentifier(token.Type))
        {
            // First part of the user definition (mandatory).
            token = nextDefaultChannelToken();
            if (token.Type == MySQLLexer.AT_SIGN_SYMBOL || token.Type == MySQLLexer.AT_TEXT_SUFFIX)
            {
                // Second part of the user definition (optional).
                bool needIdentifier = token.Type == MySQLLexer.AT_SIGN_SYMBOL;
                token = nextDefaultChannelToken();
                if (needIdentifier)
                {
                    if (!isIdentifier(token.Type) && token.Type != MySQLLexer.SINGLE_QUOTED_TEXT)
                        return false;
                    token = nextDefaultChannelToken();
                    if (token.Type == TokenConstants.EOF)
                        return false;
                }
            }

            return true;
        }

        return false;
    }

        MySQLQueryType determineQueryType()
        {
            IToken token = nextDefaultChannelToken();
            if (token.Type == TokenConstants.EOF)
                return MySQLQueryType.QtUnknown;

            switch (token.Type)
            {
                case MySQLLexer.ALTER_SYMBOL:
                    token = nextDefaultChannelToken();
                    if (token.Type == TokenConstants.EOF)
                        return MySQLQueryType.QtAmbiguous;

                    switch (token.Type)
                    {
                        case MySQLLexer.DATABASE_SYMBOL:
                            return MySQLQueryType.QtAlterDatabase;

                        case MySQLLexer.LOGFILE_SYMBOL:
                            return MySQLQueryType.QtAlterLogFileGroup;

                        case MySQLLexer.FUNCTION_SYMBOL:
                            return MySQLQueryType.QtAlterFunction;

                        case MySQLLexer.PROCEDURE_SYMBOL:
                            return MySQLQueryType.QtAlterProcedure;

                        case MySQLLexer.SERVER_SYMBOL:
                            return MySQLQueryType.QtAlterServer;

                        case MySQLLexer.TABLE_SYMBOL:
                        case MySQLLexer.ONLINE_SYMBOL:  // Optional part of ALTER TABLE.
                        case MySQLLexer.OFFLINE_SYMBOL: // ditto
                        case MySQLLexer.IGNORE_SYMBOL:
                            return MySQLQueryType.QtAlterTable;

                        case MySQLLexer.TABLESPACE_SYMBOL:
                            return MySQLQueryType.QtAlterTableSpace;

                        case MySQLLexer.EVENT_SYMBOL:
                            return MySQLQueryType.QtAlterEvent;

                        case MySQLLexer.VIEW_SYMBOL:
                            return MySQLQueryType.QtAlterView;

                        case MySQLLexer.DEFINER_SYMBOL: // Can be both event or view.
                            if (!skipDefiner(ref token))
                                return MySQLQueryType.QtAmbiguous;

                            switch (token.Type)
                            {
                                case MySQLLexer.EVENT_SYMBOL:
                                    return MySQLQueryType.QtAlterEvent;

                                case MySQLLexer.SQL_SYMBOL:
                                case MySQLLexer.VIEW_SYMBOL:
                                    return MySQLQueryType.QtAlterView;
                            }
                            break;

                        case MySQLLexer.ALGORITHM_SYMBOL: // Optional part of CREATE VIEW.
                            return MySQLQueryType.QtAlterView;

                        case MySQLLexer.USER_SYMBOL:
                            return MySQLQueryType.QtAlterUser;
                    }
                    break;

                case MySQLLexer.CREATE_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        switch (token.Type)
                        {
                            case MySQLLexer.TEMPORARY_SYMBOL: // Optional part of CREATE TABLE.
                            case MySQLLexer.TABLE_SYMBOL:
                                return MySQLQueryType.QtCreateTable;

                            case MySQLLexer.ONLINE_SYMBOL:
                            case MySQLLexer.OFFLINE_SYMBOL:
                            case MySQLLexer.INDEX_SYMBOL:
                            case MySQLLexer.UNIQUE_SYMBOL:
                            case MySQLLexer.FULLTEXT_SYMBOL:
                            case MySQLLexer.SPATIAL_SYMBOL:
                                return MySQLQueryType.QtCreateIndex;

                            case MySQLLexer.DATABASE_SYMBOL:
                                return MySQLQueryType.QtCreateDatabase;

                            case MySQLLexer.TRIGGER_SYMBOL:
                                return MySQLQueryType.QtCreateTrigger;

                            case MySQLLexer.DEFINER_SYMBOL: // Can be event, view, procedure, function, UDF, trigger.
                                {
                                    if (!skipDefiner(ref token))
                                        return MySQLQueryType.QtAmbiguous;

                                    switch (token.Type)
                                    {
                                        case MySQLLexer.EVENT_SYMBOL:
                                            return MySQLQueryType.QtCreateEvent;

                                        case MySQLLexer.VIEW_SYMBOL:
                                        case MySQLLexer.SQL_SYMBOL:
                                            return MySQLQueryType.QtCreateView;

                                        case MySQLLexer.PROCEDURE_SYMBOL:
                                            return MySQLQueryType.QtCreateProcedure;

                                        case MySQLLexer.FUNCTION_SYMBOL:
                                            {
                                                token = nextDefaultChannelToken();
                                                if (token.Type == TokenConstants.EOF)
                                                    return MySQLQueryType.QtAmbiguous;

                                                if (!isIdentifier(token.Type))
                                                    return MySQLQueryType.QtAmbiguous;

                                                token = nextDefaultChannelToken();
                                                if (token.Type == MySQLLexer.RETURNS_SYMBOL)
                                                    return MySQLQueryType.QtCreateUdf;

                                                return MySQLQueryType.QtCreateFunction;
                                            }

                                        case MySQLLexer.AGGREGATE_SYMBOL:
                                            return MySQLQueryType.QtCreateUdf;

                                        case MySQLLexer.TRIGGER_SYMBOL:
                                            return MySQLQueryType.QtCreateTrigger;
                                    }
                                }

                            case MySQLLexer.VIEW_SYMBOL:
                            case MySQLLexer.OR_SYMBOL:        // CREATE OR REPLACE ... VIEW
                            case MySQLLexer.ALGORITHM_SYMBOL: // CREATE ALGORITHM ... VIEW
                                return MySQLQueryType.QtCreateView;

                            case MySQLLexer.EVENT_SYMBOL:
                                return MySQLQueryType.QtCreateEvent;

                            case MySQLLexer.FUNCTION_SYMBOL:
                                return MySQLQueryType.QtCreateFunction;

                            case MySQLLexer.AGGREGATE_SYMBOL:
                                return MySQLQueryType.QtCreateUdf;

                            case MySQLLexer.PROCEDURE_SYMBOL:
                                return MySQLQueryType.QtCreateProcedure;

                            case MySQLLexer.LOGFILE_SYMBOL:
                                return MySQLQueryType.QtCreateLogFileGroup;

                            case MySQLLexer.SERVER_SYMBOL:
                                return MySQLQueryType.QtCreateServer;

                            case MySQLLexer.TABLESPACE_SYMBOL:
                                return MySQLQueryType.QtCreateTableSpace;

                            case MySQLLexer.USER_SYMBOL:
                                return MySQLQueryType.QtCreateUser;
                        }
                        break;
                    }

                case MySQLLexer.DROP_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        switch (token.Type)
                        {
                            case MySQLLexer.DATABASE_SYMBOL:
                                return MySQLQueryType.QtDropDatabase;

                            case MySQLLexer.EVENT_SYMBOL:
                                return MySQLQueryType.QtDropEvent;

                            case MySQLLexer.PROCEDURE_SYMBOL:
                                return MySQLQueryType.QtDropProcedure;

                            case MySQLLexer.FUNCTION_SYMBOL:
                                return MySQLQueryType.QtDropFunction;

                            case MySQLLexer.ONLINE_SYMBOL:
                            case MySQLLexer.OFFLINE_SYMBOL:
                            case MySQLLexer.INDEX_SYMBOL:
                                return MySQLQueryType.QtDropIndex;

                            case MySQLLexer.LOGFILE_SYMBOL:
                                return MySQLQueryType.QtDropLogfileGroup;

                            case MySQLLexer.SERVER_SYMBOL:
                                return MySQLQueryType.QtDropServer;

                            case MySQLLexer.TEMPORARY_SYMBOL:
                            case MySQLLexer.TABLE_SYMBOL:
                            case MySQLLexer.TABLES_SYMBOL:
                                return MySQLQueryType.QtDropTable;

                            case MySQLLexer.TABLESPACE_SYMBOL:
                                return MySQLQueryType.QtDropTablespace;

                            case MySQLLexer.TRIGGER_SYMBOL:
                                return MySQLQueryType.QtDropTrigger;

                            case MySQLLexer.VIEW_SYMBOL:
                                return MySQLQueryType.QtDropView;

                            case MySQLLexer.PREPARE_SYMBOL:
                                return MySQLQueryType.QtDeallocate;

                            case MySQLLexer.USER_SYMBOL:
                                return MySQLQueryType.QtDropUser;
                        }
                    }

                case MySQLLexer.TRUNCATE_SYMBOL:
                    return MySQLQueryType.QtTruncateTable;

                case MySQLLexer.CALL_SYMBOL:
                    return MySQLQueryType.QtCall;

                case MySQLLexer.DELETE_SYMBOL:
                    return MySQLQueryType.QtDelete;

                case MySQLLexer.DO_SYMBOL:
                    return MySQLQueryType.QtDo;

                case MySQLLexer.HANDLER_SYMBOL:
                    return MySQLQueryType.QtHandler;

                case MySQLLexer.INSERT_SYMBOL:
                    return MySQLQueryType.QtInsert;

                case MySQLLexer.LOAD_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        switch (token.Type)
                        {
                            case MySQLLexer.DATA_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtAmbiguous;

                                    if (token.Type == MySQLLexer.FROM_SYMBOL)
                                        return MySQLQueryType.QtLoadDataMaster;
                                    return MySQLQueryType.QtLoadData;
                                }
                            case MySQLLexer.XML_SYMBOL:
                                return MySQLQueryType.QtLoadXML;

                            case MySQLLexer.TABLE_SYMBOL:
                                return MySQLQueryType.QtLoadTableMaster;

                            case MySQLLexer.INDEX_SYMBOL:
                                return MySQLQueryType.QtLoadIndex;
                        }
                    }

                case MySQLLexer.REPLACE_SYMBOL:
                    return MySQLQueryType.QtReplace;

                case MySQLLexer.SELECT_SYMBOL:
                    return MySQLQueryType.QtSelect;

                case MySQLLexer.UPDATE_SYMBOL:
                    return MySQLQueryType.QtUpdate;

                case MySQLLexer.OPEN_PAR_SYMBOL: // Either (((select ..))) or (partition...)
                    {
                        while (token.Type == MySQLLexer.OPEN_PAR_SYMBOL)
                        {
                            token = nextDefaultChannelToken();
                            if (token.Type == TokenConstants.EOF)
                                return MySQLQueryType.QtAmbiguous;
                        }
                        if (token.Type == MySQLLexer.SELECT_SYMBOL)
                            return MySQLQueryType.QtSelect;
                        return MySQLQueryType.QtPartition;
                    }

                case MySQLLexer.PARTITION_SYMBOL:
                case MySQLLexer.PARTITIONS_SYMBOL:
                    return MySQLQueryType.QtPartition;

                case MySQLLexer.START_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        if (token.Type == MySQLLexer.TRANSACTION_SYMBOL)
                            return MySQLQueryType.QtStartTransaction;
                        return MySQLQueryType.QtStartSlave;
                    }

                case MySQLLexer.BEGIN_SYMBOL: // Begin directly at the start of the query must be a transaction start.
                    return MySQLQueryType.QtBeginWork;

                case MySQLLexer.COMMIT_SYMBOL:
                    return MySQLQueryType.QtCommit;

                case MySQLLexer.ROLLBACK_SYMBOL:
                    {
                        // We assume a transaction statement here unless we exactly know it's about a savepoint.
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtRollbackWork;
                        if (token.Type == MySQLLexer.WORK_SYMBOL)
                        {
                            token = nextDefaultChannelToken();
                            if (token.Type == TokenConstants.EOF)
                                return MySQLQueryType.QtRollbackWork;
                        }

                        if (token.Type == MySQLLexer.TO_SYMBOL)
                            return MySQLQueryType.QtRollbackSavepoint;
                        return MySQLQueryType.QtRollbackWork;
                    }

                case MySQLLexer.SET_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtSet;

                        switch (token.Type)
                        {
                            case MySQLLexer.PASSWORD_SYMBOL:
                                return MySQLQueryType.QtSetPassword;

                            case MySQLLexer.GLOBAL_SYMBOL:
                            case MySQLLexer.LOCAL_SYMBOL:
                            case MySQLLexer.SESSION_SYMBOL:
                                token = nextDefaultChannelToken();
                                if (token.Type == TokenConstants.EOF)
                                    return MySQLQueryType.QtSet;
                                break;

                            case MySQLLexer.IDENTIFIER:
                                {
                                    string text = token.Text;
                                    text = text.ToLower();
                                    if (text == "autocommit")
                                        return MySQLQueryType.QtSetAutoCommit;
                                    break;
                                }
                        }

                        if (token.Type == MySQLLexer.TRANSACTION_SYMBOL)
                            return MySQLQueryType.QtSetTransaction;
                        return MySQLQueryType.QtSet;
                    }

                case MySQLLexer.SAVEPOINT_SYMBOL:
                    return MySQLQueryType.QtSavepoint;

                case MySQLLexer.RELEASE_SYMBOL: // Release at the start of the query, obviously.
                    return MySQLQueryType.QtReleaseSavepoint;

                case MySQLLexer.LOCK_SYMBOL:
                    return MySQLQueryType.QtLock;

                case MySQLLexer.UNLOCK_SYMBOL:
                    return MySQLQueryType.QtUnlock;

                case MySQLLexer.XA_SYMBOL:
                    return MySQLQueryType.QtXA;

                case MySQLLexer.PURGE_SYMBOL:
                    return MySQLQueryType.QtPurge;

                case MySQLLexer.CHANGE_SYMBOL:
                    return MySQLQueryType.QtChangeMaster;

                case MySQLLexer.RESET_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtReset;

                        switch (token.Type)
                        {
                            case MySQLLexer.SERVER_SYMBOL:
                                return MySQLQueryType.QtResetMaster;
                            case MySQLLexer.SLAVE_SYMBOL:
                                return MySQLQueryType.QtResetSlave;
                            default:
                                return MySQLQueryType.QtReset;
                        }
                    }

                case MySQLLexer.STOP_SYMBOL:
                    return MySQLQueryType.QtStopSlave;

                case MySQLLexer.PREPARE_SYMBOL:
                    return MySQLQueryType.QtPrepare;

                case MySQLLexer.EXECUTE_SYMBOL:
                    return MySQLQueryType.QtExecute;

                case MySQLLexer.DEALLOCATE_SYMBOL:
                    return MySQLQueryType.QtDeallocate;

                case MySQLLexer.GRANT_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        if (token.Type == MySQLLexer.PROXY_SYMBOL)
                            return MySQLQueryType.QtGrantProxy;
                        return MySQLQueryType.QtGrant;
                    }

                case MySQLLexer.RENAME_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        if (token.Type == MySQLLexer.USER_SYMBOL)
                            return MySQLQueryType.QtRenameUser;
                        return MySQLQueryType.QtRenameTable;
                    }

                case MySQLLexer.REVOKE_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        if (token.Type == MySQLLexer.PROXY_SYMBOL)
                            return MySQLQueryType.QtRevokeProxy;
                        return MySQLQueryType.QtRevoke;
                    }

                case MySQLLexer.ANALYZE_SYMBOL:
                    return MySQLQueryType.QtAnalyzeTable;

                case MySQLLexer.CHECK_SYMBOL:
                    return MySQLQueryType.QtCheckTable;

                case MySQLLexer.CHECKSUM_SYMBOL:
                    return MySQLQueryType.QtChecksumTable;

                case MySQLLexer.OPTIMIZE_SYMBOL:
                    return MySQLQueryType.QtOptimizeTable;

                case MySQLLexer.REPAIR_SYMBOL:
                    return MySQLQueryType.QtRepairTable;

                case MySQLLexer.BACKUP_SYMBOL:
                    return MySQLQueryType.QtBackUpTable;

                case MySQLLexer.RESTORE_SYMBOL:
                    return MySQLQueryType.QtRestoreTable;

                case MySQLLexer.INSTALL_SYMBOL:
                    return MySQLQueryType.QtInstallPlugin;

                case MySQLLexer.UNINSTALL_SYMBOL:
                    return MySQLQueryType.QtUninstallPlugin;

                case MySQLLexer.SHOW_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtShow;

                        if (token.Type == MySQLLexer.FULL_SYMBOL)
                        {
                            // Not all SHOW cases allow an optional FULL keyword, but this is not about checking for
                            // a valid query but to find the most likely type.
                            token = nextDefaultChannelToken();
                            if (token.Type == TokenConstants.EOF)
                                return MySQLQueryType.QtShow;
                        }

                        switch (token.Type)
                        {
                            case MySQLLexer.GLOBAL_SYMBOL:
                            case MySQLLexer.LOCK_SYMBOL:
                            case MySQLLexer.SESSION_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtShow;

                                    if (token.Type == MySQLLexer.STATUS_SYMBOL)
                                        return MySQLQueryType.QtShowStatus;
                                    return MySQLQueryType.QtShowVariables;
                                }

                            case MySQLLexer.AUTHORS_SYMBOL:
                                return MySQLQueryType.QtShowAuthors;

                            case MySQLLexer.BINARY_SYMBOL:
                                return MySQLQueryType.QtShowBinaryLogs;

                            case MySQLLexer.BINLOG_SYMBOL:
                                return MySQLQueryType.QtShowBinlogEvents;

                            case MySQLLexer.RELAYLOG_SYMBOL:
                                return MySQLQueryType.QtShowRelaylogEvents;

                            case MySQLLexer.CHAR_SYMBOL:
                                return MySQLQueryType.QtShowCharset;

                            case MySQLLexer.COLLATION_SYMBOL:
                                return MySQLQueryType.QtShowCollation;

                            case MySQLLexer.COLUMNS_SYMBOL:
                                return MySQLQueryType.QtShowColumns;

                            case MySQLLexer.CONTRIBUTORS_SYMBOL:
                                return MySQLQueryType.QtShowContributors;

                            case MySQLLexer.COUNT_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type != MySQLLexer.OPEN_PAR_SYMBOL)
                                        return MySQLQueryType.QtShow;
                                    token = nextDefaultChannelToken();
                                    if (token.Type != MySQLLexer.MULT_OPERATOR)
                                        return MySQLQueryType.QtShow;
                                    token = nextDefaultChannelToken();
                                    if (token.Type != MySQLLexer.CLOSE_PAR_SYMBOL)
                                        return MySQLQueryType.QtShow;

                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtShow;

                                    switch (token.Type)
                                    {
                                        case MySQLLexer.WARNINGS_SYMBOL:
                                            return MySQLQueryType.QtShowWarnings;

                                        case MySQLLexer.ERRORS_SYMBOL:
                                            return MySQLQueryType.QtShowErrors;
                                    }

                                    return MySQLQueryType.QtShow;
                                }

                            case MySQLLexer.CREATE_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtShow;

                                    switch (token.Type)
                                    {
                                        case MySQLLexer.DATABASE_SYMBOL:
                                            return MySQLQueryType.QtShowCreateDatabase;

                                        case MySQLLexer.EVENT_SYMBOL:
                                            return MySQLQueryType.QtShowCreateEvent;

                                        case MySQLLexer.FUNCTION_SYMBOL:
                                            return MySQLQueryType.QtShowCreateFunction;

                                        case MySQLLexer.PROCEDURE_SYMBOL:
                                            return MySQLQueryType.QtShowCreateProcedure;

                                        case MySQLLexer.TABLE_SYMBOL:
                                            return MySQLQueryType.QtShowCreateTable;

                                        case MySQLLexer.TRIGGER_SYMBOL:
                                            return MySQLQueryType.QtShowCreateTrigger;

                                        case MySQLLexer.VIEW_SYMBOL:
                                            return MySQLQueryType.QtShowCreateView;
                                    }

                                    return MySQLQueryType.QtShow;
                                }

                            case MySQLLexer.DATABASES_SYMBOL:
                                return MySQLQueryType.QtShowDatabases;

                            case MySQLLexer.ENGINE_SYMBOL:
                                return MySQLQueryType.QtShowEngineStatus;

                            case MySQLLexer.STORAGE_SYMBOL:
                            case MySQLLexer.ENGINES_SYMBOL:
                                return MySQLQueryType.QtShowStorageEngines;

                            case MySQLLexer.ERRORS_SYMBOL:
                                return MySQLQueryType.QtShowErrors;

                            case MySQLLexer.EVENTS_SYMBOL:
                                return MySQLQueryType.QtShowEvents;

                            case MySQLLexer.FUNCTION_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtAmbiguous;

                                    if (token.Type == MySQLLexer.CODE_SYMBOL)
                                        return MySQLQueryType.QtShowFunctionCode;
                                    return MySQLQueryType.QtShowFunctionStatus;
                                }

                            case MySQLLexer.GRANT_SYMBOL:
                                return MySQLQueryType.QtShowGrants;

                            case MySQLLexer.INDEX_SYMBOL:
                            case MySQLLexer.INDEXES_SYMBOL:
                            case MySQLLexer.KEY_SYMBOL:
                                return MySQLQueryType.QtShowIndexes;

                            case MySQLLexer.INNODB_SYMBOL:
                                return MySQLQueryType.QtShowInnoDBStatus;

                            case MySQLLexer.MASTER_SYMBOL:
                                return MySQLQueryType.QtShowMasterStatus;

                            case MySQLLexer.OPEN_SYMBOL:
                                return MySQLQueryType.QtShowOpenTables;

                            case MySQLLexer.PLUGIN_SYMBOL:
                            case MySQLLexer.PLUGINS_SYMBOL:
                                return MySQLQueryType.QtShowPlugins;

                            case MySQLLexer.PROCEDURE_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtShow;

                                    if (token.Type == MySQLLexer.STATUS_SYMBOL)
                                        return MySQLQueryType.QtShowProcedureStatus;
                                    return MySQLQueryType.QtShowProcedureCode;
                                }

                            case MySQLLexer.PRIVILEGES_SYMBOL:
                                return MySQLQueryType.QtShowPrivileges;

                            case MySQLLexer.PROCESSLIST_SYMBOL:
                                return MySQLQueryType.QtShowProcessList;

                            case MySQLLexer.PROFILE_SYMBOL:
                                return MySQLQueryType.QtShowProfile;

                            case MySQLLexer.PROFILES_SYMBOL:
                                return MySQLQueryType.QtShowProfiles;

                            case MySQLLexer.SLAVE_SYMBOL:
                                {
                                    token = nextDefaultChannelToken();
                                    if (token.Type == TokenConstants.EOF)
                                        return MySQLQueryType.QtAmbiguous;

                                    if (token.Type == MySQLLexer.HOSTS_SYMBOL)
                                        return MySQLQueryType.QtShowSlaveHosts;
                                    return MySQLQueryType.QtShowSlaveStatus;
                                }

                            case MySQLLexer.STATUS_SYMBOL:
                                return MySQLQueryType.QtShowStatus;

                            case MySQLLexer.VARIABLES_SYMBOL:
                                return MySQLQueryType.QtShowVariables;

                            case MySQLLexer.TABLE_SYMBOL:
                                return MySQLQueryType.QtShowTableStatus;

                            case MySQLLexer.TABLES_SYMBOL:
                                return MySQLQueryType.QtShowTables;

                            case MySQLLexer.TRIGGERS_SYMBOL:
                                return MySQLQueryType.QtShowTriggers;

                            case MySQLLexer.WARNINGS_SYMBOL:
                                return MySQLQueryType.QtShowWarnings;
                        }

                        return MySQLQueryType.QtShow;
                    }

                case MySQLLexer.CACHE_SYMBOL:
                    return MySQLQueryType.QtCacheIndex;

                case MySQLLexer.FLUSH_SYMBOL:
                    return MySQLQueryType.QtFlush;

                case MySQLLexer.KILL_SYMBOL:
                    return MySQLQueryType.QtKill;

                case MySQLLexer.DESCRIBE_SYMBOL: // EXPLAIN is converted to DESCRIBE in the lexer.
                case MySQLLexer.DESC_SYMBOL:
                    {
                        token = nextDefaultChannelToken();
                        if (token.Type == TokenConstants.EOF)
                            return MySQLQueryType.QtAmbiguous;

                        if (isIdentifier(token.Type) || token.Type == MySQLLexer.DOT_SYMBOL)
                            return MySQLQueryType.QtExplainTable;

                        // EXTENDED is a bit special as it can be both, a table identifier or the keyword.
                        if (token.Type == MySQLLexer.EXTENDED_SYMBOL)
                        {
                            token = nextDefaultChannelToken();
                            if (token.Type == TokenConstants.EOF)
                                return MySQLQueryType.QtExplainTable;

                            switch (token.Type)
                            {
                                case MySQLLexer.DELETE_SYMBOL:
                                case MySQLLexer.INSERT_SYMBOL:
                                case MySQLLexer.REPLACE_SYMBOL:
                                case MySQLLexer.UPDATE_SYMBOL:
                                    return MySQLQueryType.QtExplainStatement;
                                default:
                                    return MySQLQueryType.QtExplainTable;
                            }
                        }
                        return MySQLQueryType.QtExplainStatement;
                    }

                case MySQLLexer.HELP_SYMBOL:
                    return MySQLQueryType.QtHelp;

                case MySQLLexer.USE_SYMBOL:
                    return MySQLQueryType.QtUse;
            }

            return MySQLQueryType.QtUnknown;
        }

        bool isRelation(uint type)
        {
            switch (type)
            {
                case MySQLLexer.EQUAL_OPERATOR:
                case MySQLLexer.ASSIGN_OPERATOR:
                case MySQLLexer.NULL_SAFE_EQUAL_OPERATOR:
                case MySQLLexer.GREATER_OR_EQUAL_OPERATOR:
                case MySQLLexer.GREATER_THAN_OPERATOR:
                case MySQLLexer.LESS_OR_EQUAL_OPERATOR:
                case MySQLLexer.LESS_THAN_OPERATOR:
                case MySQLLexer.NOT_EQUAL_OPERATOR:
                case MySQLLexer.NOT_EQUAL2_OPERATOR:
                case MySQLLexer.PLUS_OPERATOR:
                case MySQLLexer.MINUS_OPERATOR:
                case MySQLLexer.MULT_OPERATOR:
                case MySQLLexer.DIV_OPERATOR:
                case MySQLLexer.MOD_OPERATOR:
                case MySQLLexer.LOGICAL_NOT_OPERATOR:
                case MySQLLexer.BITWISE_NOT_OPERATOR:
                case MySQLLexer.SHIFT_LEFT_OPERATOR:
                case MySQLLexer.SHIFT_RIGHT_OPERATOR:
                case MySQLLexer.LOGICAL_AND_OPERATOR:
                case MySQLLexer.BITWISE_AND_OPERATOR:
                case MySQLLexer.BITWISE_XOR_OPERATOR:
                case MySQLLexer.LOGICAL_OR_OPERATOR:
                case MySQLLexer.BITWISE_OR_OPERATOR:

                case MySQLLexer.OR_SYMBOL:
                case MySQLLexer.XOR_SYMBOL:
                case MySQLLexer.AND_SYMBOL:
                case MySQLLexer.IS_SYMBOL:
                case MySQLLexer.BETWEEN_SYMBOL:
                case MySQLLexer.LIKE_SYMBOL:
                case MySQLLexer.REGEXP_SYMBOL:
                case MySQLLexer.IN_SYMBOL:
                case MySQLLexer.SOUNDS_SYMBOL:
                case MySQLLexer.NOT_SYMBOL:
                    return true;

                default:
                    return false;
            }
        }


        bool isNumber(uint type)
        {
            switch (type)
            {
                case MySQLLexer.INT_NUMBER:
                case MySQLLexer.LONG_NUMBER:
                case MySQLLexer.ULONGLONG_NUMBER:
                case MySQLLexer.FLOAT_NUMBER:
                case MySQLLexer.HEX_NUMBER:
                case MySQLLexer.BIN_NUMBER:
                case MySQLLexer.DECIMAL_NUMBER:
                    return true;

                default:
                    return false;
            }
        }

        bool isOperator(int type)
        {
            switch (type)
            {
                case MySQLLexer.EQUAL_OPERATOR:
                case MySQLLexer.ASSIGN_OPERATOR:
                case MySQLLexer.NULL_SAFE_EQUAL_OPERATOR:
                case MySQLLexer.GREATER_OR_EQUAL_OPERATOR:
                case MySQLLexer.GREATER_THAN_OPERATOR:
                case MySQLLexer.LESS_OR_EQUAL_OPERATOR:
                case MySQLLexer.LESS_THAN_OPERATOR:
                case MySQLLexer.NOT_EQUAL_OPERATOR:
                case MySQLLexer.NOT_EQUAL2_OPERATOR:
                case MySQLLexer.PLUS_OPERATOR:
                case MySQLLexer.MINUS_OPERATOR:
                case MySQLLexer.MULT_OPERATOR:
                case MySQLLexer.DIV_OPERATOR:
                case MySQLLexer.MOD_OPERATOR:
                case MySQLLexer.LOGICAL_NOT_OPERATOR:
                case MySQLLexer.BITWISE_NOT_OPERATOR:
                case MySQLLexer.SHIFT_LEFT_OPERATOR:
                case MySQLLexer.SHIFT_RIGHT_OPERATOR:
                case MySQLLexer.LOGICAL_AND_OPERATOR:
                case MySQLLexer.BITWISE_AND_OPERATOR:
                case MySQLLexer.BITWISE_XOR_OPERATOR:
                case MySQLLexer.LOGICAL_OR_OPERATOR:
                case MySQLLexer.BITWISE_OR_OPERATOR:

                case MySQLLexer.DOT_SYMBOL:
                case MySQLLexer.COMMA_SYMBOL:
                case MySQLLexer.SEMICOLON_SYMBOL:
                case MySQLLexer.COLON_SYMBOL:
                case MySQLLexer.OPEN_PAR_SYMBOL:
                case MySQLLexer.CLOSE_PAR_SYMBOL:
                case MySQLLexer.AT_SIGN_SYMBOL:
                case MySQLLexer.AT_AT_SIGN_SYMBOL:
                case MySQLLexer.PARAM_MARKER:
                    return true;

                default:
                    return false;
            }
        }

        /**
         * Allow a grammar rule to emit as many tokens as it needs.
         */
        public override IToken NextToken()
        {
            // First respond with pending tokens to the next token request, if there are any.
            if (_pendingTokens.Any())
            {
                var pending = _pendingTokens.First();
                _pendingTokens.RemoveAt(0);
                return pending;
            }

            // Let the main lexer class run the next token recognition.
            // This might create additional tokens again.
            var next = base.NextToken();
            if (_pendingTokens.Any())
            {
                var pending = _pendingTokens.First();
                _pendingTokens.RemoveAt(0);
                _pendingTokens.Add(next);
                return pending;
            }
            return next;
        }

        bool checkVersion(string text)
        {
            if (text.Length < 8) // Minimum is: /*!12345
                return false;

            // Skip version comment introducer.
            long version = Int64.Parse(text.Substring(3));
            if (version <= serverVersion)
            {
                inVersionComment = true;
                return true;
            }
            return false;
        }


        int determineFunction(int proposed)
        {
            // Skip any whitespace character if the sql mode says they should be ignored,
            // before actually trying to match the open parenthesis.
            if (isSqlModeActive(SqlMode.IgnoreSpace))
            {
                var input = this.InputStream.LA(1);
                while (input == ' ' || input == '\t' || input == '\r' || input == '\n')
                {
                    this.Interpreter.Consume((ICharStream)this.InputStream);
                    this.Channel = HIDDEN;
                    this.Type = MySQLLexer.WHITESPACE;
                    input = this.InputStream.LA(1);
                }
            }

            return this.InputStream.LA(1) == '(' ? proposed : MySQLLexer.IDENTIFIER;
        }

        int determineNumericType(string text)
        {
            const string long_str = "2147483647";
            const uint long_len = 10;
            const string signed_long_str = "-2147483648";
            const string longlong_str = "9223372036854775807";
            const uint longlong_len = 19;
            const string signed_longlong_str = "-9223372036854775808";
            const uint signed_longlong_len = 19;
            const string unsigned_longlong_str = "18446744073709551615";
            const uint unsigned_longlong_len = 20;

            // The original code checks for leading +/- but actually that can never happen, neither in the
            // server parser (as a digit is used to trigger processing in the lexer) nor in our parser
            // as our rules are defined without signs. But we do it anyway for maximum compatibility.
            uint length = (uint)text.Length - 1;
            string str = text;
            if (length < long_len) // quick normal case
                return MySQLLexer.INT_NUMBER;
            uint negative = 0;
            int ptr = 0;
            if (str[ptr] == '+') // Remove sign and pre-zeros
            {
                ptr++;
                length--;
            }
            else if (str[ptr] == '-')
            {
                ptr++;
                length--;
                negative = 1;
            }

            while (str[ptr] == '0' && length != 0)
            {
                ptr++;
                length--;
            }

            if (length < long_len)
                return MySQLLexer.INT_NUMBER;

            uint smaller, bigger;
            const char* cmp;
            if (negative != 0)
            {
                if (length == long_len)
                {
                    cmp = signed_long_str + 1;
                    smaller = MySQLLexer.INT_NUMBER; // If <= signed_long_str
                    bigger = MySQLLexer.LONG_NUMBER; // If >= signed_long_str
                }
                else if (length < signed_longlong_len)
                    return MySQLLexer.LONG_NUMBER;
                else if (length > signed_longlong_len)
                    return MySQLLexer.DECIMAL_NUMBER;
                else
                {
                    cmp = signed_longlong_str + 1;
                    smaller = MySQLLexer.LONG_NUMBER; // If <= signed_longlong_str
                    bigger = MySQLLexer.DECIMAL_NUMBER;
                }
            }
            else
            {
                if (length == long_len)
                {
                    cmp = long_str;
                    smaller = MySQLLexer.INT_NUMBER;
                    bigger = MySQLLexer.LONG_NUMBER;
                }
                else if (length < longlong_len)
                    return MySQLLexer.LONG_NUMBER;
                else if (length > longlong_len)
                {
                    if (length > unsigned_longlong_len)
                        return MySQLLexer.DECIMAL_NUMBER;
                    cmp = unsigned_longlong_str;
                    smaller = MySQLLexer.ULONGLONG_NUMBER;
                    bigger = MySQLLexer.DECIMAL_NUMBER;
                }
                else
                {
                    cmp = longlong_str;
                    smaller = MySQLLexer.LONG_NUMBER;
                    bigger = MySQLLexer.ULONGLONG_NUMBER;
                }
            }

            while (*cmp && *cmp++ == *str++)
                ;

            return ((char)str[-1] <= (char)cmp[-1]) ? smaller: bigger;
        }

        uint checkCharset(string text)
        {
            return charsets.count(text) > 0 ? MySQLLexer.UNDERSCORE_CHARSET : MySQLLexer.IDENTIFIER;
        }

        /**
         * Puts a DOT token onto the pending token list.
         */
        void emitDot()
        {
            _pendingTokens.emplace_back(_factory->create({ this, _input}, MySQLLexer.DOT_SYMBOL, _text, channel,
                                                   tokenStartCharIndex, tokenStartCharIndex, tokenStartLine,
                                                   tokenStartCharPositionInLine));
            ++tokenStartCharIndex;
        }

    }
}
