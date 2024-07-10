/*
program: function
*/
%{
#include <stdio.h>
int yylex();
int yyerror(const char* s);
%}

%token COMMENT_OPEN COMMENT_END
%token REF DEREF
%token IDENTIFIER  SEMICOL COMMA STRLEN VAR
%token ARGS PUBLIC PRIVATE STATIC RETURN MAIN
%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR 
%token BLOCK_OPEN BLOCK_CLOSE BRACKET_OPEN BRACKET_CLOSE INDEX_OPEN INDEX_CLOSE
%token BOOL CHAR STRING INT FLOAT DOUBLE VOID NULLPTR COLON
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
%right INDEX_OPEN
%%
s: dec_variables { printf("parsed successfully!\n"); }

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
%%
#include "lex.yy.c"
int main(){
    return yyparse();
}

int yyerror(const char* s){
    printf("Syntax error in line %d", yylineno);
    return 0;
}
