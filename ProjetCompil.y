%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <dirent.h>

extern FILE* yyin; 
extern int pos, col,ligne;
char title[500];
int indice=0;
//Structure de la hashtable
typedef struct Element { char* Entite; int Val; struct Element* Next; } Element;

typedef struct tableau { Element *elemL ; int Etat;} Tb;

Tb T[100];


//Tableau de References
int TabR[100];
// Word counter : to count the number of words in the title and the abstract.
int wordCounter = 0;

/****************************Partie INDEX intermediaire *****************/



/*********** Save doc in file ************/

void saveDoc(FILE* file, char* DocName){ 
	int k;
    if (TsVide() != 0){  
		for(k=0;k<100;k++){ 
			if (T[k].Etat==1){  
				Element *Tete = T[k].elemL;
				while(Tete!= NULL){  
					fprintf(file,"%s %d %s\n", Tete->Entite, Tete->Val, DocName);
					Tete = Tete->Next;
			   }	  		 
		   }
		}
   }
}
/****************************Partie Hashtable **********/
/*****************************InitTS*********************/

void InitTS()
{  int k;
   for(k=0; k<100; k++) { T[k].Etat=0; T[k].elemL = NULL; }
}

/***************************** recherche*******************/
int Rechercher(Element *Elem)
{ int valeur=0, k=0; 

    for(k=0;k<strlen(Elem->Entite);k++) 
      valeur += Elem->Entite[k];
 
  k=(((123*valeur)+193)%173)%100;
  return k;
  
}

/*********************Inserer ************************/

void inserer(char* Entite)
{
  Element* E =(Element*)malloc(sizeof(Element)); 
  int pos=0;
  E->Entite=Entite;   
  E->Val=0;
  E->Next = NULL; 
  
  pos =Rechercher(E);
  if (T[pos].Etat==0)
    {
      T[pos].Etat=1;
      E->Val=1;
      T[pos].elemL = E;
    }  
  else 
    {     Element *Tete = T[pos].elemL;
	  while(Tete->Next != NULL && strcmp(Tete->Entite, E->Entite))
	  {
	    Tete = Tete->Next;
	  }
          if (!strcmp(Tete->Entite , E->Entite))
	  {  
            Tete->Val++ ;  
          }
          else {
   
                 E->Val=1;
                 Tete->Next = E;
                  
               }
        
    }
}
/*****************************Vide*********************/

int TsVide()
{ int k=0;
  while(T[k].Etat!=1 && k<100) k++;
  if (k==100) return 0 ; else return 1; 
}

/********************************Affichage*****************/
void Affichage()
{ int k;
  
  if (TsVide() != 0)
  {

   printf("╔═══════════════════╦════════════════╦══════════════╗\n");
   printf("║      Position     ║     Entite     ║     Type     ║ \n");
  
  
    for(k=0;k<100;k++)
    { 
     if (T[k].Etat==1)
    	{  Element *Tete = T[k].elemL;

		   while(Tete!= NULL)
		   {  printf("╠═══════════════════╬════════════════╬══════════════╣\n");
		      printf("║         %d        ║       %s       ║       %d     ║ \n", k, Tete->Entite, Tete->Val ); 
               
                     
		      Tete = Tete->Next;
                   }	  		 
        
       }
    }
                printf("╚═══════════════════╩════════════════╩══════════════╝\n");
   }
  
}

/************Partie Verification des references***********/

void initTabR(){ 
	int k; 
	for(k=0;k<100;k++) TabR[k]=0;
}

void InsererRef(char* ref){
	char charHolder;
	int numRef;
	sscanf(ref, "%c%d", &charHolder, &numRef);
	printf("updating reference table: inserting  n°%d\n", numRef);
	TabR[numRef]=1;
}

int TestRef(char* ref ){ 
	char charHolder;
	int numRef;
	sscanf(ref, "%c%d", &charHolder, &numRef);	
	if(TabR[numRef]==0) return 0;
	TabR[numRef]=0;
	return 1; 
}
int isTabRVide(){
	int k; 
	for(k=0;k<100;k++) if(TabR[k]==1) return 0;
	return 1;
}
/********Teste des nombre de mot dans un paragraphe ou un title******/
int CheckTitle()
{ if (wordCounter > 10) return 0; 
   return 1;
}

int CheckParagraph()
{ if (wordCounter > 100) return 0;
 return 1; 
}



%}

%token Space Ponctuation Point Virgule SL Tabulation TITLE AUTHORS ABSTRACT KEYWORDS INTRODUCTION  RELATEDWORKS
  CONCEPTION  EXPERIMENTALRESULTS CONCLUSION  REFERENCES Ref Word  CompoundWord
	 	   
%start CorpusDoc
%%
CorpusDoc :  RTITLE RAUTHORS RABSTRACT RKEYWORDS RINTRODUCTION RRELATEDWORKS RCONCEPTION REXPERIMENTALRESULTS 
RCONCLUSION RREFERENCES {if(!isTabRVide()){ 
printf("Document valide\n");
return 3;}
};

RTITLE : TITLE Space ListeMot {if(!CheckTitle()) {yyerror("La taille du titre n'est pas conforme\n");return 3;}wordCounter=0;}
SL {printf("Title Valide\n");};
ListeMot : ListeMot Space Mot 
| Mot ;
Mot : Word 
| CompoundWord
;
RABSTRACT : ABSTRACT ListeMotParagraphe { printf("Ko\n");if(!CheckParagraph())
                                                     { yyerror("La taille de l'Abstract n'est pas conforme\n");
                                                       return 3;  
                                                     }    
                                                   } Point SL
;
ListeMotParagraphe :  ListeMotParagraphe PonctuationMot  
| PonctuationMot 
; 
PonctuationMot  : Ponctuation 
|Space Mot {wordCounter++;}
;
RAUTHORS : AUTHORS Space ListeMotVirguleAuteur Point SL {printf("Author Valide\n");}
;
ListeMotVirguleAuteur : ListeMotVirguleAuteur Virgule Space Mot Space Mot {wordCounter++;wordCounter++;}
| Mot Space Mot {wordCounter++;wordCounter++;}
;
RKEYWORDS : KEYWORDS Space ListMotVirgule Point SL
ListMotVirgule : ListMotVirgule Virgule Space Mot {wordCounter++;}
| Mot {wordCounter++;}
;
RINTRODUCTION : INTRODUCTION SL ListeMotRefParagraphe 
;
RRELATEDWORKS : RELATEDWORKS SL ListeMotRefParagraphe 
;
RCONCEPTION : CONCEPTION SL ListeMotRefParagraphe 
;
REXPERIMENTALRESULTS : EXPERIMENTALRESULTS SL ListeMotRefParagraphe 
;
RCONCLUSION : CONCLUSION SL ListeMotRefParagraphe 
;
RREFERENCES : REFERENCES SL ListeReference
;
ListeReference : ListeReference  RRef | RRef {printf("Ligne 235 SAt !\n");}
;
RRef :  Ref { indice=23;} Tabulation SuiteDeMot SL {printf("Ligne 256 SAt !\n"); if(!TestRef((char*)$1)){
											printf("reference declaré et non utilisé!\n");
											return 3;}}
;
SuiteDeMot : SuiteDeMot Mot Space {printf("Mot ref %d\n",indice);}
|Mot Point {printf("Mot ref %d\n",indice);}
;
ListeMotRefParagraphe :  ListeMotRefParagraphe PonctuationMotRef MotPoint  SL 
| PonctuationMotRef MotPoint  SL 
| MotPoint  SL {printf("Mot ref %d\n",indice);}
; 
MotPoint : Mot Point 
| Mot Ref Point { InsererRef((char*)$2);}
;
PonctuationMotRef: PonctuationMotRef Mot EspaceRefPonc {wordCounter++;}
| Mot EspaceRefPonc {wordCounter++;}
;
EspaceRefPonc : Ref Space { InsererRef((char*)$1);}| Ponctuation Space |Space | Virgule Space 
;
PonctuationMotRef  : Ponctuation
|Space Mot {wordCounter++;}
|Ref { InsererRef((char*)$1);}
; 
%%

int yywrap(){
	return 1;
}

int yyerror(char* ms){
	printf("Erreur à la ligne n° %d colonne n° %d position %d :%s \n", ligne, col,pos,ms);
return 1;
}

int main(int argc, char *argv[]){
	if(argc == 2){
		int result;
		FILE* index;
		DIR *dp;
		char chem[255];
		struct dirent *ep;
		dp = opendir (argv[1]);
		if (dp != NULL) {
			while (ep = readdir (dp)){
				if(strcmp(ep->d_name,".") && strcmp(ep->d_name,"..") && strchr(ep->d_name,'~') == NULL){
					strcpy(chem,"./");
					strcat(chem,argv[1]);
					strcat(chem,"/");
					strcat(chem,ep->d_name);
					yyin=fopen(chem,"r");
					if(yyin !=NULL){
						wordCounter = 0;
						InitTS();
						initTabR();
						printf("************Processus de validation du document: %s!*********\n", ep->d_name);
						if(!yyparse()){
							Affichage();
							index= fopen("index.txt","a");
							if(index==NULL) printf("Can't write on index!\n");
							else{
								saveDoc(index, ep->d_name);
								fclose(index);
							}
							printf("Apres affichge");
						}
						fclose(yyin);
						printf("*************Fin du processus de validation du document: %s!********\n", ep->d_name);
					} else printf("Couldn' read document: %s !\n",chem);
					strcpy(chem,"");
				}
			}	
			(void) closedir (dp);
		}
	} else printf("no valid argument!\n");
	return 0;
}
