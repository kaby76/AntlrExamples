using Antlr4.Runtime;

namespace mysql
{
    public class Program
    {
        static void Try(string input, int server_version = 0)
        {
            //var str = new AntlrInputStream(input);
            var str = new AntlrInputStream(input);
            var lexer = new MySQLLexer(str);
            lexer.serverVersion = server_version;
            var tokens = new CommonTokenStream(lexer);
            var parser = new MySQLParser(tokens);
            parser.serverVersion = server_version;
            var listener = new ErrorListener<IToken>(parser, lexer, tokens);
            parser.AddErrorListener(listener);
            var tree = parser.queries();
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
            Try(@"create table `test` (field timestamp(6));");//, 80000);

            // -----------------------------
            // Positive (parses) tests.
            // -----------------------------
            Try("select * from foobar;");

            // (From https://www.mysqltutorial.org/mysql-comment/)
            Try(@"SELECT 1 /*! +1 */;");
            Try(@"CREATE TABLE t1 (
    k INT AUTO_INCREMENT,
    KEY (k)
)  /*!50110 KEY_BLOCK_SIZE=1024; */;");

            // (From https://www.mysqltutorial.org/mysql-adjacency-list-tree/)
            Try(@"CREATE TABLE category (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  title varchar(255) NOT NULL,
  parent_id int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (parent_id) REFERENCES category (id) 
    ON DELETE CASCADE ON UPDATE CASCADE
);");

            Try(@"INSERT INTO category(title,parent_id) 
VALUES('Electronics',NULL);");
            Try(@"INSERT INTO category(title,parent_id) 
VALUES('Laptops & PC',1);
 
INSERT INTO category(title,parent_id) 
VALUES('Laptops',2);
INSERT INTO category(title,parent_id) 
VALUES('PC',2);
 
INSERT INTO category(title,parent_id) 
VALUES('Cameras & photo',1);
INSERT INTO category(title,parent_id) 
VALUES('Camera',5);
 
INSERT INTO category(title,parent_id) 
VALUES('Phones & Accessories',1);
INSERT INTO category(title,parent_id) 
VALUES('Smartphones',7);
 
INSERT INTO category(title,parent_id) 
VALUES('Android',8);
INSERT INTO category(title,parent_id) 
VALUES('iOS',8);
INSERT INTO category(title,parent_id) 
VALUES('Other Smartphones',8);
 
INSERT INTO category(title,parent_id) 
VALUES('Batteries',7);
INSERT INTO category(title,parent_id) 
VALUES('Headsets',7);
INSERT INTO category(title,parent_id) 
VALUES('Screen Protectors',7);");
            Try(@"SELECT
    id, title
FROM
    category
WHERE
    parent_id IS NULL;");
            Try(@"SELECT
    id, title
FROM
    category
WHERE
    parent_id = 1;");
            Try(@"SELECT
    c1.id, c1.title
FROM
    category c1
        LEFT JOIN
    category c2 ON c2.parent_id = c1.id
WHERE
    c2.id IS NULL;");
            Try(@"WITH RECURSIVE category_path (id, title, path) AS
(
  SELECT id, title, title as path
    FROM category
    WHERE parent_id IS NULL
  UNION ALL
  SELECT c.id, c.title, CONCAT(cp.path, ' > ', c.title)
    FROM category_path AS cp JOIN category AS c
      ON cp.id = c.parent_id
)
SELECT * FROM category_path
ORDER BY path;", 80000);
            Try(@"WITH RECURSIVE category_path (id, title, path) AS
(
  SELECT id, title, title as path
    FROM category
    WHERE parent_id = 7
  UNION ALL
  SELECT c.id, c.title, CONCAT(cp.path, ' > ', c.title)
    FROM category_path AS cp JOIN category AS c
      ON cp.id = c.parent_id
)
SELECT * FROM category_path
ORDER BY path;", 80000);
            Try(@"WITH RECURSIVE category_path (id, title, parent_id) AS
(
  SELECT id, title, parent_id
    FROM category
    WHERE id = 10 -- child node
  UNION ALL
  SELECT c.id, c.title, c.parent_id
    FROM category_path AS cp JOIN category AS c
      ON cp.parent_id = c.id
)
SELECT * FROM category_path;", 80000);
            Try(@"WITH RECURSIVE category_path (id, title, lvl) AS
(
  SELECT id, title, 0 lvl
    FROM category
    WHERE parent_id IS NULL
  UNION ALL
  SELECT c.id, c.title,cp.lvl + 1
    FROM category_path AS cp JOIN category AS c
      ON cp.id = c.parent_id
)
SELECT * FROM category_path
ORDER BY lvl;", 80000);
            Try(@"DELETE FROM category 
WHERE
    id = 2;");
            Try(@"UPDATE category 
SET 
    parent_id = 7 -- Phones & Accessories
WHERE
    parent_id = 5; -- Smartphones");
            Try(@"DELETE FROM category 
WHERE
    id = 8;");
            Try("select col1 from foobar where col1 > 1 and col1 < 10;");
            Try(@"select (select t1.id as a, sakila.actor.actor_id b, t2.id c, (select  1 * 0.123, a from t3) from  `ÄÖÜ丈` t1, sakila.actor as t2
where ((t1.id = t2.id)) and (t1.id = sakila.actor.actor_id)) as r1, 2;");
            Try(@"select 1 from
  {OJ d left outer join e on a = b} left outer join ee on aa = bb,
  a t1 force index for order by (a, b),
  (select 2 from zz) yy straight_join (select 3) as xx on ww,
  (b, c),
  (f, g) inner join h using (aa, bb),(h) straight_join `schema`.`table` on yy < zz natural right join ({OJ i left outer join j on ii = jj});");
            Try(@"select A, B, A OR B, A XOR B, A AND B from t1_30237_bool where C is null order by A, B;");
            Try(@"select count(distinct a.actor_id), phone, first_name, a.last_name, country.country 
from sakila.actor a, address aa, country
where (a.actor_id = 0 and country_id > 0) 
group by actor_id;");
            Try(@"drop user current_user(), 'mike'@localhost;");
            Try(@"CREATE definer = `root`@`localhost` trigger `upd_film` AFTER UPDATE ON `film` FOR EACH ROW BEGIN
  IF (old.title != new.title) or (old.description != new.description)
  THEN
    UPDATE film_text
      SET title=new.title,
          description=new.description,
          film_id=new.film_id
    WHERE film_id=old.film_id;
  END IF;
END;");
            Try(@"CREATE TABLE total (
  a INT NOT NULL AUTO_INCREMENT,
  message CHAR(20), INDEX(a))
  ENGINE=MERGE UNION=(t1,t2) INSERT_METHOD=LAST;
");
            Try(@"SELECT a FROM tick t WHERE timestamp > (((((((SELECT 1)  + 1))))));");
            Try(@"select * from (select 1 from dual);");



            // Negative (does not parse) tests.
            Try(@"select 2 as expected, /*!01000/**/*/ 2 as result;");
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
END;");
            Try(@"grant alter (a, b) on table * to 'mike'@'%';");
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
