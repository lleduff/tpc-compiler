%{
#include <stdio.h>
#include <string.h>
#include "tree.h"
int yyparse();
int yylex();
void yyerror(char *s);
int yyrestart();
int res;
int printtree;

extern int line;
%}

%union {
    struct Node *node;
    char ident[64];
    int num;

}

%token <ident> IDENT CHARACTER OR AND EQ ORDER ADDSUB DIVSTAR TYPE
%token VOID
%token <num> NUM
%token IF
%token ELSE
%token WHILE
%token RETURN
%token SWITCH
%token BREAK
%token DEFAULT
%token CASE


%type <node> Prog DeclVars Declarateurs DeclFoncts DeclFonct EnTeteFonct Parametres ListTypVar Corps SuiteInstr SuiteSwitch Instr Exp TB FB M E T F LValue Arguments ListExp


%%
Prog:  DeclVars DeclFoncts                          { $$ = makeNode(Prog); addChild($$, $1); addChild($$, $2); if (printtree) { printTree($$); } ; deleteTree($$); }
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'               { $$ = $1; Node *t = makeNode(_TYPE); addChild($$, t); addChild(t, $3); strcpy(t->attributes.ident, $2); }
    |                                               { $$ = makeNode(DeclVars); }
    ;
Declarateurs:
       Declarateurs ',' IDENT                       { $$ = $1; Node *t = makeNode(_IDENT); addSibling($$, t); strcpy(t->attributes.ident, $3); }
    |  IDENT                                        { $$ = makeNode(_IDENT); strcpy($$->attributes.ident, $1); }
    ;
DeclFoncts:
       DeclFoncts DeclFonct                         { $$ = $1; addChild($$, $2); }
    |  DeclFonct                                    { $$ = makeNode(DeclFoncts); addChild($$, $1); }
    ;
DeclFonct:
       EnTeteFonct Corps                            { $$ = makeNode(DeclFonct); addChild($$, $1); addChild($$, $2); }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'                { Node *id, *id2; $$ = makeNode(EnTeteFonct); addChild($$, id = makeNode(_TYPE)); addChild($$, id2 = makeNode(_IDENT)); addChild($$, $4); strcpy(id->attributes.ident, $1); strcpy(id2->attributes.ident, $2);}
    |  VOID IDENT '(' Parametres ')'                { Node *id; $$ = makeNode(EnTeteFonct); addChild($$, makeNode(_VOID)); addChild($$, id = makeNode(_IDENT)); addChild($$, $4); strcpy(id->attributes.ident, $2); }
    ;
Parametres:
       VOID                                         { $$ = makeNode(Parametres); addChild($$, makeNode(_VOID)); }             
    |  ListTypVar                                   { $$ = makeNode(Parametres); addChild($$, $1); }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT                    { Node *id, *id2; $$ = makeNode(ListTypVar); addChild($$, $1); addChild($$, id = makeNode(_TYPE)); addChild($$, id2 = makeNode(_IDENT)); strcpy(id->attributes.ident, $3); strcpy(id2->attributes.ident, $4); }
    |  TYPE IDENT                                   { Node *id, *id2; $$ = makeNode(ListTypVar); addChild($$, id = makeNode(_TYPE)); addChild($$, id2 = makeNode(_IDENT)); strcpy(id->attributes.ident, $1); strcpy(id2->attributes.ident, $2); }
    ;
Corps: '{' DeclVars SuiteInstr '}'                  { $$ = makeNode(Corps); addChild($$, $2); addChild($$, $3); }
    ;
SuiteInstr:
       SuiteInstr Instr                             { $$ = $1; addChild($$, $2); }  
    |                                               { $$ = makeNode(SuiteInstr); }
    ;
SuiteSwitch:
        SuiteSwitch CASE Exp ':' 
    |   SuiteSwitch CASE Exp ':' Instr BREAK ';'    { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_CASE)); addChild($$, $3); addChild($$, $5); addChild($$, makeNode(_BREAK)); }
    |   SuiteSwitch CASE Exp ':' Instr              { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_CASE)); addChild($$, $3); addChild($$, $5); }
    |   SuiteSwitch CASE Exp ':' BREAK ';'          { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_CASE)); addChild($$, $3); addChild($$, makeNode(_BREAK)); }
    |   SuiteSwitch DEFAULT ':' Instr               { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_DEFAULT)); addChild($$, $4); }
    |   SuiteSwitch DEFAULT ':' Instr BREAK ';'     { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_DEFAULT)); addChild($$, $4); addChild($$, makeNode(_BREAK)); }
    |   SuiteSwitch DEFAULT ':' BREAK ';'           { $$ = makeNode(SuiteSwitch); addChild($$, $1); addChild($$, makeNode(_DEFAULT)); addChild($$, makeNode(_BREAK)); }
    |                                               { $$ = makeNode(SuiteSwitch); }
    ;
Instr:
       LValue '=' Exp ';'                           { $$ = makeNode(_AFFECTATION); addChild($$, $1); addChild($$, $3); }
    |  IF '(' Exp ')' Instr                         { $$ = makeNode(_IF); addChild($$, $3); addChild($$, $5); }
    |  IF '(' Exp ')' Instr ELSE Instr              { $$ = makeNode(_IF); addChild($$, $3); addChild($$, $5); addChild($$, makeNode(_ELSE)); addChild($$, $7); }
    |  WHILE '(' Exp ')' Instr                      { $$ = makeNode(_WHILE); addChild($$, $3); addChild($$, $5); }
    |  SWITCH '(' Exp ')' '{' SuiteSwitch '}'       { $$ = makeNode(_SWITCH); addChild($$, $3); addChild($$, $6); }    
    |  IDENT '(' Arguments  ')' ';'                 { $$ = makeNode(_IDENT); strcpy($$->attributes.ident, $1); addChild($$, $3); }
    |  RETURN Exp ';'                               { $$ = makeNode(_RETURN); addChild($$, $2); }
    |  RETURN ';'                                   { $$ = makeNode(_RETURN); }
    |  '{' SuiteInstr '}'                           { $$ = $2; }
    |  ';'                                          { $$ = NULL; }
    ;
Exp :  Exp OR TB                                    { $$ = makeNode(_OR); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  TB                                           { $$ = $1; }
    ;
TB  :  TB AND FB                                    { $$ = makeNode(_AND); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  FB                                           { $$ = $1; }
    ;
FB  :  FB EQ M                                      { $$ = makeNode(_EQ); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  M                                            { $$ = $1; }
    ;
M   :  M ORDER E                                    { $$ = makeNode(_ORDER); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  E                                            { $$ = $1; }
    ;
E   :  E ADDSUB T                                   { $$ = makeNode(_ADDSUB); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  T                                            { $$ = $1; }
    ;
T   :  T DIVSTAR F                                  { $$ = makeNode(_DIVSTAR); addChild($$, $1); addChild($$, $3); strcpy($$->attributes.ident, $2); }
    |  F                                            { $$ = $1; }
    ;
F   :  ADDSUB F                                     { $$ = makeNode(_ADDSUB); addChild($$, $2); strcpy($$->attributes.ident, $1); }
    |  '!' F                                        { $$ = $2; }
    |  '(' Exp ')'                                  { $$ = $2; }
    |  NUM                                          { $$ = makeNode(_NUM); $$->attributes.num = $1; }
    |  CHARACTER                                    { $$ = makeNode(_CHARACTER); strcpy($$->attributes.ident, $1); }
    |  LValue                                       { $$ = $1; }
    |  IDENT '(' Arguments  ')'                     { $$ = makeNode(_IDENT); addChild($$, $3); strcpy($$->attributes.ident, $1); }
    ;
LValue:                                             
       IDENT                                        { $$ = makeNode(_IDENT); strcpy($$->attributes.ident, $1); }
    ;
Arguments:
       ListExp                                      { $$ = makeNode(Arguments); addChild($$, $1); }
    |                                               { $$ = makeNode(Arguments); }
    ;
ListExp:
       ListExp ',' Exp                              { $$ = makeNode(ListExp); addChild($$, $1); addChild($$, $3); }
    |  Exp                                          { $$ = makeNode(ListExp); addChild($$, $1); }
    ;
%%



void yyerror(char *s) {
    fprintf(stderr, "line %d : %s\n", line, s);
}

void help() {
    printf("./tpcas lance l'analyseur dans le terminal\n");
    printf("./tpcas [fichier] lance l'analyseur avec le fichier en argument\n");
    printf("./tpcas [-t (ou --tree) fichier] affiche l'arbre abstrait construit lors de l'analyse du fichier\n");
}


int main(int argc, char *argv[]) {
    FILE *f;
    if (argc == 1)
        return yyparse();

    if (argc == 2) {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
            help();
            return 0;
        }

        if (strcmp(argv[1], "-t") == 0 || strcmp(argv[1], "--tree") == 0) {
            printtree = 1;
            return yyparse();
        }

        else {
            f = fopen(argv[1], "r");
            
            if (f == NULL) {
                fprintf(stderr, "file does not exist\n");
                return 2;
            }
            else {
                yyrestart(f);
                res = yyparse();
            }
            fclose(f);
            return res;
        }
    }

 
    if (argc == 3) {
        if (strcmp(argv[1], "-t") == 0 || strcmp(argv[1], "--tree") == 0) {
            printtree = 1;
            f = fopen(argv[2], "r");
            
            if (f == NULL) {
                fprintf(stderr, "file does not exist\n");
                return 2;
            }
            else {
                yyrestart(f);
                res = yyparse();
            }
            fclose(f);
            return res;            
        }

        else {
            help();
        }   
    }

    else {
        help();
    }
}