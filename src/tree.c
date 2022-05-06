/* tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
extern int lineno;       /* from lexer */

static const char *StringFromLabel[] = {
  "Prog",
  "DeclVars",
  "Declarateurs",
  "DeclFoncts",
  "DeclFonct",
  "EnTeteFonct",
  "Parametres",
  "ListTypVar",
  "Corps",
  "SuiteInstr",
  "SuiteSwitch",
  "Instr",
  "Exp",
  "TB",
  "FB",
  "M",
  "E",
  "T",
  "F",
  "LValue",
  "Arguments",
  "ListExp",
  "_IDENT",
  "_CHARACTER",
  "_NUM",
  "_TYPE",
  "_EQ",
  "_ORDER",
  "_ADDSUB",
  "_DIVSTAR",
  "_OR",
  "_AND",
  "_IF",
  "_WHILE",
  "_VOID",
  "_CASE",
  "_BREAK",
  "_DEFAULT",
  "_ELSE",
  "_RETURN",
  "_SWITCH",
  "_AFFECTATION"
  /* list all other node labels, if any */
  /* The list must coincide with the label_t enum in tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

Node *makeNode(label_t label) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->label = label;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno= 0;
  return node;
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printTree(Node *node) {
  static bool rightmost[128]; // tells if node is rightmost sibling
  static int depth = 0;       // depth of current node
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = L form; 2500 = horizontal line; 251c = vertical line and right horiz 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }
  printf("%s", StringFromLabel[node->label]);
  switch (node->label) {
    case _IDENT: printf(" : %s", node->attributes.ident); break;
    case _TYPE: printf(" : %s", node->attributes.ident); break;
    case _CHARACTER: printf(" : %s", node->attributes.ident); break;
    case _OR: printf(" : %s", node->attributes.ident); break;
    case _AND: printf(" : %s", node->attributes.ident); break;
    case _EQ: printf(" : %s", node->attributes.ident); break;
    case _ORDER: printf(" : %s", node->attributes.ident); break;
    case _ADDSUB: printf(" : %s", node->attributes.ident); break;
    case _DIVSTAR: printf(" : %s", node->attributes.ident); break;
    case _NUM: printf(" : %d", node->attributes.num); break;
    default: break;
  }
  printf("\n");
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}
