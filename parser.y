/*
program: function
*/
%{
#include <stdio.h>
int yylex();
int yyerror();
}%

%token COMMENT_OPEN COMMENT_END
%token REF DEREF
%token IDENTIFIER  SEMICOL COMMA STRLEN VAR
%token ARGS PUBLIC PRIVATE STATIC RETURN 
%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR 
%token BLOCK_OPEN BLOCK_CLOSE BRACKET_OPEN BRACKET_CLOSE INDEX_OPEN INDEX_CLOSE
%token BOOL CHAR STRING INT FLOAT DOUBLE VOID NULL
%token LIT_BOOL LIT_CHAR LIT_INT LIT_DOUBLE LIT_FLOAT LIT_STRING 
%token PTR_INT PTR_FLOAT PTR_DOUBLE PTR_CHAR
%token WHILE DO FOR
%token IF ELSE

%left COMMA
%right ASS
%left OR
%left AND
%left EQ NOT_EQ
%left LESS LESS_EQ GRTR GRTR_EQ
%left ADD SUB
%left MUL DIV
%right NOT
%right DEREF
%right REF
right INDEX_OPEN
%



s: program
;

program: 
    function
|program function
;

function:
modifier returnType IDENTIFIER BRACKET_OPEN arguments static body
;

modifier: 
    PRIVATE
| PUBLIC
;

returnType: void | type;
type: BOOL | INT | FLOAT | DOUBLE | CHAR | STRING | ptype;
ptype: PTR_INT | PTR_FLOAT | PTR_DOUBLE | PTR_CHAR;
argType: ptype | type;

arguments: BRACKET_CLOSE | ARGS list arglists;
arglists: SEMICOL list arglists | BRACKET_CLOSE
list:   argType ":" IDENTIFIER ls;
ls: COMMA IDENTIFIER ls | IDENTIFIER;

static: ":" STATIC | "NON-STATIC";

body:
BLOCK_OPEN declarations statements BLOCK_CLOSE;

declarations: declaration
declaration: dec_var | function;

dec_var:
VAR type IDENTIFIER dec;
dec: COMMA IDENTIFIER val dec | SEMICOL;
val:   "" | ASS value;
value: literal | functionCall;
