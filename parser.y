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
%token DIV '-' '+' '*'
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
%left '+' '-'
%left '*' DIV
%nonassoc REF
%nonassoc DEREF 
%nonassoc NOT
%nonassoc UMINUS 
%nonassoc UPLUS
%right INDEX_OPEN
%%
s: expr SEMICOL { printf("parsed successfully!%d:%d\n",yylineno,col);return 0; }

program: functions;

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT  
    ;

value: literal | ID ;

string: ID | LIT_STRING ;

type: BOOL 
    | CHAR 
    | STRING 
    | INT 
    | FLOAT 
    | REAL 
    ;
    
/* ptype: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT ; */

dec: declr_vars | dec declr_vars ;
declr_vars: VAR type COLON ID ass vars SEMICOL { printf("%s",yytext); }
vars: vars COMMA ID ass | ;
ass: ASS value | ;

expr: value 
    | PARENT_OPEN expr PARENT_CLOSE 
    | opt_unary 
    | STRLEN string STRLEN
    | string INDEX_OPEN expr INDEX_CLOSE %prec INDEX_OPEN
    | opt_binary;

opt_unary: NOT expr
    | '-' expr %prec UMINUS
    | '+' expr %prec UPLUS
    | '*' expr %prec DEREF
    | REF expr
    ;

opt_binary:expr '+' expr
    | expr '-' expr 
    | expr '*' expr 
    | expr DIV expr
    | expr AND expr
    | expr OR expr
    | expr EQ expr
    | expr NOT_EQ expr
    | expr GRTR expr
    | expr GRTR_EQ expr
    | expr LESS expr
    | expr LESS_EQ expr
    ;

/* if_stmt: IF PARENT_OPEN expr PARENT_CLOSE BLOCK_OPEN block BLOCK_CLOSE else_stmt
       | IF PARENT_OPEN expr PARENT_CLOSE stmt else_stmt ;
else_stmt: ELSE BLOCK_OPEN block BLOCK_CLOSE
         | ELSE stmt | ;

block: stmt; */

func_call: lhs ASS ID PARENT_OPEN func_expr PARENT_CLOSE SEMICOL
         | ID PARENT_OPEN func_expr PARENT_CLOSE SEMICOL ;
func_expr: func_expr COMMA expr | expr | ;



ass_stmt: lhs ASS expr SEMICOL ;
lhs: ID | ID INDEX_OPEN expr INDEX_CLOSE ; 


functions: functions function | function;
function: modifier func_void | modifier func_ret;

modifier: PUBLIC | PRIVATE;
static: COLON STATIC | ;
params: | ARGS lists;
lists: lists SEMICOL list | list;
list: list COMMA ID | ID;

func_ret: type ID PARENT_OPEN params PARENT_CLOSE static BLOCK_OPEN bodyRet BLOCK_CLOSE;
func_void: VOID ID PARENT_OPEN params PARENT_CLOSE static BLOCK_OPEN body BLOCK_CLOSE;
bodyRet: body return;
body: ;
return: RETURN

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


