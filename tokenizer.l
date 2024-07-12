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
                                c = *yytext;
                                yytext++;
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
                                printf( "EOF in comment");
                                break;
                                }
                            }
                        }
 /*KEYWORDS*/
bool                {  col+= yyleng;printf("BOOL "); }
char                {  col+= yyleng;printf("CHAR "); }
int                 {  col+= yyleng;printf("INT "); }
double              {  col+= yyleng;printf("REAL "); }
float               {  col+= yyleng;printf("FLOAT "); }
string              {  col+= yyleng;printf("STRING "); }
null                {  col+= yyleng;printf("NULLPTR "); }
"int*"              {  col+= yyleng;printf("P_INT "); }
"float*"            {  col+= yyleng;printf("P_FLOAT "); }
"double*"           {  col+= yyleng;printf("P_REAL "); }
"char*"             {  col+= yyleng;printf("P_CHAR "); }
"var"                 {  col+= yyleng;printf("VAR "); }
if                  {  col+= yyleng;printf("IF "); }
else                {  col+= yyleng;printf("ELSE "); }
while               {  col+= yyleng;printf("WHILE "); }
do                  {  col+= yyleng;printf("DO "); }
for                 {  col+= yyleng;printf("FOR "); }
"args>>"            {  col+= yyleng;printf("ARGS "); }
public              {  col+= yyleng;printf("PUBLIC "); }
private             {  col+= yyleng;printf("PRIVATE "); }
static              {  col+= yyleng;printf("STATIC "); }
return              {  col+= yyleng;printf("RETURN "); }
void                {  col+= yyleng;printf("VOID "); }
main                {  col+= yyleng;printf("MAIN "); }
 /*Operators*/
"&&"                {  col+= yyleng;printf("AND "); }
"=="                {  col+= yyleng;printf("EQ "); }
"!="                {  col+= yyleng;printf("NOT_EQ "); }
"<-"                {  col+= yyleng;printf("ASS "); }
">="                {  col+= yyleng;printf("GRTR_EQ "); }
"<="                {  col+= yyleng;printf("LESS_EQ "); }
">"                 {  col+= yyleng;printf("GRTR "); }
"<"                 {  col+= yyleng;printf("LESS "); }
"!"                 {  col+= yyleng;printf("NOT "); }
"||"                {  col+= yyleng;printf("OR "); }
"/"                 {  col+= yyleng;printf("DIV "); }
"-"                 {  col+= yyleng;printf("MINUS "); }
"+"                 {  col+= yyleng;printf("PLUS "); }
{ID}\*              {  col+= yyleng;printf("MUL "); }
"&"{ID}             {  col+= yyleng;printf("REF "); }
\*{ID}              {  col+= yyleng;printf("DEREF "); }
 /*Literals*/
true|false          { printf("LIT_BOOL "); }
{char}              { printf("LIT_CHAR "); }
{int_dec}           { printf("LIT_INT "); }
{int_hex}           { printf("LIT_INT "); }
{double}            { printf("LIT_REAL "); }
{float}             {  col+= yyleng;printf("LIT_FLOAT "); }
{string}            {  col+= yyleng;printf("LIT_STRING "); }
{ID}                {  col+= yyleng;printf("ID "); }
 /*others*/
";"         { printf("SEMICOL "); }
","         { printf("COMMA "); }
"|"         { printf("STRLEN "); }
"{"         { printf("BLOCK_OPEN "); }
"}"         { printf("BLOCK_CLOSE "); }
"("         { printf("PARENT_OPEN "); }
")"         { printf("PARENT_CLOSE "); }
"["         { printf("INDEX_OPEN "); }
"]"         { printf("INDEX_CLOSE "); }
":"         { printf("COLON "); }
.                   {  printf("UNRECOGNIZED TOKEN ");col+= yyleng; }
%%