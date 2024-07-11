%{
#include <stdio.h>
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
    int     type_integer;
    float   type_float;
    double  type_double;
    char    type_char;
    bool    type_bool;
    string  type_string;
    int*     type_pinteger;
    float *  type_pfloat;
    double*  type_pdouble;
    char*    type_pchar;
    
    void*   type_null;
};

%token REF DEREF
%token IDENTIFIER  SEMICOL COMMA STRLEN VAR
%token ARGS PUBLIC PRIVATE STATIC RETURN MAIN ASS
%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR 
%token BLOCK_OPEN BLOCK_CLOSE BRACKET_OPEN BRACKET_CLOSE INDEX_OPEN INDEX_CLOSE
%token STRING   VOID COLON
%token LIT_STRING 
%token PTR_INT PTR_FLOAT PTR_DOUBLE PTR_CHAR
%token WHILE DO FOR
%token IF ELSE

%token  <type_integer>  LIT_INT     INT
%token  <type_float>    LIT_FLOAT   FLOAT
%token  <type_double>   LIT_DOUBLE  DOUBLE
%token  <type_char>     LIT_CHAR    CHAR
%token  <type_bool>     LIT_BOOL    BOOL
%token  <type_null>     NULLPTR

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
%right INDEX_OPEN
%%
s: dec_variables SEMICOL s | { printf("parsed successfully!\n");return 0; }

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_DOUBLE 
    | LIT_FLOAT 
    | LIT_INT 
    | LIT_STRING ;

value: literal 
    | IDENTIFIER ;

type: BOOL 
    | CHAR 
    | STRING 
    | INT 
    | FLOAT 
    | DOUBLE ;
    
type_pointer: PTR_CHAR 
    | PTR_DOUBLE 
    | PTR_FLOAT 
    | PTR_INT ;

dec_variables: type COLON IDENTIFIER vars | ;
vars: COMMA IDENTIFIER ass vars | ;
ass: ASS value | ;


expr: ;
arith: 
    |ADD expr { $$ = $1; }
    |MINUS expr {$$ = -1 * $1; }

comp:;
logic:expr OR expr;
mem_access:;

%%
#include "lex.yy.c"
int main(){
    return yyparse();
}


int yyerror(const char* s){
    fprintf(stderr,"Syntax error in <%d,%d> \"%s\"\n", yylineno,col, yytext);
    return 0;
}
