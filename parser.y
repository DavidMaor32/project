%{
#include <stdio.h>
#include <string.h>
#define printdent(x) for(int _ = 0; _ < x; _++) printf("\t");
int yylex();
int yyerror(const char* s);
int yylineno, col;
char* yytext;
typedef enum {
    false, 
    true
} bool;

bool flag = 0;

typedef struct {
    char* str;
    unsigned int size;
} string;

// typedef struct{
//     char* token;
//     struct node* left;
//     struct node* right;
// }node;

// node* mknode(char* token, node* left, node* right);
// void printree(node* tree);
// void indentree(node* tree, int level);

%}
%union {
    int _int;
    float _float;
    double _real;
    char _char;
    bool _bool;
    struct string* _str;
    int* p_int;
    float* p_float;
    double* p_real;
    char* p_char;
    void* _nullptr;
    struct node* node;
}

%token IF ELSE
%token WHILE DO FOR
%token ID STRLEN VAR ASS
%token PUBLIC PRIVATE ARGS STATIC RETURN MAIN VOID

%token AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR  
%token DIV '-' '+' '*'
%token DEREF REF

%token COLON SEMICOL COMMA 
%token BLOCK_OPEN BLOCK_CLOSE 
%token PARENT_OPEN PARENT_CLOSE 
%token INDEX_OPEN INDEX_CLOSE

%token  LIT_INT INT
%token  LIT_FLOAT FLOAT
%token  LIT_REAL REAL
%token  LIT_CHAR CHAR
%token  LIT_BOOL BOOL
%token  NULLPTR
%token  P_INT
%token  P_FLOAT
%token  P_REAL
%token  P_CHAR
%token  LIT_STRING STRING


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
s: program  { 
                
                 printf("parsed successfully! %d:%d\n", yylineno, col); return 0; 
                // printree($1);
            }

program: functions ;


/* ============== FUNCTIONS ============== */
functions: functions function | function  ;
function: modifier func | error {yyerror("missing modifier!\n");}
modifier: PUBLIC | PRIVATE;
func: func_void | func_ret;

func_ret: type { if(flag==1)flag=-1; } func_sign BLOCK_OPEN ret_body  { if(flag==-1)flag=1; }BLOCK_CLOSE ;

func_void: VOID { flag=1; } func_sign BLOCK_OPEN  body  BLOCK_CLOSE { flag=0; }

func_sign: ID PARENT_OPEN params PARENT_CLOSE static;
static: COLON STATIC | ;
params: ARGS lists | ;
lists: dec_str
    | lists SEMICOL type COLON list 
    | type COLON list
    | type list { yyerror("missing ':'"); }

dec_str: STRING COLON strs ;
strs: strs COMMA ID size | ID size ;
size: INDEX_OPEN LIT_INT INDEX_CLOSE ;

list: list COMMA ID | ID ;
return: {if(strcmp(yytext, "return")!=0) yyerror("missing return statement!\n");} RETURN  expr SEMICOL {if (flag==1)yyerror("void function can't return!\n");} 

/* ============== BODY - BLOCK  ============== */
body: dec
    | functions
    | ret_stmts
    | dec functions
    | dec ret_stmts
    | functions ret_stmts 
    | dec functions ret_stmts 
    |;

ret_body: stmts
    | dec stmts
    | functions stmts 
    | dec functions stmts  ;

nested_stmt_body: code_block | ret_stmt ;
code_block: BLOCK_OPEN ret_stmts BLOCK_CLOSE | BLOCK_OPEN  BLOCK_CLOSE;
block: dec 
    | dec ret_stmts 
    | ret_stmts ;

/* ============== STATEMENTS ============== */
stmts:  ret_stmt stmts | return ;
stmt: ass_stmt | func_call  | if_stmt  | if_else_stmt  | loop_stmt | code_block ;
ret_stmts: ret_stmt ret_stmts | ret_stmt ;
ret_stmt: stmt | return ;

func_call: ID PARENT_OPEN func_expr PARENT_CLOSE SEMICOL ;
func_expr: func_expr COMMA expr | expr | ;

ass_stmt: lhs ASS expr SEMICOL | lhs ASS func_call ;
lhs: ID | ID INDEX_OPEN expr INDEX_CLOSE | DEREF ; 

if_stmt: IF PARENT_OPEN expr PARENT_CLOSE  nested_stmt_body  %prec IFX;

if_else_stmt: IF PARENT_OPEN expr PARENT_CLOSE nested_stmt_body ELSE nested_stmt_body ;

loop_stmt: for | while | do;

for: FOR PARENT_OPEN init SEMICOL expr SEMICOL ID ASS expr PARENT_CLOSE nested_stmt_body;
init: ID ASS expr;

do: DO nested_stmt_body WHILE PARENT_OPEN expr PARENT_CLOSE SEMICOL;
while: WHILE PARENT_OPEN expr PARENT_CLOSE nested_stmt_body;

/* ============== DECLARATIONS ============== */
dec: dec declr_vars | declr_vars;
declr_vars: VAR type COLON ID ass vars SEMICOL 
    | VAR ID { yyerror("missing type!\n"); };
vars: vars COMMA ID ass |;
ass: ASS expr |;

/* ============== EXPRESSIONS ============== */
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
    | REF expr;

opt_binary: expr '+' expr
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
    | expr LESS_EQ expr;

/* ============== TYPES - VALUES ============== */
literal: LIT_BOOL 
    | LIT_CHAR 
    | LIT_REAL 
    | LIT_FLOAT 
    | LIT_INT;

value: literal | ID | LIT_STRING ;

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

/* node* mknode(char* token, node* left, node* right){
    node* newnode = (node*)malloc(sizeof(node));
    newnode->token = strdup(token); 
    newnode->left = left;
    newnode->right = right;
    return newnode;
}

void printree(node* tree){
    indentree(tree, 0);
}

void indentree(node* tree, int level){
    
} */