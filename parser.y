%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define printdent(out,x) for(int _ = 0; _ < x; _++) fprintf(out,"|   ")

typedef enum {
    false, 
    true
} bool;

typedef struct{
    char* token;
    struct tree** children;
    unsigned int num_children;
}tree;

char* yytext;
int yylineno, col;
bool flag = 0;
int yylex();
int yyerror(const char* s);


void    printree(tree* root);
void    indentree(FILE* output, tree* root, int level);
tree*   mknode(char* token);
tree*   mkunary(char* token, tree* child);
tree*   mkbinary(char* token, tree* left, tree* right);
void    killtree(tree* root);
void    add(tree* root, tree* child);
bool    isleaf(tree* root) { return root->num_children == 0; }
%}
%union {
    char* str;
    struct tree* node;
}

%token<node> IF ELSE
%token<node> WHILE DO FOR
%token<str> ID
%token<node> VAR ASS STRLEN
%token<node> ARGS STATIC RETURN MAIN VOID
%token<node> PUBLIC PRIVATE 

%token<str> AND EQ GRTR GRTR_EQ LESS LESS_EQ NOT NOT_EQ OR  
%token<str> DIV '-' '+' '*'
%token<str> DEREF REF

%token<str> COLON SEMICOL COMMA 
%token<str> BLOCK_OPEN BLOCK_CLOSE 
%token<str> PARENT_OPEN PARENT_CLOSE 
%token<str> INDEX_OPEN INDEX_CLOSE

%token<str>  LIT_INT INT
%token<str>  LIT_FLOAT FLOAT
%token<str>  LIT_REAL REAL
%token<str>  LIT_CHAR CHAR
%token<str>  LIT_BOOL BOOL
%token<str>  NULLPTR
%token<str>  P_INT
%token<str>  P_FLOAT
%token<str>  P_REAL
%token<str>  P_CHAR
%token<str>  LIT_STRING STRING

%type<node> s program functions function func func_ret func_void modifier dec declr_vars vars while do init for loop_stmt


%type<node> expr opt_unary opt_binary string value  type ptype ass
%type<str> literal

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
s: dec  { 
                printf("parsed successfully! %d:%d\n", yylineno, col);
                printree($1);

            }

program: functions ;


/* ============== FUNCTIONS ============== */
functions   : functions function 
            | function  
            ;

function    : modifier func 
            | error {yyerror("missing modifier!\n");}
            ;

modifier    : PUBLIC    
            | PRIVATE
            ;

func        : func_void 
            | func_ret
            ;

func_ret    : type { if(flag==1)flag=-1; } func_sign BLOCK_OPEN ret_body  { if(flag==-1)flag=1; } BLOCK_CLOSE;

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

nested_stmt_body: code_block ;
code_block: BLOCK_OPEN block BLOCK_CLOSE | BLOCK_OPEN  BLOCK_CLOSE;
block: dec 
    | dec ret_stmts 
    | ret_stmts ;

/* ============== STATEMENTS ============== */
stmts:  ret_stmt stmts | return ;
stmt: ass_stmt | func_call SEMICOL | if_stmt  | if_else_stmt  | loop_stmt | code_block ;
ret_stmts: ret_stmt ret_stmts | ret_stmt ;
ret_stmt: stmt | return ;

func_call: ID PARENT_OPEN func_expr PARENT_CLOSE ;
func_expr: func_expr COMMA expr | expr | ;

ass_stmt: lhs ASS expr SEMICOL;
lhs: ID | ID INDEX_OPEN expr INDEX_CLOSE | DEREF ; 

if_stmt: IF PARENT_OPEN expr PARENT_CLOSE  nested_stmt_body  %prec IFX;

if_else_stmt: IF PARENT_OPEN expr PARENT_CLOSE nested_stmt_body ELSE nested_stmt_body ;

loop_stmt: for | while | do;

for: FOR PARENT_OPEN init SEMICOL expr SEMICOL ID ASS expr PARENT_CLOSE nested_stmt_body;

init        : ID ASS expr 
            ;

do          : DO nested_stmt_body WHILE PARENT_OPEN expr PARENT_CLOSE SEMICOL
            ;

while       : WHILE PARENT_OPEN expr PARENT_CLOSE nested_stmt_body 
            ;

/* ============== DECLARATIONS ============== */
dec         : dec declr_vars { $$ = $1; add($$, $2); }
            | declr_vars { $$ = mkunary("VAR",$1); }
            ;

declr_vars  : VAR type COLON  vars SEMICOL { $$ = $2; add($$, $4); }
            | VAR ID { yyerror("missing type!\n"); }
            ;

vars        : vars COMMA ID ass { add($1, mkunary($3, $4)); $$ = $1; }
            |   ID ass { $$ = mkunary("", mkunary($1, $2)); }
            ;

ass         : ASS expr { $$ = $2; }
            |   { $$ = NULL; }
            ;

/* ============== EXPRESSIONS ============== */
expr        : value                             { $$ = $1; }
            | opt_unary                         { $$ = $1; }
            | opt_binary                        { $$ = $1; }
            | STRLEN string STRLEN              { $$ = mkunary("STRLEN-OF ",$2); }
            | PARENT_OPEN expr PARENT_CLOSE     { $$ = $2; }
            | PARENT_OPEN expr PARENT_CLOSE     { $$ = $2; }
            | ID         INDEX_OPEN expr INDEX_CLOSE %prec INDEX_OPEN { $$ = mkbinary("CHAR-AT ", mknode($1), $3); }
            | LIT_STRING INDEX_OPEN expr INDEX_CLOSE %prec INDEX_OPEN { $$ = mkbinary("CHAR-AT ", mknode($1), $3); }
            | func_call  { $$ = mknode("FUNC-CALL"); }; 

opt_unary   : NOT expr                  { $$ = mkunary("NOT", $2); }
            | REF expr                  { $$ = mkunary("REF", $2); }
            | '-' expr %prec UMINUS     { $$ = mkunary("-", $2); }
            | '+' expr %prec UPLUS      { $$ = $2; }
            | '*' expr %prec DEREF      { $$ = mkunary("DEREF", $2); }
            ;

opt_binary  : expr '+' expr             { $$ = mkbinary("+", $1, $3); }
            | expr '-' expr             { $$ = mkbinary("-", $1, $3); }
            | expr '*' expr             { $$ = mkbinary("*", $1, $3); }
            | expr DIV expr             { $$ = mkbinary("/", $1, $3); }
            | expr AND expr             { $$ = mkbinary("AND", $1, $3); }
            | expr OR expr              { $$ = mkbinary("OR", $1, $3); }
            | expr EQ expr              { $$ = mkbinary("==", $1, $3); }
            | expr GRTR expr            { $$ = mkbinary(">", $1, $3); }
            | expr LESS expr            { $$ = mkbinary("<", $1, $3); }
            | expr NOT_EQ expr          { $$ = mkbinary("!=", $1, $3); }
            | expr GRTR_EQ expr         { $$ = mkbinary(">=", $1, $3); }
            | expr LESS_EQ expr         { $$ = mkbinary("<=", $1, $3); }
            ;
/* 
expr_bool   : NOT expr_bool             { $$ = mkunary("NOT", $1); }
            | expr_bool AND expr_bool   { $$ = mkbinary("AND", $1, $3); }
            | expr_bool OR expr_bool    { $$ = mkbinary("OR", $1, $3); }
            | expr_num EQ expr_num      { $$ = mkbinary("EQ", $1, $3); }
            | expr_bool EQ expr_bool    { $$ = mkbinary("EQ", $1, $3); }
            | expr_num NOT_EQ expr_num  { $$ = mkbinary("AND", $1, $3); }
            | expr_bool NOT_EQ expr_bool{ $$ = mkbinary("AND", $1, $3); }
            | expr_num GRTR expr_num    { $$ = mkbinary("AND", $1, $3); }
            | expr_num GRTR_EQ expr_num { $$ = mkbinary("AND", $1, $3); }
            | expr_num LESS expr_num    { $$ = mkbinary("AND", $1, $3); }
            | expr_num LESS_EQ expr_num { $$ = mkbinary("AND", $1, $3); }
            ;

expr_num    :
            ; 
*/

/* ============== TYPES - VALUES ============== */
literal : LIT_BOOL      { $$ = mknode($1); }
        | LIT_CHAR      { $$ = mknode($1); }
        | LIT_REAL      { $$ = mknode($1); }
        | LIT_FLOAT     { $$ = mknode($1); }
        | LIT_INT       { $$ = mknode($1); }
        | NULLPTR       { $$ = mknode($1); }
        ;

value   : literal       { $$ = $1; }
        | ID            { $$ = mknode($1); }
        | LIT_STRING    { $$ = mknode($1); }
        ;

string  : ID            { $$ = mknode(yytext); }
        | LIT_STRING    { $$ = mknode(yytext); }
        ;

type    : BOOL          { $$ = mknode("BOOL"); }
        | CHAR          { $$ = mknode("CHAR"); }
        | INT           { $$ = mknode("INT"); }
        | FLOAT         { $$ = mknode("FLOAT"); }
        | REAL          { $$ = mknode("DOUBLE"); }
        | ptype         { $$ = $1; }
        ;

ptype   : P_CHAR        { $$ = mknode("CHAR*"); }
        | P_REAL        { $$ = mknode("DOUBLE*"); }
        | P_FLOAT       { $$ = mknode("FLOAT*"); }
        | P_INT         { $$ = mknode("INT*"); }
        ;
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
    exit(EXIT_FAILURE);
    return 1;
}

void printree(tree* root) {
    indentree(stdout, root, 0);
}

void indentree(FILE* output, tree* root, int level) {
    if (root == NULL)
        return;
    if (isleaf(root)) {
        printdent(output, level);
        fprintf(output, "%s", root->token);
        return;
    }
    /* if(root->num_children == 1){
        printdent(output, level);
        fprintf(output, "%s %s", root->token, ((root->children)[0])->token);
        indentree(output,root->children[0], level+1);
        return;
    } */

    printdent(output, level);
    fprintf(output, "(%s", root->token);
    for (unsigned int i = 0; i < root->num_children; i++) {
        fprintf(output, "\n");
        indentree(output, root->children[i], level + 1);
    }
    fprintf(output, "\n");
    printdent(output, level);
    fprintf(output, ")");
}

//return NULL if failed
tree* mknode(char* token) {
    tree* newtree = (tree*)malloc(sizeof(tree));
    if(newtree == NULL)
        return NULL;
    newtree->token = strdup(token);
    newtree->children = NULL;
    newtree->num_children = 0;
    return newtree;
}

//return NULL if failed
tree* mkunary(char* token, tree* child) {
    tree* newtree = (tree*)malloc(sizeof(tree));
    if(newtree == NULL)
        return NULL;
    if(child){
        newtree->children = (tree**)malloc(sizeof(tree*));
        if(newtree->children == NULL){
            free(newtree);
            return NULL;
        }
        newtree->num_children = 1;
        newtree->children[0] = child;
    }
    else{
        newtree->children = NULL;
        newtree->num_children = 0;
    }
    newtree->token = strdup(token);
    return newtree;
}

//return NULL if failed
tree* mkbinary(char* token, tree* left, tree* right) {
    tree* newtree = (tree*)malloc(sizeof(tree));
    if(newtree == NULL)
        return NULL;
    newtree->children = (tree**)malloc(2 * sizeof(tree*));
    if(newtree->children == NULL){
        free(newtree);
        return NULL;
    }
    newtree->num_children = 2;
    newtree->children[0] = left;
    newtree->children[1] = right;
    newtree->token = strdup(token);
    return newtree;
}

void killtree(tree* root) {
    if (root == NULL)
        return;
    for (unsigned int i = 0; i < root->num_children; i++)
        killtree(root->children[i]);
    free(root->token);
    if(root->children != NULL)
        free(root->children);
    free(root);
}

//adds `child` to `root` attribute `children`. does nothing if root or child is NULL.
void add(tree* root, tree* child) {
    if(root == NULL || child == NULL)
        return;
    tree** newchld = (tree**)realloc(root->children, (root->num_children + 1) * sizeof(tree*));
    if(newchld == NULL){
        killtree(root);
        yyerror("ERROR CREATING AST!\n");
    }
    root->children = newchld;
    root->children[root->num_children++] = child;
}