%{
#include <stdio.h>
#define YYDEBUG 1
int yydebug = 1;
int yylex();
int yyerror(const char* s);
typedef enum bool{
    false, 
    true
}bool;
typedef struct string{
    char*   str;
    unsigned int   size;
}string;

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

%token REF DEREF
%token ID ',' STRLEN VAR
%token ARGS PUBLIC PRIVATE STATIC RETURN MAIN ASS
%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR  
%token STRING   VOID 
%token LIT_STRING 
%token P_INT P_FLOAT P_REAL P_CHAR
%token WHILE DO FOR
%token IF ELSE

%token  <_int>      LIT_INT     INT
%token  <_float>    LIT_FLOAT   FLOAT
%token  <_real>     LIT_REAL    DOUBLE
%token  <_char>     LIT_CHAR    CHAR
%token  <_bool>     LIT_BOOL    BOOL
%token  <_nullptr>  NULLPTR

%left ','
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
%right '['
%%
s: dec_variables ';' s | { printf("parsed successfully!\n");return 0; }

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT 
    | LIT_STRING ;

value: literal 
    | ID ;

type: BOOL 
    | CHAR 
    | STRING 
    | INT 
    | FLOAT 
    | DOUBLE ;
    
/* type_pointer: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT ; */

dec_variables: type ':' ID vars | ;
vars: ',' ID ass vars | ;
ass: ASS value | ;


/* expr: arith;

arith: 
    |ADD expr { $$ = $1; }
    |SUB expr {$$ = -1 * $1; }

comp:;
logic:expr OR expr;
mem_access:; */

%%
#include "lex.yy.c"
int main(){
    return yyparse();
}


int yyerror(const char* s){
    fprintf(stderr,"Syntax error in <%d,%d> \"%s\"\n", yylineno,col, yytext);
    return 0;
}
