// Template generated code from Antlr4BuildTasks.dotnet-antlr v 1.5


import java.io.FileNotFoundException;
import java.io.IOException;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

public class Program {
    public static void main(String[] args) throws  FileNotFoundException, IOException
    {
        boolean show_tree = false;
        boolean show_tokens = false;
        String file_name = null;
        String input = null;
        for (int i = 0; i < args.length; ++i)
        {
            if (args[i].equals("-tokens"))
            {
                show_tokens = true;
                continue;
            }
            else if (args[i].equals("-tree"))
            {
                show_tree = true;
                continue;
            }
            else if (args[i].equals("-input"))
                input = args[++i];
            else if (args[i].equals("-file"))
                file_name = args[++i];
        }

        for (int kk = 0; kk < 99; ++kk)
        {
            CharStream str = null;
            if (input == null && file_name == null)
            {
                str = CharStreams.fromStream(System.in);
            } else if (input != null)
            {
                str = CharStreams.fromString(input);
            } else if (file_name != null)
            {
                str = CharStreams.fromFileName(file_name);
            }
            RiScriptLexer lexer = new RiScriptLexer(str);
            if (show_tokens)
            {
                StringBuilder new_s = new StringBuilder();
                for (int i = 0; ; ++i)
                {
                var ro_token = lexer.nextToken();
                var token = (CommonToken)ro_token;
                token.setTokenIndex(i);
                new_s.append(token.toString());
                new_s.append(System.getProperty("line.separator"));
                if (token.getType() == IntStream.EOF)
                    break;
                }
                System.out.println(new_s.toString());
            }
            lexer.reset();
            var tokens = new CommonTokenStream(lexer);
            RiScriptParser parser = new RiScriptParser(tokens);
            ErrorListener lexer_listener = new ErrorListener();
            ErrorListener listener = new ErrorListener();
            parser.removeParseListeners();
            parser.addErrorListener(listener);
            lexer.addErrorListener(lexer_listener);
            ParseTree tree = parser.script();
            if (show_tree)
            {
                System.out.println(tree.toStringTree());
            }
        }
    }
}
