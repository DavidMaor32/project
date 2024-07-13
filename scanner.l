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
[ \t\s\r]           {   col++;}
[ \n]               {   yylineno++; col = 1; }
"/*"(.|\n)*"*/"     {   for(int i =0;i<yyleng;i++) {if(yytext[i] == '\n') {yylineno++;col=0;} col++;} }
"/*"                {   yyerror("missing closing comment!"); }          
 /*KEYWORDS*/
bool                {   col+= yyleng;return BOOL; }
char                {   col+= yyleng;return CHAR; }
int                 {   col+= yyleng;return INT; }
double              {   col+= yyleng;return REAL; }
float               {   col+= yyleng;return FLOAT; }
string              {   col+= yyleng;return STRING; }
null                {   col+= yyleng;return NULLPTR; }
"int*"              {   col+= yyleng;return P_INT; }
"float*"            {   col+= yyleng;return P_FLOAT; }
"double*"           {   col+= yyleng;return P_REAL; }
"char*"             {   col+= yyleng;return P_CHAR; }
var                 {   col+= yyleng;return VAR; }
if                  {   col+= yyleng;return IF; }
else                {   col+= yyleng;return ELSE; }
while               {   col+= yyleng;return WHILE; }
do                  {   col+= yyleng;return DO; }
for                 {   col+= yyleng;return FOR; }
"args>>"            {   col+= yyleng;return ARGS; }
public              {   col+= yyleng;return PUBLIC; }
private             {   col+= yyleng;return PRIVATE; }
static              {   col+= yyleng;return STATIC; }
return              {   col+= yyleng;return RETURN; }
void                {   col+= yyleng;return VOID; }
main                {   col+= yyleng;return MAIN; }
 /*Operators*/
"&&"                {   col+= yyleng;return AND; }
"=="                {   col+= yyleng;return EQ; }
"!="                {   col+= yyleng;return NOT_EQ; }
"<-"                {   col+= yyleng;return ASS; }
">="                {   col+= yyleng;return GRTR_EQ; }
"<="                {   col+= yyleng;return LESS_EQ; }
">"                 {   col+= yyleng;return GRTR; }
"<"                 {   col+= yyleng;return LESS; }
"!"                 {   col+= yyleng;return NOT; }
"||"                {   col+= yyleng;return OR; }
"/"                 {   col+= yyleng;return DIV; }
[*+-]               {   col+= yyleng;return *yytext; }
"&"                 {   col+= yyleng;return REF; }
 /*Literals*/
true|false          {   col+= yyleng;return LIT_BOOL; }
{char}              {   col+= yyleng;return LIT_CHAR; }
{int_dec}           {   col+= yyleng;return LIT_INT; }
{int_hex}           {   col+= yyleng;return LIT_INT; }
{double}            {   col+= yyleng;return LIT_REAL; }
{float}             {   col+= yyleng;return LIT_FLOAT; }
{string}            {   col+= yyleng;return LIT_STRING; }
{ID}                {   col+= yyleng;return ID; }
 /*others*/
";"                 {   col+= yyleng;return SEMICOL; }
","                 {   col+= yyleng;return COMMA; }
"|"                 {   col+= yyleng;return STRLEN; }
"{"                 {   col+= yyleng;return BLOCK_OPEN; }
"}"                 {   col+= yyleng;return BLOCK_CLOSE; }
"("                 {   col+= yyleng;return PARENT_OPEN; }
")"                 {   col+= yyleng;return PARENT_CLOSE; }
"["                 {   col+= yyleng;return INDEX_OPEN; }
"]"                 {   col+= yyleng;return INDEX_CLOSE; }
":"                 {   col+= yyleng;return COLON; }
.                   {   yyerror("UNRECOGNIZED TOKEN ");col+= yyleng;return yytext[0]; }
%%