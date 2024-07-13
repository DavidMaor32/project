%{
#include <stdio.h>
int yylex();
int yyerror(const char* s);
int yylineno, col;
char* yytext;
typedef enum {
    false, 
    true
} bool;
typedef struct {
    char* str;
    unsigned int size;
} string;
%}
%union {
    int _int;
    float _float;
    double _real;
    char _char;
    bool _bool;
    string _str;
    int* p_int;
    float* p_float;
    double* p_real;
    char* p_char;
    void* _nullptr;
}

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

%token <_int> LIT_INT INT
%token <_float> LIT_FLOAT FLOAT
%token <_real> LIT_REAL REAL
%token <_char> LIT_CHAR CHAR
%token <_bool> LIT_BOOL BOOL
%token <_nullptr> NULLPTR
%token <p_int> P_INT
%token <p_float> P_FLOAT
%token <p_real> P_REAL
%token <p_char> P_CHAR
%token <p_char> LIT_STRING STRING

%left COMMA
%right ASS
%left OR
%left AND
%nonassoc EQ NOT_EQ
%nonassoc LESS LESS_EQ GRTR GRTR_EQ
%left '+' '-'
%left '*' DIV
%nonassoc IFX
%nonassoc ELSE
%nonassoc REF
%nonassoc DEREF 
%nonassoc NOT
%nonassoc UMINUS 
%nonassoc UPLUS
%right INDEX_OPEN
%%
s: program { printf("parsed successfully! %d:%d\n", yylineno, col); return 0; }

program: functions;

literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT;

value: literal | ID;

string: ID | LIT_STRING;

type: BOOL 
    | CHAR 
    | INT 
    | FLOAT 
    | REAL 
    | ptype;

ptype: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT;

functions: function 
    | functions function;

function: modifier func;
func: func_void | func_ret;

modifier: PUBLIC | PRIVATE;

func_ret: type func_sign BLOCK_OPEN block return BLOCK_CLOSE
    | type func_sign BLOCK_OPEN block BLOCK_CLOSE { yyerror("missing return statement!"); }

func_void: VOID func_sign BLOCK_OPEN block BLOCK_CLOSE
    | VOID func_sign BLOCK_OPEN block RETURN { yyerror("void function can't return value"); } 

func_sign: ID PARENT_OPEN params PARENT_CLOSE static;
static: COLON STATIC |;
params: ARGS lists |;
lists: dec_str
    | lists SEMICOL type COLON list 
    | type COLON list
    | type list { yyerror("missing ':'"); }

dec_str: STRING strs;
strs: strs COMMA ID size | ID size;
size: INDEX_OPEN LIT_INT INDEX_CLOSE;
list: list COMMA ID | ID;
return: RETURN expr SEMICOL;

<<<<<<< HEAD
block: dec functions stmts
=======

block: dec functions 
>>>>>>> c83d19f47b2a839411004f68cd2b17b77948e121
    | dec stmts
    | functions stmts
    | stmts 
    | dec |
    ;

<<<<<<< HEAD
stmts: stmts stmt | stmt ;
=======
stmts: ;
>>>>>>> c83d19f47b2a839411004f68cd2b17b77948e121


stmt: ass_stmt | func_call | if_stmt | if_else_stmt | loop_stmt; 

if_stmt: IF PARENT_OPEN expr PARENT_CLOSE body %prec IFX;
if_else_stmt: IF PARENT_OPEN expr PARENT_CLOSE body ELSE body;

body: stmt | BLOCK_OPEN stmts BLOCK_CLOSE | BLOCK_OPEN BLOCK_CLOSE;

<<<<<<< HEAD
func_call: lhs ASS ID PARENT_OPEN func_expr PARENT_CLOSE SEMICOL
    | ID PARENT_OPEN func_expr PARENT_CLOSE SEMICOL;
=======
type: BOOL 
    | CHAR
    | INT 
    | FLOAT 
    | REAL 
    |ptype
    ;
    
ptype: P_CHAR 
    | P_REAL 
    | P_FLOAT 
    | P_INT ;
>>>>>>> c83d19f47b2a839411004f68cd2b17b77948e121

func_expr: func_expr COMMA expr | expr |;

ass_stmt: lhs ASS expr SEMICOL;
lhs: ID | ID INDEX_OPEN expr INDEX_CLOSE;

loop_stmt: for | while | do;

for: FOR PARENT_OPEN init SEMICOL expr SEMICOL ID ASS expr PARENT_CLOSE body;
init: ID ASS expr;

do: DO body WHILE PARENT_OPEN expr PARENT_CLOSE SEMICOL;
while: WHILE PARENT_OPEN expr PARENT_CLOSE body;

dec: declr_vars | dec declr_vars;
declr_vars: VAR type COLON ID ass vars SEMICOL 
    | VAR ID { yyerror("missing type"); };
vars: vars COMMA ID ass |;
ass: ASS expr |;

expr: value 
    | PARENT_OPEN expr PARENT_CLOSE 
    | opt_unary 
    | STRLEN string STRLEN
    | string INDEX_OPEN expr INDEX_CLOSE %prec INDEX_OPEN
    | opt_binary;

opt_unary: NOT expr
    | '-' expr %prec UMINUS
    | '+' expr %prec UPLUS
    | '*' expr %prec DEREF {printf("DEREF \n");}
    | REF expr;

opt_binary: expr '+' expr
    | expr '-' expr 
    | expr '*' expr {printf("MUL \n");}
    | expr DIV expr
    | expr AND expr
    | expr OR expr
    | expr EQ expr
    | expr NOT_EQ expr
    | expr GRTR expr
    | expr GRTR_EQ expr
    | expr LESS expr
    | expr LESS_EQ expr;

%%

#include "lex.yy.c"
#ifdef YYDEBUG
  int yydebug = 1;
#endif

int main() {
    return yyparse();
}

int yyerror(const char* s) {
    fprintf(stderr, "\n<%d:%d> ERROR: \"%s\"\tTOKEN:%s\n", yylineno, col, s, yytext);
    exit(1);
    return 1;
}
