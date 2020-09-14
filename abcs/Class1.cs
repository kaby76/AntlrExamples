using Antlr4.Runtime;
using Antlr4.Runtime.Misc;
using System;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;

namespace a
{
    class TestSize<T>
    {

        static private int SizeOfObj(Type T, object thevalue)
        {
            var type = T;
            int returnval = 0;
            if (type.IsValueType)
            {
                var nulltype = Nullable.GetUnderlyingType(type);
                returnval = System.Runtime.InteropServices.Marshal.SizeOf(nulltype ?? type);
            }
            else if (thevalue == null)
                return 0;
            else if (thevalue is string)
                returnval = Encoding.Default.GetByteCount(thevalue as string);
            else if (type.IsArray && type.GetElementType().IsValueType)
            {
                returnval = ((Array)thevalue).GetLength(0) * System.Runtime.InteropServices.Marshal.SizeOf(type.GetElementType());
            }
            else if (thevalue is Stream)
            {
                Stream thestram = thevalue as Stream;
                returnval = (int)thestram.Length;
            }
            else if (type.IsSerializable)
            {
                try
                {
                    using (Stream s = new MemoryStream())
                    {
                        BinaryFormatter formatter = new BinaryFormatter();
                        formatter.Serialize(s, thevalue);
                        returnval = (int)s.Length;
                    }
                }
                catch { }
            }
            else
            {
                var fields = type.GetFields(System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                for (int i = 0; i < fields.Length; i++)
                {
                    Type t = fields[i].FieldType;
                    Object v = fields[i].GetValue(thevalue);
                    returnval += 4 + SizeOfObj(t, v);
                }
            }
            if (returnval == 0)
                try
                {
                    returnval = System.Runtime.InteropServices.Marshal.SizeOf(thevalue);
                }
                catch { }
            return returnval;
        }
        static public int SizeOf(T value)
        {
            return SizeOfObj(typeof(T), value);
        }
    }

    class MyCTF : ITokenFactory
    {
        [return: NotNull]
        public IToken Create(Tuple<ITokenSource, ICharStream> source, int type, string text, int channel, int start, int stop, int line, int charPositionInLine)
        {
            var result = new MyToken()
            {
                Channel = channel,
                Column = charPositionInLine,
                InputStream = source.Item2,
                Line = line,
                StartIndex = start,
                StopIndex = stop,
                Text = text,
                Type = type,
            };
            //var size = TestSize<MyToken>.SizeOf(result);
            return result;
        }

        [return: NotNull]
        public IToken Create(int type, string text)
        {
            var result = new MyToken()
            {
                Text = text,
                Type = type,
            };
            return result;
        }
    }

    class MyToken : IToken
    {
        public string Text { get { return ""; } set { } }
        // SAVE 4 bytes public string Text { get; set; }
        public int Type { get; set; }
        public int Line { get { return 0; } set { } }
        public int Column { get { return 0; } set { } }
        public int Channel { get; set; }
        public int TokenIndex { get; set; }
        public int StartIndex { get { return 0; } set { } }
        public int StopIndex { get { return 0; } set { } }
        public ITokenSource TokenSource { get { return null; } set { } }
        public ICharStream InputStream { get { return null; } set { } }
        }
}
