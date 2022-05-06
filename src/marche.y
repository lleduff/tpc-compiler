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
       DeclVars TYPE Declarateurs ';'               { Node *id; $$ = makeNode(DeclVars); addChild($$, id = makeNode(_TYPE)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |                                               { $$ = makeNode(DeclVars); }
    ;
Declarateurs:
       Declarateurs ',' IDENT                       { Node *id; $$ = makeNode(Declarateurs); addChild($$, $1); addChild($$, id = makeNode(_IDENT)); strcpy(id->attributes.ident, $3); }
    |  IDENT                                        { Node *id; $$ = makeNode(Declarateurs); addChild($$, id = makeNode(_IDENT)); strcpy(id->attributes.ident, $1); }
    ;
DeclFoncts:
       DeclFoncts DeclFonct                         { $$ = makeNode(DeclFoncts); addChild($$, $1); addChild($$, $2); }
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
       SuiteInstr Instr                             { $$ = makeNode(SuiteInstr); addChild($$, $1); addChild($$, $2); }   
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
       LValue '=' Exp ';'                           { $$ = makeNode(Instr); addChild($$, $1); addChild($$, $3); }
    |  IF '(' Exp ')' Instr                         { $$ = makeNode(Instr); addChild($$, makeNode(_IF)); addChild($$, $3); addChild($$, $5); }
    |  IF '(' Exp ')' Instr ELSE Instr              { $$ = makeNode(Instr); addChild($$, makeNode(_IF)); addChild($$, $3); addChild($$, $5); addChild($$, makeNode(_ELSE)); addChild($$, $7); }
    |  WHILE '(' Exp ')' Instr                      { $$ = makeNode(Instr); addChild($$, makeNode(_WHILE)); addChild($$, $3); addChild($$, $5); }
    |  SWITCH '(' Exp ')' '{' SuiteSwitch '}'       { $$ = makeNode(Instr); addChild($$, makeNode(_SWITCH)); addChild($$, $3); addChild($$, $6); }    
    |  IDENT '(' Arguments  ')' ';'                 { Node *id; $$ = makeNode(Instr); addChild($$, id = makeNode(_IDENT)); strcpy(id->attributes.ident, $1); addChild($$, $3); }
    |  RETURN Exp ';'                               { $$ = makeNode(Instr); addChild($$, makeNode(_RETURN)); addChild($$, $2); }
    |  RETURN ';'                                   { $$ = makeNode(Instr); addChild($$, makeNode(_RETURN)); }
    |  '{' SuiteInstr '}'                           { $$ = makeNode(Instr); addChild($$, $2); }
    |  ';'                                          { $$ = makeNode(Instr); }
    ;
Exp :  Exp OR TB                                    { Node *id; $$ = makeNode(Exp); addChild($$, $1); addChild($$, id = makeNode(_OR)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  TB                                           { $$ = makeNode(Exp); addChild($$, $1); }
    ;
TB  :  TB AND FB                                    { Node *id; $$ = makeNode(TB); addChild($$, $1); addChild($$, id = makeNode(_AND)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  FB                                           { $$ = makeNode(TB); addChild($$, $1); }
    ;
FB  :  FB EQ M                                      { Node *id; $$ = makeNode(FB); addChild($$, $1); addChild($$, id = makeNode(_EQ)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  M                                            { $$ = makeNode(FB); addChild($$, $1); }
    ;
M   :  M ORDER E                                    { Node *id; $$ = makeNode(M); addChild($$, $1); addChild($$, id = makeNode(_ORDER)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  E                                            { $$ = makeNode(M); addChild($$, $1); }
    ;
E   :  E ADDSUB T                                   { Node *id; $$ = makeNode(E); addChild($$, $1); addChild($$, id = makeNode(_ADDSUB)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  T                                            { $$ = makeNode(E); addChild($$, $1); }
    ;
T   :  T DIVSTAR F                                  { Node *id; $$ = makeNode(T); addChild($$, $1); addChild($$, id = makeNode(_DIVSTAR)); addChild($$, $3); strcpy(id->attributes.ident, $2); }
    |  F                                            { $$ = makeNode(T); addChild($$, $1); }
    ;
F   :  ADDSUB F                                     { Node *id; $$ = makeNode(F); addChild($$, id = makeNode(_ADDSUB)); addChild($$, $2); strcpy(id->attributes.ident, $1); }
    |  '!' F                                        { $$ = makeNode(F); addChild($$, $2); }
    |  '(' Exp ')'                                  { $$ = makeNode(F); addChild($$, $2); }
    |  NUM                                          { Node *id; $$ = makeNode(F); addChild($$, id = makeNode(_NUM)); id->attributes.num = $1; }
    |  CHARACTER                                    { Node *id; $$ = makeNode(F); addChild($$, id = makeNode(_CHARACTER)); strcpy(id->attributes.ident, $1); }
    |  LValue                                       { $$ = makeNode(F); addChild($$, $1); }
    |  IDENT '(' Arguments  ')'                     { Node *id; $$ = makeNode(F); addChild($$, id = makeNode(_IDENT)); addChild($$, $3); strcpy(id->attributes.ident, $1); }
    ;
LValue:                                             
       IDENT                                        { Node *id; $$ = makeNode(LValue); addChild($$, id = makeNode(_IDENT)); strcpy(id->attributes.ident, $1); }
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