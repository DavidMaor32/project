DIGIT       [0-9]
DIGIT_HEX   [A-F]
NONZERO     [1-9]
SIGN        [\-\+]
LETTER      [a-zA-Z]
CHARACHTER  [a-zA-Z0-9]
char        \'[ -~]\'
int_dec     0|{NONZERO}{DIGIT}*
int_hex     0(x|X){DIGIT_HEX}+
lit_int         {SIGN}?({int_hex}|{int_dec})
ex_notation (e|E){int_dec}
double      {SIGN}?({int_dec}?\.{int_dec}|{int_dec}\.{int_dec}?){ex_notation}?
float       ({double}|{lit_int}\.)(f|F)
string      \"[ -!#-~]*\"
ID  {LETTER}({CHARACHTER}|_)*
%{
    #include <stdlib.h>
    int col = 1;
%}
%%
[ \t\s\r]           {col++;}
[ \n]               { yylineno++; col = 1; }
"/*"                {
                        char c;
                        while (1){
                            do{
                                c = input();
                                col++;
                                if ( c == '\n')
                                    yylineno++;
                            }while ( c != '*' && c != EOF );    /* eat up text of comment */
                            if ( c == '*' ){
                                while ( (c = input()) == '*' );
                                if ( c == '/' )
                                    break;    /* found the end */
                            }
                            if ( c == EOF ){
                                yyerror( "EOF in comment");
                                break;
                                }
                            }
                        }
 /*KEYWORDS*/
bool                {  col+= yyleng;return BOOL; }
char                {  col+= yyleng;return CHAR; }
int                 {  col+= yyleng;return INT; }
double              {  col+= yyleng;return DOUBLE; }
float               {  col+= yyleng;return FLOAT; }
string              {  col+= yyleng;return STRING; }
null                {  col+= yyleng;return NULLPTR; }
"int*"              {  col+= yyleng;return PTR_INT; }
"float*"            {  col+= yyleng;return PTR_FLOAT; }
"double*"           {  col+= yyleng;return PTR_DOUBLE; }
"char*"             {  col+= yyleng;return PTR_CHAR; }
var                 {  col+= yyleng;return VAR; }
if                  {  col+= yyleng;return IF; }
else                {  col+= yyleng;return ELSE; }
while               {  col+= yyleng;return WHILE; }
do                  {  col+= yyleng;return DO; }
for                 {  col+= yyleng;return FOR; }
"args>>"            {  col+= yyleng;return ARGS; }
public              {  col+= yyleng;return PUBLIC; }
private             {  col+= yyleng;return PRIVATE; }
static              {  col+= yyleng;return STATIC; }
return              {  col+= yyleng;return RETURN; }
void                {  col+= yyleng;return VOID; }
main                {  col+= yyleng;return MAIN; }
 /*Operators*/
"&&"                {  col+= yyleng;return AND; }
"=="                {  col+= yyleng;return EQ; }
"<-"                {  col+= yyleng;return ASS; }
">="                {  col+= yyleng;return GRTR_EQ; }
"<="                {  col+= yyleng;return LESS_EQ; }
">"                 {  col+= yyleng;return GRTR; }
"<"                 {  col+= yyleng;return LESS; }
"!"                 {  col+= yyleng;return NOT; }
"!="                {  col+= yyleng;return NOT_EQ; }
"||"                {  col+= yyleng;return OR; }
"/"                 {  col+= yyleng;return DIV; }
"-"                 {  col+= yyleng;return SUB; }
"+"                 {  col+= yyleng;return ADD; }
{ID}\*              {  col+= yyleng;return MUL; }
"&"{ID}             {  col+= yyleng;return REF; }
\*{ID}              {  col+= yyleng;return DEREF; }
 /*Literals*/
true|false          {  col+= yyleng;yylval._bool = (strcmp("true",yytext) == 0 ? 1: 0); return LIT_BOOL; }
{char}              {  col+= yyleng;yylval._char = yytext[1]; return LIT_CHAR; }
{int_dec}           {  col+= yyleng;yylval._int = atoi(yytext); return LIT_INT; }
{int_hex}           {  col+= yyleng;yylval._int = atoi(yytext); return LIT_INT; }
{double}            {  col+= yyleng;char* pend; yylval._real = strtod(yytext, &pend); return LIT_REAL; }
{float}             {  col+= yyleng;return LIT_FLOAT; }
{string}            {  col+= yyleng;return LIT_STRING; }
{ID}                {  col+= yyleng;return ID; }
 /*others*/
.                   {  yyerror("UNRECOGNIZED TOKEN ");col+= yyleng;return yytext[0]; }
%%