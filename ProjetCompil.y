%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <dirent.h>

#define TAILLE_TS 1000
#define TAILLE_TABLE_INDEX 1000

extern FILE* yyin; 
extern int pos, col,ligne;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//la creation de la structure
typedef struct Entity
{
	char *name;
	char *type;
	int occ;
	struct Entity *Next;
} Entity;

//Création de structure d'indexage
typedef struct elemIndex
{
	char *document;
	char *mot;
	int occ;
	struct elemIndex *suivant;//Deja ca je veux l'enlever
}elemIndex;

//Structure pour les references
typedef struct elemRef
{
	int ref;
	struct elemRef *suivant;
}elemRef;

//Variables globales
Entity *tab[TAILLE_TS];
elemIndex *indexage[TAILLE_TABLE_INDEX];
int nbMot;//Nombre de mot dans un document
int nbMotIndex;//Nombre de mot dans tous l'indexage
char* nomDocument;
elemRef *teteReference;//Table des reference ce vide a chzaque nouveaux document
int nbRef;
int nbRef2;

//On fait appele a cette fonction au debut de chaque lecture de fichier corpus
void initNewDoc(char* document)
{
	elemIndex *pointeurCourant=NULL,*pointeurSupp=NULL;
	Entity *pointeur = NULL ;
    int i;
    
    nbRef=0;
    nbRef2=0;
    nbMot=0;
    ligne=0;

    nomDocument=document;
    
    
    //Initialisation de la table des symbole
    for(i=0;i<TAILLE_TS;i++)
    {
		pointeur = tab[i];
		while(pointeur!=NULL)
		{
			if(tab[i]->occ!=0)//Les element du tableux deja initialiser
			{
				tab[i]->occ=0;
				strcpy(tab[i]->name,"");
				strcpy(tab[i]->type,"");
			}
			//On ne sait jamais
			strcpy(tab[i]->name,"");
			strcpy(tab[i]->type,"");
			tab[i]->Next=NULL;
			pointeur = pointeur->Next ;
		}
		tab[i]=NULL;
    }
}

//On fait appel a cette fonction a chaque lecture d'une référence dans hors de la liste de référence
int addRef(char* refChar)
{
	char enPlus;
	int ref;
	sscanf(refChar, "%c%d", &enPlus, &ref);
	elemRef *NewElmRef =NULL,*pointeurCourant=NULL;
	nbRef++;
	NewElmRef = (elemRef*)malloc(sizeof(elemRef));
	if(NewElmRef==NULL)
	{
		fprintf(stderr,"Element elmRef non allouer (Fonction addRef)\n");
		exit(EXIT_FAILURE);
	}
	NewElmRef->ref=ref;
	NewElmRef->suivant=NULL;

	if(teteReference==NULL)//Insertion a la tete
	{
		teteReference=NewElmRef;
	}
	else
	{
		pointeurCourant=teteReference;
		while(pointeurCourant->suivant!=NULL)
		{
			pointeurCourant=pointeurCourant->suivant;
		}
		pointeurCourant->suivant=NewElmRef;
	}
	return 0;
}

//VerifRef
int verifNbRef()
{
    if (nbRef==nbRef2)return 1;
    else return 0;
}

//On fait appel a cette fonction a chaque fois que l'on rencontre une références dans la partie référence
int verifRef(char* ref)
{
    char enPlus;
	int numRef;
	elemRef *teteDeReference =NULL;
	teteDeReference = teteReference;
	sscanf(ref, "%c%d", &enPlus, &numRef);
	if((nbRef2+1-numRef)!=0 )
    {
        printf("Reference non sequentielle\n");
        return -1;
    }
    nbRef2++;
    while(teteDeReference!=NULL && teteDeReference->ref!=numRef)
    {
       teteDeReference=teteDeReference->suivant;
    }
	if(teteDeReference==NULL) return 0;
	else return 1; //On a trouver l'element
}

int hacha(char* name)
{
	int i,val=0;
	for(i=0;i<strlen(name);i++)
		val+=name[i];
	return (((123*val)+139)*173)%TAILLE_TS;
}

Entity* search(char* name)
{
	Entity *pc = &tab[hacha(name)];
    while (pc!=NULL)
    {
		if(!(strcmp(pc->name,name))) return pc;
		pc=pc->Next;
	}
	return pc;
}

void print()
{
	int i;
	Entity *pc = NULL;
	printf(" ___________________________________________________________________________________________________\n");
	printf("| INDICE | TYPE                    | Entite				   | nombre d'occurences   |\n");

	for (i=0; i < TAILLE_TS ;i++)
	{
		if (tab[i]!=NULL)
		{
			pc = tab[i];
			while (pc !=NULL)
			{
				if(pc!=tab[i])
				{
					printf("|	 |_________________________________________________________________________________________|\n");
					printf("|        | 	      %s	   |	         %s          |	      %d		   |\n",pc->type,pc->name,pc->occ);
				}
				else
				{
					printf("|________|_________________________________________________________________________________________|\n");
					printf("|   %d   | 	      %s	   |	         %s          |	      %d		   |\n",i,pc->type,pc->name,pc->occ);
				}
				pc = pc->Next;
			}
		}
	}
	printf("|________|_________________________|_______________________________________________________________|\n");
	printf(" \n");
}

int docVide()
{
	int i;
    for(i=0;i<TAILLE_TS;i++)
    {
        if(tab[i]!=NULL)//Les element du tableux deja initialiser
        {
            return 0;
        }
    }
    return 1;
}

int insert (char *name ,char *type)
{
    int i,val = 0;
    Entity *pc =NULL,*ps = NULL;

	val=hacha(name);
	

    if (tab[val]==NULL) //n'existe pas, pas de collisions
    {
		tab[val]= (Entity*)malloc(sizeof(Entity));
		if(tab[val]==NULL)
        {
			fprintf(stderr,"élément non inséré dans la TS\n");
			exit (EXIT_FAILURE);
		}
		tab[val]->type=strdup(type);
		tab[val]->name=strdup(name);
		tab[val]->occ= 1;
		if((tab[val]->type==NULL)||(tab[val]->name==NULL))
        {
			fprintf(stderr,"chaine type ou name non allouee \n");
			exit (EXIT_FAILURE);
		}
        tab[val]->Next = NULL;
    }
    else
    {
        pc = tab[val];
        while (pc->Next!=NULL)
        {
			if(!(strcmp(pc->name,name)))
			{
				(pc->occ)++;
				return 1;
			}
		    pc = pc->Next;
		}
		if(!(strcmp(pc->name,name)))
		{
			(pc->occ)++;
			return 1;
		}

        //Allouer une nouvelle Entite (pointeur)
        ps=(Entity*)malloc(sizeof(Entity));
        if(ps==NULL)
        {
			fprintf(stderr,"élément non inséré dans la liste chainee de collistion de la TS\n");
			exit (EXIT_FAILURE);
		}
        ps->name=strdup(name);
        ps->type=strdup(type);
		if((ps->type==NULL)||(ps->name==NULL))
        {
			fprintf(stderr,"chaine type ou name non allouee (insertion)\n");
			exit (EXIT_FAILURE);
		}
        ps->Next=NULL;
        ps->occ= 1;

        //Chainage avec le nouveau element
        pc->Next=ps;
    }
    return 0;
}

int insertIndex(char* mot)
{
    int val = 0;
    elemIndex *pc = NULL,*NewElmIndex = NULL ;

	val=hacha(mot);
	nbMotIndex++;

    if (indexage[val]==NULL)
    {
		indexage[val]= (Entity*)malloc(sizeof(Entity));
		if(indexage[val]==NULL)
        {
			fprintf(stderr,"élément non inséré dans la TS\n");
			exit (EXIT_FAILURE);
		}
		indexage[val]->occ= 1;
		indexage[val]->mot=strdup(mot);
		indexage[val]->document=strdup(nomDocument);
		if((indexage[val]->mot==NULL))
        {
			fprintf(stderr,"Mot non allouer (Fonction create Index)\n");
			exit (EXIT_FAILURE);
		}
		indexage[val]->suivant=NULL;
    }
    else
    {
        //Si c'est le même document
        pc = indexage[val];
        while (pc->suivant!=NULL)
        {
			if(strcmp(pc->document,nomDocument)==0)
			{
				(pc->occ)++;
				return 1;
			}
		    pc = pc->suivant;
		}
		if(strcmp(pc->document,nomDocument)==0)
		{
			(pc->occ)++;
			return 1;
		}

        NewElmIndex= (elemIndex*)malloc(sizeof(elemIndex));
        if(NewElmIndex==NULL)
        {
			fprintf(stderr,"Element NewElmIndex non alloué (Fonction insert Index)\n");
			exit (EXIT_FAILURE);
		}

		NewElmIndex->mot=strdup(mot);
        NewElmIndex->document= strdup(nomDocument);
		if(NewElmIndex->document==NULL || NewElmIndex->mot==NULL)
        {
			fprintf(stderr,"Document ou mot non alloué dans NewElmIndex (Fonction insertIndex)\n");
			exit (EXIT_FAILURE);
		}

        NewElmIndex->suivant=NULL;
        pc->suivant=NewElmIndex;
    }
	return 0;
}

void saveFile()
{
	elemIndex *pointeurCourant = NULL;
	int i;
	FILE *fichier =NULL ;

	fichier =fopen("textIndex.txt","w");
	if(fichier==NULL)
	{
		fprintf(stderr,"erreur lors de l'ouverture du fichier textIndex.txt en écriture\n");
		exit(EXIT_FAILURE);
	}

    for(i=0;i<TAILLE_TABLE_INDEX;i++)
    {

		pointeurCourant = indexage[i];
		while(pointeurCourant !=NULL)
		{
			fprintf(fichier,"%s %d %s\n",indexage[i]->mot,indexage[i]->occ,indexage[i]->document);
			pointeurCourant=pointeurCourant->suivant;
        }
    }

    fclose(fichier);
}

//Cette fonction sauvegarde nos information dans le fichier indexage
int createIndex()
{
	FILE *fichier;
	fichier = fopen("indexage.bin" , "wb");
	if (fichier==NULL)
	{
		fprintf(stderr,"Erreur dans l'ouverture du fichier indexage.bin\n");
		exit(EXIT_FAILURE);
	}
	fwrite( indexage , sizeof(indexage[0]) , nbMotIndex , fichier);
	fclose(fichier);
	return 1;
}

//Fonction qui verifie si le nombre maximum de mots dans un titre n'a pas été depassé (Routine semantque)
int verificationTitre()
{
	if (nbMot > 10)
	{
		nbMot=0;
		return 0;
	}
	nbMot=0;
	return 1;
}

//Fonction qui verifie si le nombre maximum de mots dans un paragraphe n'a pas été depassé (Routine semantque)
int verificationParagraphe()
{
	if (nbMot > 100)
	{
		nbMot=0;
		return 0;
	}
	nbMot=0;
	return 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

%}

%token Space Ponctuation Point Virgule SL Tabulation TITLE AUTHORS ABSTRACT KEYWORDS INTRODUCTION  RELATEDWORKS
  CONCEPTION  EXPERIMENTALRESULTS CONCLUSION  REFERENCES Ref Word  CompoundWord
	 	   
%start CorpusDoc
%%
CorpusDoc : RTITLE RAUTHORS RABSTRACT RKEYWORDS RINTRODUCTION RRELATEDWORKS RCONCEPTION REXPERIMENTALRESULTS
RCONCLUSION RREFERENCES {
if(docVide()){ 
yyerror("Document non valide\n");
return -1;}
};

RTITLE : TITLE Space ListeMot {if(!verificationTitre()) {yyerror("La taille du titre n'est pas conforme\n");return -1;}nbMot=0;} SL 
;
ListeMot : ListeMot Space Mot 
| Mot ;

Mot : Word {nbMot++;insertIndex((char*)($1));}
| CompoundWord {nbMot++;insertIndex((char*)($1));}
;

RABSTRACT : ABSTRACT Space ListeMotParagraphe {if(!verificationParagraphe())
                                                    {
              yyerror("La taille de l'Abstract n'est pas conforme\n");
              return -1;  
                                                    }
             nbMot=0;
                                                   } 


ListeMotParagraphe : PonctuationMot MotPointFinal  SL 
| MotPointFinal  SL 
;
 
MotPointFinal : Mot Point 
;

PonctuationMot: PonctuationMot Mot EspacePonc 
| Mot EspacePonc 
;

EspacePonc : Space 
| Ponctuation Space
| Virgule Space
;

RAUTHORS : AUTHORS Space ListeMotVirguleAuteur Point SL 
;

ListeMotVirguleAuteur : ListeMotVirguleAuteur Virgule Space Mot Space Mot 
| Mot Space Mot 
;
RKEYWORDS : KEYWORDS Space ListMotVirgule Point SL
;
ListMotVirgule : ListMotVirgule Virgule Space Mot 
| Mot 
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
RREFERENCES : REFERENCES SL ListeReference {if(!verifNbRef()) {yyerror("existance de référance non listé a la fin du document\n");return 3;}}
;
ListeReference : ListeReference  RRef 
| RRef 
;
RRef :  Ref Tabulation SuiteDeMot SL {if(!verifRef((char*)$1)){
											yyerror("reference declaré et non utilisé!\n");
											return 3;}}
;
SuiteDeMot : Mot Space SuiteDeMot 
| Mot Point   
;
ListeMotRefParagraphe :  ListeMotRefParagraphe PonctuationMotRef MotPoint  SL 
| PonctuationMotRef MotPoint  SL 
| MotPoint  SL 
; 
MotPoint : Mot Point 
| Mot Ref Point {addRef((char*)$2);}
;
PonctuationMotRef: PonctuationMotRef Mot EspaceRefPonc 
| Mot EspaceRefPonc 
;
EspaceRefPonc : Ref Space { addRef((char*)$1);}| Ponctuation Space |Space | Virgule Space 
;
PonctuationMotRef  : Ponctuation
|Space Mot 
|Ref { addRef((char*)$1);}
; 
%%

int yywrap(){
	return 1;
}

int yyerror(char* ms){
	printf("Erreur à la ligne n° %d colonne n° %d position %d :%s \n", ligne, col,pos,ms);
return 1;
}

int main(int argc, char *argv[])
{
	int result;
	elemRef *courantElmRef=NULL;
	FILE* indexage;
	DIR *repertoire;
	char chemin[255];
	struct dirent *contenu;
	nbRef=0;
    nbRef2=0;
    nbMot=0;
	if(argc == 2)
	{
		nbMotIndex=0;
		repertoire = opendir (argv[1]);
		if(repertoire != NULL)
		{
			while (contenu = readdir (repertoire))//contenu represente soit un repertoire ou un dossier
			{
				if(strcmp(contenu->d_name,".") && strcmp(contenu->d_name,".."))
				{
					strcpy(chemin,"./");
					strcat(chemin,argv[1]);
					strcat(chemin,"/");
					strcat(chemin,contenu->d_name);
                    yyin=fopen(chemin,"r");
					if(yyin !=NULL)
					{
                        nomDocument= contenu->d_name ;
                        initNewDoc(contenu->d_name);
						printf("||||||||||||Debut validation du document: %s!|||||||||\n", contenu->d_name);
						if(!yyparse())
						{
							print();//Affichage de la table des symbole
							createIndex();
							saveFile();
							
							//Initialisation de la liste des reference
							courantElmRef =teteReference ->suivant ;
							while(courantElmRef!=NULL)
							{
								courantElmRef=teteReference ->suivant ;
								free(teteReference);
								teteReference=courantElmRef;
							}
							teteReference=NULL;

						}
						fclose(yyin);
						printf("|||||||||||||Fin de la  validation du document: %s!||||||||\n", contenu->d_name);
					}
					else printf("Erreur : Fichier corromput: %s !\n",chemin);
					strcpy(chemin,"");//On reinitialise notre chemin
				}
			}
			closedir (repertoire);
		}
	}
	else printf("Argument en entrer non valide \n");

	return 0;
}

