/* tree.h */
#ifndef __DEF__
#define __DEF__
typedef enum {
  Prog,
  DeclVars,
  Declarateurs,
  DeclFoncts,
  DeclFonct,
  EnTeteFonct,
  Parametres,
  ListTypVar,
  Corps,
  SuiteInstr,
  SuiteSwitch,
  Instr,
  Exp,
  TB,
  FB,
  M,
  E,
  T,
  F,
  LValue,
  Arguments,
  ListExp,
  _IDENT,
  _CHARACTER,
  _NUM,
  _TYPE,
  _EQ,
  _ORDER,
  _ADDSUB,
  _DIVSTAR,
  _OR,
  _AND,
  _IF,
  _WHILE,
  _VOID,
  _CASE,
  _BREAK,
  _DEFAULT,
  _ELSE,
  _RETURN,
  _SWITCH,
  _AFFECTATION
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
  union {
      char ident[64];
      int num;
  } attributes;
} Node;

Node *makeNode(label_t label);


void addSibling(Node *node, Node *sibling);


void addChild(Node *parent, Node *child);


void deleteTree(Node*node);


void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling

#endif
