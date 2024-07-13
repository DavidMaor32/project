%{
#include <stdio.h>
int yylex();
int yyerror(const char* s);
int yylineno, col;
    char* yytext;
typedef enum {
    false, 
    true
}bool;
typedef struct {
    char*   str;
    unsigned int   size;
}string;
// typedef struct {
//     char* name;
//     yylval val;
// }yystype;
%}
%union{
    int     _int;
    float   _float;
    double  _real;
    char    _char;
    bool    _bool;
    string  _str;
    int*     p_int;
    float *  p_float;
    double*  p_real;
    char*    p_char;
    void*   _nullptr;
};

%token IF ELSE
%token WHILE DO FOR
%token ID STRLEN VAR ASS
%token PUBLIC PRIVATE ARGS STATIC MAIN RETURN VOID

%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR  
%token DIV MINUS PLUS MUL
%token DEREF REF

%token COLON SEMICOL COMMA 
%token BLOCK_OPEN BLOCK_CLOSE 
%token PARENT_OPEN PARENT_CLOSE 
%token INDEX_OPEN INDEX_CLOSE


%token  <_int>      LIT_INT     INT
%token  <_float>    LIT_FLOAT   FLOAT
%token  <_real>     LIT_REAL    REAL
%token  <_char>     LIT_CHAR    CHAR
%token  <_bool>     LIT_BOOL    BOOL
%token  <_nullptr>  NULLPTR
%token  <p_int>     P_INT
%token  <p_float>   P_FLOAT
%token  <p_real>    P_REAL
%token  <p_char>    P_CHAR
%token  <p_char>    LIT_STRING  STRING

%left COMMA
%right ASS
%left OR
%left AND
%nonassoc EQ NOT_EQ
%nonassoc LESS LESS_EQ GRTR GRTR_EQ
%left PLUS MINUS
%left MUL DIV
%right NOT
%right DEREF
%right REF
%right INDEX_OPEN
%%
s: program { printf("parsed successfully!%d:%d\n",yylineno,col);return 0; }

program: functions;

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT 
    | LIT_STRING ;

value: literal | ID ;

type: BOOL 
    | CHAR 
    | STRING 
    | INT 
    | FLOAT 
    | REAL ;
    
/* ptype: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT ; */

dec: declr_vars | dec declr_vars ;
declr_vars: VAR type COLON ID ass vars SEMICOL { printf("%s",yytext); }
vars: vars COMMA ID ass | ;
ass: ASS value | ;

functions: functions function | function;
function: modifier func_void | modifier func_ret;

modifier: PUBLIC | PRIVATE;
static: COLON STATIC | ;
params: 

func_ret: type ID PARENT_OPEN params PARENT_CLOSE static bodyRet;
func_void: VOID ID PARENT_OPEN params PARENT_CLOSE static body ;

%%
#include "lex.yy.c"
#ifdef YYDEBUG
  int yydebug = 1;
#endif
int main(){
    
    return yyparse();
}
int yyerror(const char* s){
    fprintf(stderr,"%s in <%d,%d> \"%s\"\n", s, yylineno,col, yytext);
    exit(1);
    return 1;
}


