using System;
using System.Collections.Generic;

namespace mysql
{
    public class MySQLSymbolInfo
    {

        public enum MySQLVersion
        {
            Unknown,
            MySQL56,
            MySQL57,
            MySQL80,
        };

        public static HashSet<string> systemFunctionsForVersion(MySQLVersion version)
        {
            throw new Exception();
        }

        public static HashSet<string> keywordsForVersion(MySQLVersion version)
        {
            throw new Exception();
        }

        public static bool isReservedKeyword(string identifier, MySQLVersion version)
        {
            throw new Exception();
        }

        public static bool isKeyword(string identifier, MySQLVersion version)
        {
            throw new Exception();
        }

        public static MySQLVersion numberToVersion(long version)
        {
            throw new Exception();
        }
    }
}
