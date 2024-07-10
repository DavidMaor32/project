
DIGIT       [0-9]
DIGIT_HEX   [A-F]
NONZERO     [1-9]
SIGN        [\-\+]
LETTER      [a-zA-Z]
CHARACHTER  [a-zA-Z0-9]
char        \'[ -~]\'
int_dec     0|{NONZERO}{DIGIT}*
int_hex     0(x|X){DIGIT_HEX}+
int         (^{SIGN})?({int_hex}|{int_dec})
ex_notation (e|E){int_dec}
double      (^{SIGN})?({int_dec}?.{int_dec}|{int_dec}.{int_dec}?){ex_notation}?
float       ({double}|{int}.)(f|F)
string      \"[ -!#-~]*\"
identifier  {LETTER}({CHARACHTER}|_)*

%%
[\t\s]+      ;
[\n]       { yylineno++; }
"/*"        { return COMMENT_OPEN; }
"*/"        { return COMMENT_END; }
 /*KEYWORDS*/
bool        { return BOOL; }
char        { return CHAR; }
int         { return INT; }
double      { return DOUBLE; }
float       { return FLOAT; }
string      { return STRING; }
null        { return NULLPTR; }
"int*"      { return PTR_INT; }
"float*"    { return PTR_FLOAT; }
"double*"   { return PTR_DOUBLE; }
"char*"     { return PTR_CHAR; }
var         { return VAR; }
if          { return IF; }
else        { return ELSE; }
while       { return WHILE; }
do          { return DO; }
for         { return FOR; }
"args>>"    { return ARGS; }
public      { return PUBLIC; }
private     { return PRIVATE; }
static      { return STATIC; }
return      { return RETURN; }
void        { return VOID; }
main        { return MAIN; }
 /*Operators*/
"&&"        { return AND; }
"=="        { return EQ; }
">"         { return GRTR; }
">="        { return GRTR_EQ; }
"<"         { return LESS; }
"<="        { return LESS_EQ; }
"!"         { return NOT; }
"!="        { return NOT_EQ; }
"||"        { return OR; }
"/"         { return DIV; }
"-"         { return SUB; }
"+"         { return ADD; }
[.]+\*      { return MUL; }     /*maybe use {identifier} instead*/
"&"[.]+     { return REF; }     /*maybe delete the [.]+  or put {identifier}*/
\*[.]+      { return DEREF; }   /*maybe use {identifier} instead*/
 /*Literals*/
true|false      { yylval = (strcmp("true",yytext) == 0 ? 1: 0); return LIT_BOOL; }
{char}          { yylval = yytext[1]; return LIT_CHAR; }
{int_dec}           { yylval = atoi(yytext); return LIT_INT; }
{int_hex}           { yylval = atoi(yytext); return LIT_INT; }
{double}        { return LIT_DOUBLE; }
{float}         { return LIT_FLOAT; }
{string}        { return LIT_STRING; }
{identifier}    { return IDENTIFIER; }
 /*others*/
";"         { return SEMICOL; }
","         { return COMMA; }
"|"         { return STRLEN; }
"{"         { return BLOCK_OPEN; }
"}"         { return BLOCK_CLOSE; }
"("         { return BRACKET_OPEN; }
")"         { return BRACKET_CLOSE; }
"["         { return INDEX_OPEN; }
"]"         { return INDEX_CLOSE; }
"<-"        { return ASS; }
":"         { return COLON; }
.           { return yytext[0]; }
%%