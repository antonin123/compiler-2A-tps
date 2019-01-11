%{

	#include <stdio.h>
	#include <stdlib.h>
	int i;
	int count = 0;
	int yylex(void);
	int yyerror(char *);
	extern FILE * yyin;
 	FILE * fichier;
	int preci;
	int lib;
	char *library;
	char *library2;
	int tab[50];

%}

%token PRAGMA LIBRARY PRECISION ROUNDTYPE ROUNDING
%token ENTIER IDENTIFIER 
%token OUVRIR FERMER ACCO_OUVRIR ACCO_FERMER VIRGULE PT_VIRG
%token EGALE PLUS MOINS FOIS DIVISION POW SQR
%token IF WHILE SUPERIEUR INFERIEUR
%start pragma
%left PLUS MOINS
%left FOIS DIVISION

%%

pragma: PRAGMA LIBRARY 
		PRECISION OUVRIR ENTIER FERMER 
		ROUNDING OUVRIR ROUNDTYPE FERMER 
		 {
			 lib = $2;
		   preci  = $5; 
			 if (lib == 67) {
				 library = "mpc";
				 library2 = "MPC";
			 } else {
				 library = "mpfr";
				 library2 = "MPFR";
			 }
		   fichier= fopen("toto.txt", "w");
		 } 
		loop 
			{
				fprintf(fichier, "\n");
				for (i = 0; i <= count-1; i++){
					fprintf(fichier,
								 "%s_clear(T%i);\n", 
								 library, i);
				}
				fclose(fichier);
			}
;


loop:  ACCO_OUVRIR sup_expr ACCO_FERMER 
;


sup_expr: IDENTIFIER EGALE expr PT_VIRG
		  {		
			fprintf(fichier,
						  "%c = %s_get_ldc(T%i, %s_RNDZZ);\n",
							$1, library, $3, library2);
		  }

	| IDENTIFIER EGALE expr PT_VIRG
		  {		
			fprintf(fichier,
						  "%c = %s_get_ldc(T%i, %s_RNDZZ);\n\n\n",
							$1, library, $3, library2);
		  }
		sup_expr

	| WHILE OUVRIR expr SUPERIEUR expr FERMER 
			{
				fprintf(fichier, 
							  "while ( %s_cmp(T%i, T%i) ) {\n\n",
								library, $3, $5);								
			}
		loop
			{
				fprintf(fichier, "\n}\n");
			}
		
	| WHILE OUVRIR expr INFERIEUR expr FERMER 
			{
				fprintf(fichier, 
							  "while ( !%s_cmp(T%i, T%i) ) {\n\n",
								library, $3, $5);								
			}
		loop
			{
				fprintf(fichier, "\n}\n\n");
			}
	
	| IF OUVRIR expr SUPERIEUR expr FERMER 
			{
				fprintf(fichier, 
							  "if ( %s_cmp(T%i, T%i) ) {\n\n",
								library, $3, $5);								
			}
		loop
			{
				fprintf(fichier, "\n}\n\n");
			}
		
	| IF OUVRIR expr INFERIEUR expr FERMER 
			{
				fprintf(fichier, 
							  "if ( !%s_cmp(T%i, T%i) ) {\n\n",
								library, $3, $5);								
			}
		loop
			{
				fprintf(fichier, "\n}\n\n");
			}
;


expr: expr PLUS expr 
		{
			$$ = count;
			fprintf(fichier, 
							"%s_t T%i; %s_init2(T%i, %i); \n",
							library, count, library, count, preci);
			fprintf(fichier, 
							"%s_add(T%i, T%i, T%i, %s_RNDZZ);\n\n", 
							library, count, $1, $3, library2);
			count++; 
		}

	| expr MOINS expr 
		{
			$$ = count;
			fprintf(fichier, 
							"%s_t T%i; %s_init2(T%i, %i); \n",
							library, count, library, count, preci);
			fprintf(fichier, 
							"%s_sub(T%i, T%i, T%i, %s_RNDZZ);\n\n", 
							library, count, $1, $3, library2);
			count++; 
		}

	| expr FOIS expr 
		{
			$$ = count;
			fprintf(fichier, 
							"%s_t T%i; %s_init2(T%i, %i); \n",
							library, count, library, count, preci);
			fprintf(fichier, 
							"%s_mul(T%i, T%i, T%i, %s_RNDZZ);\n\n", 
							library, count, $1, $3, library2);
			count++; 
		} 

	| expr DIVISION expr 
		{
			if(tab[$3]==0){
				fprintf(fichier, "division par zero\n\n\n");
				return 1;
			}	else {
				$$ = count;
				fprintf(fichier, 
								"%s_t T%i; %s_init2(T%i, %i); \n",
								library, count, library, count, preci);
				fprintf(fichier, 
								"%s_div(T%i, T%i, T%i, %s_RNDZZ);\n\n", 
								library, count, $1, $3, library2);
				count++; 
			}
			
		} 

	| POW OUVRIR expr VIRGULE expr FERMER
		{
			$$ = count;
			fprintf(fichier, 
							"%s_t T%i; %s_init2(T%i, %i); \n",
							library, count, library, count, preci);
			fprintf(fichier, 
							"%s_pow(T%i, T%i, T%i, %s_RNDZZ);\n\n", 
							library, count, $3, $5, library2);
			count++; 
		}

	| SQR OUVRIR expr FERMER
		{
			if(tab[$3]<0 && tab[$3]!=-5000000){
				fprintf(fichier, "racine negative IMPOSSIBLE\n\n\n");
				return 1;
			}
			$$ = count;
			fprintf(fichier, 
							"%s_t T%i; %s_init2(T%i, %i); \n",
							library, count, library, count, preci);
			fprintf(fichier, 
							"%s_sqr(T%i, T%i, %s_RNDZZ);\n\n", 
							library, count, $3, library2);
			count++; 
		}

	| value { $$ = $1;}

	| OUVRIR expr FERMER 
		{
			$$ = $2;
		}
;


value: IDENTIFIER 
		  { 
				$$ = count;
				tab[count]=5000000;
				fprintf(fichier,
								"%s_t T%i; %s_init2(T%i, %i); \n",
								library, count, library, count, preci);
				fprintf(fichier,
							 "%s_set_si(T%i, %c, %s_RNDZZ);\n\n",
							  library, count, (char)$1, library2);
				count++; 
		  }
	| ENTIER 
		  { 
				$$ = count;
				tab[count]=$1;
				fprintf(fichier, 
								"%s_t T%i; %s_init2(T%i, %i); \n",
								library, count, library, count, preci);
				fprintf(fichier,
							  "%s_set_si(T%i, %d, %s_RNDZZ);\n\n",
							  library, count, $1, library2);
				count++;
		  }
		| MOINS value
	 		{
				$$ = count;
					if(tab[$2]!=500000){
						tab[count]=-tab[$2];
					}
					fprintf(fichier, 
									"%s_t T%i; %s_init2(T%i, %i); \n",
									library, count, library, count, preci);
					fprintf(fichier,
									"%s_set_si(T%i, %d, %s_RNDZZ);\n\n",
									library, count, tab[count], library2);
					count++;
			}
;

%%

int main(void) {
	yyparse();
}


