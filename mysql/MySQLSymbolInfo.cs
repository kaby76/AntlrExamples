namespace mysql
{
    using System;
    using System.Collections.Generic;

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

        private static Dictionary<MySQLVersion, HashSet<string>> keywords = new Dictionary<MySQLVersion, HashSet<string>>();
        private static Dictionary<MySQLVersion, HashSet<string>> reservedKeywords = new Dictionary<MySQLVersion, HashSet<string>>();

        public static HashSet<string> keywordsForVersion(MySQLVersion version)
        {
            if (!keywords.TryGetValue(version, out HashSet<string> value) || value.Count == 0)
            {
                HashSet<string> list = new HashSet<string>();
                HashSet<string> reservedList = new HashSet<string>();
                switch (version)
                {
                    case MySQLVersion.MySQL56:
                    {
                        foreach (var keyword in keyword_list56.data)
                        {
                            string word = keyword.Item1;
                            list.Add(word);
                            if (keyword.Item2 != 0)
                                reservedList.Add(word);
                        }

                        break;
                    }

                    case MySQLVersion.MySQL57:
                    {
                        foreach (var keyword in keyword_list57.data)
                        {
                            string word = keyword.Item1;
                            list.Add(word);
                            if (keyword.Item2 != 0)
                                reservedList.Add(word);
                        }

                        break;
                    }

                    case MySQLVersion.MySQL80:
                    {
                        foreach (var keyword in keyword_list80.data)
                        {
                            string word = keyword.Item1;
                            list.Add(word);
                            if (keyword.Item2 != 0)
                                reservedList.Add(word);
                        }

                        break;
                    }

                    default:
                        break;
                }

                keywords[version] = list;
            }
            return keywords[version];
        }

        public static bool isReservedKeyword(string identifier, MySQLVersion version)
        {
            bool found = reservedKeywords.TryGetValue(version, out HashSet<string> value);
            if (!found) return false;
            return value.Contains(identifier);
        }

        public static bool isKeyword(string identifier, MySQLVersion version)
        {
            var keywords = keywordsForVersion(version);
            return keywords.Contains(identifier);
        }

        public static MySQLVersion numberToVersion(long version)
        {
            long major = version / 10000, minor = (version / 100) % 100;

            if (major < 5 || major > 8)
                return MySQLVersion.Unknown;

            if (major == 8)
                return MySQLVersion.MySQL80;

            if (major != 5)
                return MySQLVersion.Unknown;

            switch (minor)
            {
                case 6:
                    return MySQLVersion.MySQL56;
                case 7:
                    return MySQLVersion.MySQL57;
                default:
                    return MySQLVersion.Unknown;
            }
        }
    }
}
