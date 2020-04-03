/* #include <stdio.h>

main()
{
        char *line;
        while(line = yylex()){
                printf("%s", line);
        }
}
*/

%e 2000
%p 5000
%n 1000
%k 500
%a 4000
%o 2000
BW [         ]
EW [         .,;!?]

%{
        char buf[128];

%}

%%
file                                return(" stash");
send                                return(" t'row");
program                                return(" honky code");
atlas                                return(" Isaac");
unix                                return(" slow mo-fo");
UNIX                                return(" that slow mo-fo");
takes                                return(" snatch'd");
Mexican                                return(" wet-back");
mexican                                return(" wet-back");
Italian                                return(" greaser");
italian                                return(" greaser");
take                                return(" snatch");
"don't"                                return(" duzn't");
jive                                return(" JIBE");
fool                                return(" honkyfool");
modem                                return(" doodad");
"e the "                        return("e da damn ");
"a the "                        return("a da damn ");
"t the "                        return("t da damn ");
"d the "                        return("d da damn ");
man                     return(" dude ");
woman                                return("mama");
girl                                return("goat");
something                        return("sump'n");
" lie "                        return(" honky jibe ");
-o-                     return(" -on rebound- ");
-oo-                        return(" -check y'out latah-");
[a-b]"."                { sprintf(buf, "%s  Sheeeiit.",yytext); return(buf); }
[e-f]"."                { sprintf(buf, "%s  What it is, Mama!",yytext); return(buf); }
[i-j]"."                { sprintf(buf, "%s  Ya' know?",yytext); return(buf); }
[m-n]"."                { sprintf(buf, "%s  'S coo', bro.",yytext); return(buf); }
[q-r]"."                { sprintf(buf, "%s  Ah be baaad...",yytext); return(buf); }
[u-v]"."                { sprintf(buf, "%s  Man!",yytext); return(buf); }
[y-z]"."                { sprintf(buf, "%s  Slap mah fro!",yytext); return(buf); }
Sure                        return("Sho' nuff");
sure                        return("sho' nuff");
\40+get                                return(" git");
"will have"                        return("gots'ta");
"will "                                return("gots'ta ");
"got to"                        return("gots'ta");
"I am"                                return("I's gots'ta be");
"am not"                                return("aint");
"is not"                                return("aint");
"are not"                                return("aint");
" are your"                                return(" is yo'");
" are you"                                return(" you is");
\40+hat\40+                     return(" fedora ");
\40+shoe                    return(" kicker");
haven't                                return("aint");
"have to"                        return("gots'ta");
have                                return("gots'");
" has"                                return(" gots'ta");
"come over"                        return("mosey on down");
\40+come\40+                    return(" mosey on down ");
!                       return(".  Right On!  ");
buy                                return("steal");
\40+car\40+                     return(" wheels ");
drive                                return("roll");
\40+eat\40+                     return(" feed da bud ");
\40+black                   return(" brother ");
\40+negro                   return(" brother");
white                                 return("honky");
\40+nigger                  return(" gentleman ");
nice                                return("supa' fine");
"person"                        return("sucka'");
\40+thing                   return(" wahtahmellun");
home                                        return("plantation");
name                                return("dojigger");
\40+path                    return(" alley");
computer                        return("clunker");
or                                return("o'");
killed                                return("wasted");
president                        return("super-dude");
"prime minister"                return("super honcho");
injured                                return("hosed");
government                        return("guv'ment");
knew                                return("knowed");
because                                return("a'cuz");
Because                                return("A'cuz");
your                                return("yo'");
Your                                return("Yo'");
four                                return("foe");
got                                return("gots");
aren't                                return("ain't");
young                                return("yung");
you                                return("ya'");
You                                return("You's");
first                                return("fust");
police                                return("honky pigs");
\40+string                  return(" chittlin'");
\40+read                return(" eyeball");
write                                return("scribble");
th                                return("d");
Th                                return("D");
ing                                return("in'");
\40+a\40+                        return(" some ");
\40+to\40+                        return(" t'");
tion                                return("shun");
\40+almost\40+                        return(" mos' ");
" from"                        return(" fum");
\40+because\40+                return(" cuz' ");
you're                return("youse");
You're                return("Youse");
alright                        return("coo'");
okay                        return("coo'");
"er "                        return("a' ");
known                        return("knode");
want                        return("wants'");
beat                        return("whup'");
exp                        return("'sp");
exs                        return("'s");
" exc"                        return(" 's");
" ex"                        return(" 'es");
like                        return("likes");
did                                return("dun did");
"kind of"                        return("kind'a");
women                                return("honky chicks");
" men "                                return(" dudes ");
" mens "                        return(" dudes ");
" man "                                return(" dude ");
woman                                return("honky chick");
dead                        return("wasted");
good                        return("baaaad");
"open "                                return("jimmey ");
"opened "                        return("jimmey'd ");
" very"                                return(" real");
"per"                                return("puh'");
"pera"                                return("puh'");
"oar"                                return("o'");
" can"                                return(" kin");
"just "                                return("plum ");
detroit                        return("Mo-town");
"western electric"                return("da' cave");
" believe"                        return(" recon'");
[Ii]"ndianapolis"                return("Nap-town");
" "[Jj]"ack"                        return(" Buckwheat");
" "[Bb]"ob "                return(" Liva' Lips ");
" "[Pp]"hil "                return(" dat fine soul ");
" "[Mm]"ark "                return(" Amos ");
[Rr]obert                return("Leroy");
[Ss]"andy"                return("dat fine femahnaine ladee");
[Jj]"ohn "                return("Raz'tus ");
" "[Pp]"aul"                return(" Fuh'rina");
[Rr]"eagan"                return("Kingfish");
[Dd]"avid"                return("Issac");
[Rr]"onald"                return("Rolo");
" "[Jj]"im "                return(" Bo-Jangles ");
" "[Mm]"ary"                return(" Snow Flake");
[Ll]"arry"                return("Remus");
[Jj]"oe"                return("Massa' ");
[Jj]"oseph"                return("Massa' ");
mohammed                        return("liva' lips");
pontiff                                return("wiz'");
pope                                return("wiz'");
pravda                                return("dat commie rag");
broken                                return("bugger'd");
"strange "                        return("funky ");
"dance "                        return("boogy ");
" house"                        return(" crib");
ask                                return("ax'");
" so "                                return(" so's ");
head                                return("'haid");
boss                                return("main man");
wife                                return("mama");
people                                return("sucka's");
money                                return("bre'd");
[a-z]":"                {        *(yytext+1) = ',';
                                sprintf(buf, "%s dig dis:",yytext);
                                return(buf);
                        }
amateur                                return("begina'");
radio                                        return("transista'");
" of "                                return(" uh ");
what                                return("whut");
does                                return("duz");
was                                return("wuz");
" were"                                return(" wuz");
"understand it"                        return("dig it");
understand                        return("dig it");
" my"                                return(" mah'");
" "[Ii]" "                        return(" ah' ");
"meta"                                return("meta-fuckin'");
"hair"                        return("fro");
"talk"                        return("rap");
"music"                        return("beat");
"basket"                return("hoop");
"football"                return("ball");
"friend"                return("homey");
"school"                return("farm");
"boss"                        return("Man");
"want to"                return("wanna");
"wants to"                return("be hankerin' aftah");
"well"                        return("sheeit");
"Well"                        return("Sheeit");
"big"                        return("big-ass");
"bad"                        return("bad-ass");
"small"                        return("little-ass");
"sort of"                return("radical");
" is "                        return(" be ");
water                        return("booze");
book                        return("scribblin'");
magazine                return("issue of GQ");
paper                        return("sheet");
up                        return("down");
down                        return("waaay down");
break                        return("boogie");
Hi                        return("'Sup, dude");
VAX                        return("pink Cadillac");
.                        return(yytext);
\n                        return("\n");

%%

        