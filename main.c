#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define TAILLE_TABLE_INDEX 1000
#define TAILLE_TAB_RECHERCHE 1000
//ERecu ce main depuis gmail
typedef struct recherche
{
    char* document;
    int cout;
}
recherche;

typedef struct indexage
{
	char *document;
    char *mot;
    int nbApparition ;
    struct indexage* suivant;
} indexage;

typedef struct liste
{
    char* document;
    int cout;
    struct liste* suivant;
}
liste;

recherche *tabRecherche[TAILLE_TAB_RECHERCHE];
liste *teteListe =NULL;

void merge(recherche *tab[], long first, long mid, long last)
{
    long f = first, m = mid+1, i = 0, k;
    long taille;
    recherche **temp;
    taille = last - first +1;
    temp = malloc(sizeof(recherche*)*taille);
    while((f<=mid) &&(m<=last))
    {
		if(tab[f]== NULL) temp[i] = tab[m++];
        else if(tab[m]== NULL) temp[i] = tab[f++];
		else if(tab[f]->cout < tab[m]->cout) temp[i] = tab[m++];
		else temp[i] = tab[f++];
        i++;
    }
    if(f>mid){
        for(k=m;k<=last;k++){
            temp[i++] = tab[k];
        }
    }
    else{
        for(k=f;k<=mid;k++){
            temp[i++] = tab[k];
        }
    }
    for(k=first;k<=last;k++){
        tab[k] = temp[k-first];
    }
    free(temp);
}

void sort(recherche* tab[], long first, long last){
    if(first < last){
            long mid = (first+last)/2;
            sort(tab, first, mid);
            sort(tab, mid+1, last);
            merge(tab, first, mid, last);
    }
}

int hash(char* name)
{
	int i,val=0;
	for(i=0;i<strlen(name);i++)
		val+=name[i];
	return (((123*val)+139)*173)%TAILLE_TABLE_INDEX;
}

void initIndex(indexage *index[])
{
	int i;
	for(i=0;i<TAILLE_TABLE_INDEX;i++)
    {
		index[i] = NULL;
	}
}

void AjoutIndex(char* mot, char* document, int occ,indexage* index[])
{
    int pos = hash(mot);
	indexage *pointeurCourant=NULL,*newElem=NULL;

    if(index[pos] == NULL)
    {
        index[pos] =(indexage*) malloc(sizeof(indexage));
        if(index[pos]==NULL)
        {
            fprintf(stderr,"Erreur espace non alloer (Fonction Ajout Index )\n");
            exit(EXIT_FAILURE);
        }
        index[pos]->document = strdup(document);
        index[pos]->suivant = NULL;
        index[pos]->mot = strdup(mot);
        index[pos]->nbApparition=occ;
    }
    else
    {
		pointeurCourant=index[pos];
		while(pointeurCourant->suivant!=NULL)
		{
			pointeurCourant=pointeurCourant->suivant;
		}
		newElem=(indexage*)malloc(sizeof(indexage));
		if(newElem==NULL)
		{
			fprintf(stderr,"Erreur espace non alloer (Fonction Ajout Index )\n");
            exit(EXIT_FAILURE);
		}
		newElem->document = strdup(document);
        newElem->suivant = NULL;
        newElem->mot = strdup(mot);
        newElem->nbApparition=occ;
        pointeurCourant->suivant=newElem;
	}
}

indexage* motAIindex(char* mot, indexage* index[])
{
    indexage *pointeur= index[hash(mot)];
    while(pointeur!=NULL)
    {
        if(!(strcmp(pointeur->mot,mot))) return pointeur ;
        pointeur= pointeur->suivant ;
    }
    return NULL;
}

int verifChaine(char* chaine)
{
    int i=0;
    while (chaine[i]!='\0' )
    {
        if(chaine[i]=='.' || chaine[i]==',' || chaine[i]==';') return 0 ;
        i++;
    }
    return 1 ;
}
void viderListe()
{
    liste *newElm =NULL ;
    if(teteListe==NULL) return ;
    newElm= teteListe->suivant ;
    while(newElm!=NULL)
    {
        newElm=teteListe ->suivant ;
        free(teteListe);
        teteListe=newElm;
        }
        teteListe=NULL;

}
void ajoutListe(char* document , int occ)
{
    liste *newElm =NULL ;
    if(teteListe==NULL)
    {
        teteListe= (liste*)malloc(sizeof(liste));
        teteListe->cout= occ;
        teteListe->document = strdup(document) ;
        teteListe->suivant=NULL ;
    }
    else
    {
        //Insertion a la tete
        newElm = (liste*)malloc(sizeof(liste));
        newElm->cout= occ;
        newElm->document = strdup(document) ;
        newElm->suivant=teteListe ;
        teteListe->suivant= newElm ;
    }
}

void sortList(recherche array[], int begin, int end){
    int left = begin-1;
    int right = end+1;
    const int pivot = array[begin].cout;
    if(begin >= end)
        return;
    while(1)
    {
        do right--; while(array[right].cout < pivot);
        do left++; while(array[left].cout > pivot);
        if(left < right){
            recherche temp = array[left];
            array[left] = array[right];
            array[right] = temp;
        }
        else break;
    }
    sortList(array, begin, right);
    sortList(array, right+1, end);
}

void rechercher(indexage* index[])
{
    char chaine[255];
    char *chaineSplit, *buffer,*pointeur ;
    int nb_mot=0,i=0,j=0,nbDocument=0,newElement,val=0;
    char *motCle[100];//Au maximum 100 mot
    indexage *mot = NULL ;
    //Initialisation du tableau recherche
    for(i=0;i<TAILLE_TAB_RECHERCHE;i++)
    {
        tabRecherche[i]->cout=-1;
        tabRecherche[i]->document=NULL;
    }

    printf("Recherche du document pertinent avec les mot donnée  \n");
    do
    {
        scanf( "%s",chaine);
    }
    while( verifChaine(chaine)==0 );
    chaineSplit = strtok (chaine ," ");
    buffer = strdup ( chaine );
    pointeur = strtok( buffer, " "  );
    printf ("Mot 1: %d %s\n",nb_mot, pointeur);
    strcpy( motCle[nb_mot],pointeur);
    nb_mot++;
    while( pointeur != NULL )
    {
        pointeur = strtok( NULL, " "  );
        if ( pointeur != NULL )
        {
            strcpy( motCle[nb_mot],pointeur);
            printf ("Mot de la phrase numero : %d %s\n",nb_mot, pointeur);
            nb_mot++;
        }
    }
    //Cas pour un seul mot une liste
    if(nb_mot==1)
    {
        viderListe();
        val=hash(motCle[0]);
        mot = index[val];
        while(mot!=NULL)
        {
            if(!strcmp(mot->mot,motCle[0]))
            {


                if(nbDocument==0)
                        {
                            nbDocument=1;
                            tabRecherche[0]->cout=mot->nbApparition;
                            tabRecherche[0]->document=mot->document;
                        }//Un seul mot document disctinc
                else
                {
                    tabRecherche[nbDocument]->cout=mot->nbApparition;
                    strcpy(tabRecherche[nbDocument]->document,mot->document);
                    nbDocument++;
                }
            }
            mot=mot->suivant ;
        }
        //trie
         sortList(tabRecherche,0,nbDocument);
        //affichage de la liste
        printf("Le (les) document le ou (les) plus pertient pour le mot %s est (sont)\n",motCle[0]);
        for(i=0;i<nbDocument;i++)
        {
            printf("document %s avec occurence %d \n ",tabRecherche[i]->document,tabRecherche[i]->cout);
        }
    }


}









void print()
{
    liste *pointeur = teteListe;
    while(pointeur!=NULL)
    {
        printf("Document: %s occurene du mot %d\n",pointeur->document,pointeur->cout);
        pointeur=pointeur->suivant;
    }
}

//Fonction qui affichage la table des index (Mot occurence et la liste des document dans lesquelle le mot figure  )
void affichage(indexage *index[])
{
	int i;
	indexage *pointeurCourant;
	for(i=0;i<TAILLE_TABLE_INDEX;i++)
    {
		if(index[i]!=NULL)
		{
			pointeurCourant = index[i];
            //Collision de Zmar
			while(pointeurCourant != NULL)
			{
				printf("mot: %s nbApparition: %d document: %s \n", pointeurCourant->mot, pointeurCourant->nbApparition,pointeurCourant->document);
				pointeurCourant = pointeurCourant->suivant;
				printf("\n");
			}
		}
	}
}

void MotNbApparition(indexage *index[])
{
	if(nbMotTotal(index, TAILLE_TABLE_INDEX))
    {
    int i,j;
    indexage *pointeurCourant;
    printf("________________________________________________________________________________\n");
    printf("| Le Mot          | Nombre d apparition dans tous les corpus |\n");
    printf("________________________________________________________________________________\n");
    for(i=0;i<TAILLE_TABLE_INDEX;i++)
    {
        if(index[i]!=NULL)
        {
            pointeurCourant = index[i];
            while(pointeurCourant != NULL)
            {
                printf("| %s | %d |\n", pointeurCourant->mot,pointeurCourant->nbApparition);
                printf("________________________________________________________________\n");
                pointeurCourant = pointeurCourant->suivant;
            }
        }
    }
    printf("______________________________________________________________\n");
	}
    else
    printf("Erreur dans l'index (Fonction MotNbApparition)\n");
}

int nbMotTotal(indexage *index[])
{
	int i, cpt=0;
	indexage *pointeurCourant;
	for(i=0;i<TAILLE_TABLE_INDEX;i++)
        {
		if(index[i]!=NULL)
		{
			pointeurCourant = index[i];
			while(pointeurCourant != NULL)
			{
				cpt++;
				pointeurCourant = pointeurCourant->suivant;
			}
		}
	}
	return cpt;
}

int nbMotUnefois(indexage *index[])
{
	int i, cpt=0;
	indexage *pointeurIndex;
	for(i=0;i<TAILLE_TABLE_INDEX;i++)
    {
		if(index[i]!=NULL)
		{
			pointeurIndex = index[i];
			while(pointeurIndex != NULL)
			{
				if(pointeurIndex->nbApparition ==1)
                {
                    printf("Mot: %s \n",pointeurIndex->mot);
                    cpt++;
                }
				pointeurIndex = pointeurIndex->suivant;
			}
		}
	}
	return cpt;
}

int main()
{
	FILE* fichier;
	char mot[255], document[255];
	int nb,i=0,k=0,existe=0,j=0;
	recherche maxUtiliser[4];
	indexage *index[TAILLE_TABLE_INDEX];
    char selection;
    indexage *pointeurCourant =NULL;
	initIndex(index);
	fichier = fopen("textIndex.txt", "r");

	while(fscanf(fichier,"%s %d %s", mot, &nb, document)!=EOF)
    {
        AjoutIndex(mot,document,nb, index);
    }
	fclose(fichier);

	do
    {
        printf("\tProjet m Module de compilation : Recherche d'information\n\n");
        printf("1- Le nombre de mots total du corpus\n");
        printf("2- Le nombre de mots figurant juste une fois dans le corpus\n");
        printf("3- La fréquence d’apparition de chaque mot dans le corpus\n");
        printf("4- Les 4 mots les plus utilisés dans le corpus\n");
        printf("5- Sortie \n");
        selection=getc(stdin);
        switch(selection)
        {
			case '1':
				printf("\t Le nombre de mots total du corpus est: %d\n", nbMotTotal(index));
				printf("Revenir au menu\n");
				getchar();
				break;
			case '2':
				printf("\t Le nombre de mots figurant juste une fois dans le corpus est: %d\n", nbMotUnefois(index));
				printf("Revenir au menu\n");
				getchar();
				break;
			case '3':
				printf("\t La fréquence d’apparition de chaque mot dans le corpus \n");
				MotNbApparition(index);
				printf("Revenir au menu\n");
				getchar();
				break;
			case '4':
				printf("Les 4 mots les plus utilisés dans le corpus sont:\n\n");
				for(j=0;j<4;j++)
				{
                    maxUtiliser[j].cout=0;
                    maxUtiliser[j].document=strdup("Mot vide");
				}

                for(i=0;i<TAILLE_TABLE_INDEX;i++)
                {
                    if(index[i]==NULL)continue ;
                    pointeurCourant = index[i];
                    while(pointeurCourant != NULL)
                    {
                        for(j=0;j<4;j++)
                        {
                            existe=0;
                            for(k=0;k<4;k++)
                            {
                                if(strcmp(pointeurCourant->mot,maxUtiliser[k].document)==0)
                                {
                                    existe=1 ;
                                    if(maxUtiliser[k].cout<pointeurCourant->nbApparition)
                                    maxUtiliser[k].cout=pointeurCourant->nbApparition;
                                }

                            }
                            if(existe==0)break;
                            if( maxUtiliser[j].cout<pointeurCourant->nbApparition)
                            {
                                maxUtiliser[j].cout = pointeurCourant->nbApparition ;
                                maxUtiliser[j].document=strdup(pointeurCourant->mot);
                                break; //Pour ne pas trouver le meme mot
                            }
                        }
                        pointeurCourant = pointeurCourant->suivant ;
                    }
                }
                for(j=0;j<4;j++)
                {
                    if(strcmp(maxUtiliser[j].document,"Mot vide")==0)continue;
                    printf("Mot %s\n",maxUtiliser[j].document);

                }
				printf("Revenir au menu\n");
				getchar();
				break;
			case '5':
				printf("Fin!\n");
				break;
		}
    }while(selection!='5');

	return 0;
}
