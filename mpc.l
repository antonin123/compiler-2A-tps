%{

	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	#ifndef YYSTYPE
	#define YYSTYPE double
	#endif
	void yyerror(const char * msg);

%}

%option noyywrap
library 	(MPC|MPFR)
roundtype 	(MPC_RND[NZUD][NZUD])
entier 		[0-9]+
ouvrir		\(
fermer		\)
acco_ouvrir \{
acco_fermer \}
identifier 	[a-zA-Z] 
plus 		\+
egale 		\=
fois 		\*
moins 		\-
pt_virg 	\;
superieur 	\>
inferieur 	\<
virgule 	\,
division 	\/

%%

"#pragma"	  { printf("%s", yytext); return PRAGMA; }
{library}	  { yylval = *(strdup(yytext)+2); printf("%s", yytext); return LIBRARY; }
"precision"	  { printf("%s", yytext); return PRECISION; }
{roundtype}	  { printf("%s", yytext); return ROUNDTYPE; }
{entier}	  { yylval = atoi(yytext); printf("%d", yylval); return(ENTIER); }
{ouvrir}	  { printf("%s", yytext); return OUVRIR; }
{fermer}	  { printf("%s", yytext); return FERMER; }
"rounding"	  { printf("%s", yytext); return ROUNDING; }
{identifier}  { yylval = *strdup(yytext); printf("%s", yytext); return IDENTIFIER; }
{acco_ouvrir} { printf("%s", yytext); return ACCO_OUVRIR; }
{acco_fermer} { printf("%s", yytext); return ACCO_FERMER; }
{plus}        { printf("%s", yytext); return PLUS; }
{egale}       { printf("%s", yytext); return EGALE; }
{fois}        { printf("%s", yytext); return FOIS; }
{moins}       { printf("%s", yytext); return MOINS; }
{pt_virg}     { printf("%s", yytext); return PT_VIRG; }
{superieur}   { printf("%s", yytext); return SUPERIEUR; }
{inferieur}   { printf("%s", yytext); return INFERIEUR; }
"while"       { printf("%s", yytext); return WHILE; }
"if"		  { printf("%s", yytext); return IF; }
"pow" 		  { printf("%s", yytext); return POW; }
{virgule} 	  { printf("%s", yytext); return VIRGULE; }
"sqr" 		  { printf("%s", yytext); return SQR; }
{division}    { printf("%s", yytext); return DIVISION; }

%%