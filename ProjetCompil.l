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
Ponctuation	[?!:;]
Ref "["[1-9][0-9]*"]"

%%
{Space} {col+= strlen(yytext);return Space;}
{Ponctuation} {pos++;col+= strlen(yytext);return Ponctuation;}
{Point} {pos++;col+= strlen(yytext);return Point ;} 
{Virgule} {pos++;col+= strlen(yytext);return Virgule; }
{SL} { ligne++;pos=0;col=0; return SL;}
{Tabulation} {pos++;col+= strlen(yytext);return Tabulation;}
{TITLE} {pos++;col+= strlen(yytext);return TITLE ;}
{AUTHORS} {pos++;col+= strlen(yytext);return AUTHORS;}
{ABSTRACT} {pos++;col+= strlen(yytext);return ABSTRACT;}
{KEYWORDS} {pos++;return KEYWORDS;}
{INTRODUCTION} {pos++;return INTRODUCTION;} 
{RELATEDWORKS} {pos++;return RELATEDWORKS;}
{CONCEPTION} {pos++;return CONCEPTION;}
{EXPERIMENTALRESULTS} {pos++;col+= strlen(yytext);return EXPERIMENTALRESULTS;}
{CONCLUSION} {pos++;col+= strlen(yytext);return CONCLUSION;}
{REFERENCES} {pos++;col= strlen(yytext);return REFERENCES;}
{Ref} {pos++; yylval=strdup(yytext) ;col= strlen(yytext);return Ref;}
{Word}  {pos++;yylval=strdup(yytext); col+= strlen(yytext);return Word;}
. {printf("Erreur lexical: élément non reconnut %s ligne %d colonne %d position %d \n ",strdup(yytext),ligne,col,pos);} 
%%
