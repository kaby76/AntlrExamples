/* 
      Multi-function calculator. 
This seems to be the canonical example for parser generators, but
there is really not much point in this example in Julia, inasmuch as
it only reproduces a small subset of what is available in the REPL
Note the C style comments for Bison.

*/

%{

# The Bison language is a very simple language.  Unfortunately for Julia,
# both '$' and '@' are reserved characters in Bison with special meaning.  
# Also note that Bison does not interpret these correctly inside of 
# quotes "".  So you will need to move much of your semantic actions 
# outside of the grammer specification, which is probably good practice anyway.

function yyerrok()
end

# This would turn on the debugging prints to watch the actions of the
# parser.
#const yydebug = true

function report_location(fr, fc, lr, lc)
    write(stderr, "Error location $fr:$fc $lr:$lc\n")
end

# OK the string lex values are sometimes Strings and sometimes
# SubString{String} and I am too lazy to figure out why.  So I
# got around it with a hierarchical Union type.
USubs = Union{String, SubString{String}}
 
%}
%union {USubs, Float64}
%token NUM
/* these return strings.  The lexer must decide on VAR vs FNCT */
%token VAR FNCT

%type<USubs> FNCT VAR
%type<Float64> exp NUM

%right '='
%left '-' '+'
%left '*' '/'
%left NEG
%right '^'

/* Grammar rules and actions follow */
%% 
input:    /* empty */
        | input line
;

line:     '\n'
        | exp '\n'  
        {            println($1) }
        | error '\n'
        {            yyerrok()   }
;

exp:      NUM             
        {            $$ = $1 }
        
        | VAR
        {            try
                $$ = eval(Symbol($1))  
            catch
	        println("Symbol ", $1, " is not defined")
                # FIXME should really do error handling here
                $$ = 0.0
            end
	}

        | VAR '=' exp
        {            $$ = $3
            # Inject variable definition into enclosing scope
	    eval(Expr(:(=), Symbol($1), $3))
        }

        | FNCT '(' exp ')'
        {         $$ = eval(Expr(:call, Symbol($1), $3)) }

        | exp '+' exp
        {            $$ = $1 + $3 }

        | exp '-' exp
        {            $$ = $1 - $3 }

        | exp '*' exp
        {            $$ = $1 * $3 }

        | exp '/' exp
        {            if $3 != 0.0
                $$ = $1 / $3
            else
                $$ = 1
                write(stderr, "Error: Divide by zero\n")
		report_location(@3.first_line, @3.first_column, @3.last_line, 
                                @3.last_column)
            end
	}

        | '-' exp %prec NEG
        {            $$ = -$2 }

        /* Exponentiation */
        | exp '^' exp
        {            $$ = $1 ^ $3 }

        | '(' exp ')'         
        {            $$ = $2 }
        
;
%%

# This is really low budget "tokenizing" and performance will be awful.
# We need to double up on the \ to \\ because the first one is
# processed away by the normal string handling.
# Note that each of the const defined below will be a capture group
# and so we can get the token id by the index of the capture group
NAME = "([a-zA-Z_][a-zA-Z_0-9]*)"   # Can be a function or variable
NMBR = "(\\d+\\.?(?:\\d+)?)"        # simplistic floating point matching
PLUS = "(\\+)"
MINUS = "(-)"
TIMES = "(\\*)"
DIV = "(/)"
EQ = "(=)"
NL = "(\n)"
EXP = "(\\^)"
LPARENS = "(\\()"
RPARENS = "(\\))"


token_pat = join((NAME, NMBR, PLUS, MINUS, TIMES, DIV, EQ, NL, EXP,
                  LPARENS, RPARENS ), "|")
regex = Regex(token_pat)


# Is the string a name of a Julia function?
function get_token(val::Union{String, SubString{String}})
    try
        if typeof(eval(Symbol(val))) <: Function
            return FNCT
        end
    catch
    end
    return VAR
end

using ResumableFunctions

# Just a note in passing here, I dont think that ResumableFunctions is
# all that robust. I wasted some hours tracking down two bugs where the
# way it rewrote the code producded errors.  Dont know why, but by trial
# and error was able to rewrite to something that worked.

@resumable function lex()
    # Typing ctrl-d at term returns ""
    io = stdin
    line_count = 0
    val = 0.0
    prompt = "mcalc> "
    print(prompt)
    while  (line = readline(io)) != ""
        # readline used to return the newline as well, but no more
	line = string(line, "\n")
        line_count += 1
        for mo in eachmatch(regex, line)
            yylloc = zero(YYLType)
	    tok = findfirst(x -> x != nothing, mo.captures)

            # Function or variable?
            if tok == 1
                # for variable or function, we return the string name
                # Note that this doesnt allow redefinition of function
                # names. We _should_ try to catch and report and error
                val = mo.match
		tok = get_token(val)

            # Return a number                
            elseif tok == 2
                val = parse(Float64, mo.match)
                tok = NUM

            else
                # Just return the Char value itself, but we must convert
                # to int to use the translation tables correctly
                val = 0.0
        	tok = Int(mo.captures[tok][1])
            end

            @yield (tok, val, yylloc)
        end
        print(prompt)
    end
    yylloc = zero(YYLType)
    @yield (-1, -1.0, yylloc)
end

function main()
    # In this instance, lex is a functor
    yylex = lex()
    return yyparse(yylex)
end
					  
main()