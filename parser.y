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

/* program: dec; */

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT  
    ;

value: literal | ID ;

string: ID | LIT_STRING ;

/* type: BOOL 
    | CHAR 
    | STRING 
    | INT 
    | FLOAT 
    | REAL 
    ; */
    
/* ptype: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT ; */

/* dec: declr_vars | dec declr_vars ; */
/* declr_vars: VAR type COLON ID ass vars SEMICOL { printf("%s",yytext); } */
/* vars: vars COMMA ID ass | ;
ass: ASS value | ; */


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
    
    

    /*maybe expr = expr*/
    ;

/* 
var_str:ID INDEX_OPEN LIT_INT INDEX_CLOSE ; 

stmts: stmnts stmt SEMICOL | ;
stmt: 
    | ID ASS value
    | funcall
    | stmt_if
    | stmt_loop
    | block
    ;

stmt_if: IF PARENT_OPEN expr PARENT_CLOSE stmnt
    | IF PARENT_OPEN expr PARENT_CLOSE stmnt ELSE stmt 

stmt_loop: stmt_for | stmt_while | stmt_do

*/

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


