using Antlr4.Runtime;

namespace mysql
{
    public class Program
    {
        static void Try(string input)
        {
            //var str = new AntlrInputStream(input);
            var str = new AntlrInputStream(input);
            var lexer = new MySQLLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new MySQLParser(tokens);
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.query();
            if (listener.had_error)
            {
                System.Console.WriteLine("error in parse.");
            }
            else
            {
                System.Console.WriteLine("parse completed.");
            }
            System.Console.WriteLine(tokens.OutputTokens());
            System.Console.WriteLine(tree.OutputTree(tokens));
        }

        static void Main(string[] args)
        {
            Try(@"select 2 as expected, /*!01000/**/*/ 2 as result");
            return;
            Try("select * from foobar;");
            Try("select col1 from foobar where col1 > 1 and col1 < 10;");
            Try(@"select (select t1.id as a, sakila.actor.actor_id b, t2.id c, (select  1 * 0.123, a from t3) from  `ÄÖÜ丈` t1, sakila.actor as t2
where ((t1.id = t2.id)) and (t1.id = sakila.actor.actor_id)) as r1, 2");
            Try(@"select 1 from
  {OJ d left outer join e on a = b} left outer join ee on aa = bb,
  a t1 force index for order by (a, b),
  (select 2 from zz) yy straight_join (select 3) as xx on ww,
  (b, c),
  (f, g) inner join h using (aa, bb),(h) straight_join `schema`.`table` on yy < zz natural right join ({OJ i left outer join j on ii = jj})");
            Try(@"CREATE PROCEDURE do_insert(value INT)
  BEGIN
    -- declare variables to hold diagnostics area information
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE rows INT;
    DECLARE result TEXT;
    -- declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;
  -- perform the insert
  INSERT INTO t1 (int_col) VALUES(value);
  -- check whether the insert was successful
  IF code = '00000' THEN
    GET DIAGNOSTICS rows = ROW_COUNT;
   -- SET result = CONCAT('insert succeeded, row count = ',rows);
  ELSE
   -- SET result = CONCAT('insert failed, error = ',code,', message = ',msg);
  END IF;
  -- say what happened
  SELECT result;
END");
            Try(@"grant alter (a, b) on table * to 'mike'@'%'");
            Try(@"select A, B, A OR B, A XOR B, A AND B from t1_30237_bool where C is null order by A, B");
            Try(@"select count(distinct a.actor_id), phone, first_name, a.last_name, country.country 
from sakila.actor a, address aa, country
where (a.actor_id = 0 and country_id > 0) 
group by actor_id");
            Try(@"drop user current_user(), 'mike'@localhost");
            Try(@"CREATE definer = `root`@`localhost` trigger `upd_film` AFTER UPDATE ON `film` FOR EACH ROW BEGIN
  IF (old.title != new.title) or (old.description != new.description)
  THEN
    UPDATE film_text
      SET title=new.title,
          description=new.description,
          film_id=new.film_id
    WHERE film_id=old.film_id;
  END IF;
END");
            Try(@"CREATE TABLE total (
  a INT NOT NULL AUTO_INCREMENT,
  message CHAR(20), INDEX(a))
  ENGINE=MERGE UNION=(t1,t2) INSERT_METHOD=LAST;
");
            Try(@"SELECT a FROM tick t WHERE timestamp > (((((((SELECT 1)  + 1))))))");
            Try(@"select * from (select 1 from dual)");
            Try(@"ALTER USER u@localhost IDENTIFIED WITH sha256_password BY 'test';");


            Try(@"`test` select 1;"); //Syntax error: `test` (back thick quoted id) is not valid input at this position
            Try(@"'test' select 1;"); // Syntax error: 'test' (single quoted text) is not valid input at this position
            Try("\"test\" select 1;"); // Syntax error: "test" (double quoted text) is not valid input at this position
            Try("select 1 from ;"); // Syntax error: unexpected end of statement
            Try("select 1 from '';"); // Syntax error: unexpected '' (single quoted text)
            Try(@"
select a, b,
    (case y
        -- missing when clause here
        then c # Syntax error: missing subclause or elements before 'then' (then)
        else 0 # Syntax error: missing closing parenthesis
    end)
;");
        }
    }
}
