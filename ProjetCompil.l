%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "ProjetCompil.tab.h"
int ligne=0, col=0,pos=0;
extern YYSTYPE yylval; 

%}
Point "."
Virgule ","
SL [\n]
Space [ ] 
Tabulation [\t]
TITLE "TITLE"
AUTHORS "AUTHORS"
ABSTRACT "ABSTRACT"
KEYWORDS "KEYWORDS"
INTRODUCTION "INTRODUCTION" 
RELATEDWORKS "RELATEDWORKS"
CONCEPTION "CONCEPTION"
EXPERIMENTALRESULTS "EXPERIMENTALRESULTS"
CONCLUSION "CONCLUSION"
REFERENCES "REFERENCES"
Word [a-zA-Z][a-zA-Z0-9]*
CompoundWord {Word}"-"{Word}
Ponctuation	[?!:;()]
Ref "["[1-9][0-9]*"]"

%%
{Space} {col+= strlen(yytext);return Space;}
{Ponctuation} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Ponctuation");return Ponctuation;}
{Point} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Point");return Point ;} 
{Virgule} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Virgule");return Virgule; }
{SL} { ligne++;pos=0;col=0; return SL;}
{Tabulation} {pos++;col+= strlen(yytext);return Tabulation;}
{TITLE} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return TITLE ;}
{AUTHORS} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return AUTHORS;}
{ABSTRACT} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return ABSTRACT;}
{KEYWORDS} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return KEYWORDS;}
{INTRODUCTION} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return INTRODUCTION;} 
{RELATEDWORKS} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return RELATEDWORKS;}
{CONCEPTION} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return CONCEPTION;}
{EXPERIMENTALRESULTS} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return EXPERIMENTALRESULTS;}
{CONCLUSION} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return CONCLUSION;}
{REFERENCES} {pos++;col+= strlen(yytext);insert(strdup(yytext),"Mot Clé");return REFERENCES;}
{Ref} {pos++; yylval=strdup(yytext) ;col= strlen(yytext);insert(strdup(yytext),"Références");return Ref;}
{CompoundWord} {pos++;yylval=strdup(yytext); col+= strlen(yytext);insert(strdup(yytext),"Mot");return CompoundWord;}
{Word}  {pos++;yylval=strdup(yytext); col+= strlen(yytext);insert(strdup(yytext),"Mot");return Word;}
. {printf("Erreur lexical: élément non reconnut %s ligne %d colonne %d position %d \n ",strdup(yytext),ligne,col,pos);} 
%%
