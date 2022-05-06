%{
#include "parser.tab.h"
#include "tree.h"
#include <string.h>
int line = 1;
%}

%x COMMENTAIRE
%option noyywrap
%option nounput
%option noinput

%%
"/*"                             {BEGIN(COMMENTAIRE);}
<COMMENTAIRE>.                   ;
<COMMENTAIRE>\n                  {line++;}
<COMMENTAIRE>"*/"                {BEGIN(INITIAL);}

\n                               {line++;}
[ \t]+                           ;
"//".*                           ;
void                             {return VOID;}
'.'|'\\n'|'\\t'                  { strcpy(yylval.ident, yytext); return CHARACTER;}
[0-9]+                           { yylval.num = atoi(yytext);return NUM;}
int|char                         { strcpy(yylval.ident, yytext); return TYPE;}
if                               { return IF;}
else                             { return ELSE;}
while                            { return WHILE;}
return                           { return RETURN;}
switch                           { return SWITCH;}
default                          { return DEFAULT;}
break                            { return BREAK;}
case                             { return CASE;}
"||"                             { strcpy(yylval.ident, yytext); return OR;}
"&&"                             { strcpy(yylval.ident, yytext); return AND;}
"=="|"!="                        { strcpy(yylval.ident, yytext); return EQ;}
"<"|">"|"<="|">="                { strcpy(yylval.ident, yytext); return ORDER;}
"+"|"-"                          { strcpy(yylval.ident, yytext); return ADDSUB;}
"*"|"/"|"%"                      { strcpy(yylval.ident, yytext); return DIVSTAR;}
[a-zA-Z_][a-zA-Z0-9_]*           { strcpy(yylval.ident, yytext); return IDENT;}
.                                { return yytext[0];}


%%
