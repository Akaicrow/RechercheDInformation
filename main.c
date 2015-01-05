#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//***********************Data structure
typedef struct Doc { char* document_name; int nbOcc; struct Doc* nextDoc; } Doc;
//la liste de mot 
typedef struct WordDocs {char *word; int nbApparition ; Doc* nextDocument; struct WordDocs* nextWord;} WordDocs;
//***********************Fonctions

//TRI
void merge(WordDocs *tab[], long first, long mid, long last){
    long f = first, m = mid+1, i = 0, k;
    long taille;
    WordDocs **temp;
    taille = last - first +1;
    temp = malloc(sizeof(WordDocs*)*taille);
    while((f<=mid) &&(m<=last)){
		if(tab[f]== NULL) temp[i] = tab[m++];
        else if(tab[m]== NULL) temp[i] = tab[f++];
		else if(tab[f]->nbApparition < tab[m]->nbApparition) temp[i] = tab[m++];
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
void sort(WordDocs* tab[], long first, long last){
    if(first < last){
            long mid = (first+last)/2;
            sort(tab, first, mid);
            sort(tab, mid+1, last);
            merge(tab, first, mid, last);
    }
}
//TRI END
int hash(char* word){
	int valeur = 0, k = 0; 
	for(k=0;k<strlen(word);k++) valeur += word[k];
	k=(((123*valeur)+193)%173)%1000;
	return k;
}

void initIndex(WordDocs *index[],int size){
	int i;
	for(i=0;i<size;i++){
		index[i] = NULL;
	}
}
WordDocs* getWordDoc(char* word, int mode, WordDocs* index[]){
	int pos = hash(word);
	WordDocs *newWordDoc,*currentWordDoc, *previousWordDoc;
	if(mode == 0){// if WordDoc doesn't exist. we create it in the index
		printf("** %d\n", pos);
		//printf("ici  AA0000\n");
		if(index[pos] == NULL){
			 printf("ici  6760000\n");
			newWordDoc = malloc(sizeof(WordDocs));
			if(newWordDoc==NULL) 
			{
				fprintf(stderr,"Erreur NuLl ligne 72\n");
			}
			printf("ici  A\n");
			newWordDoc->nextDocument = NULL;
			printf("ici  B\n");
			newWordDoc->nextWord = NULL;
			printf("ici  C\n");
			newWordDoc->nbApparition = 0;
			printf("ici  D = int=%d et chaine=%s \n",strlen(word),word);
			newWordDoc->word = malloc(((int)strlen(word))*sizeof(char));
			printf("ici  E\n");
			strcpy(newWordDoc->word,word);
			printf("ici  F\n");
			index[pos] =  newWordDoc;
			 printf("ici  9660000\n");
			return newWordDoc;
		}
		else{
			//printf("ici 7800000\n");
			currentWordDoc = index[pos];
			//printf("ici 800000000\n");
			previousWordDoc = currentWordDoc;
			//printf("ici ba\n");
			while(currentWordDoc!=NULL && strcmp(currentWordDoc->word,word)){
				//printf("ici jh\n");
				 previousWordDoc = currentWordDoc;
				 currentWordDoc = currentWordDoc->nextWord;
			 }
			//printf("ici 84\n");
			if(currentWordDoc == NULL){
			// printf("ici 86\n");
				newWordDoc = malloc(sizeof(WordDocs));
				newWordDoc->nextDocument = NULL;
				newWordDoc->nextWord = NULL;
				newWordDoc->nbApparition = 0;
				newWordDoc->word = malloc(strlen(word)*sizeof(char));
				strcpy(newWordDoc->word,word);
				previousWordDoc->nextWord = newWordDoc;
				return newWordDoc;
			}return currentWordDoc;
		}
	}else if(mode == 1){// returns the WordDoc if exists else returns NULL
		if(index[pos] != NULL){
			currentWordDoc = index[pos];
			while(currentWordDoc!=NULL && strcmp(currentWordDoc->word,word)) currentWordDoc = currentWordDoc->nextWord;
			return currentWordDoc;
		}
		return NULL;
	}
}
void insertDoc(WordDocs *word,char* doc_name,int nbOcc){
	Doc *previousDoc, *currentDoc, *newDoc;
	currentDoc = word->nextDocument;
	previousDoc = currentDoc;
	newDoc = malloc(sizeof(Doc));
	while(currentDoc!=NULL && currentDoc->nbOcc > nbOcc){
		previousDoc = currentDoc;
		currentDoc = currentDoc->nextDoc;
	}
	newDoc->document_name = malloc(strlen(doc_name)*sizeof(char));
	strcpy(newDoc->document_name, doc_name);
	newDoc->nbOcc = nbOcc;
	if(previousDoc != currentDoc){
		newDoc->nextDoc = currentDoc;
		previousDoc->nextDoc = newDoc;
	}else{
		newDoc->nextDoc = currentDoc;
		word->nextDocument = newDoc;
	}
	word->nbApparition += nbOcc;
}
void addDocToIndex(char* word, char* doc_name, int nbOcc,WordDocs* index[]){
	printf("Ligne 132\n");
	WordDocs* wordDoc = getWordDoc(word, 0, index);
	printf("Ligne 133\n");
	insertDoc(wordDoc, doc_name, nbOcc);
}
void affichage(WordDocs *index[], int size){
	int i;
	WordDocs *currentWordDoc;
	Doc *currentDoc;
	for(i=0;i<size;i++){
		if(index[i]!=NULL){
			currentWordDoc = index[i];
			while(currentWordDoc != NULL){
				printf("mot: %s nbApparition: %d ", currentWordDoc->word, currentWordDoc->nbApparition);
				currentDoc = currentWordDoc->nextDocument;
				while(currentDoc != NULL){
					printf("| %s %d | ",currentDoc->document_name, currentDoc->nbOcc);
					currentDoc = currentDoc->nextDoc;
				}
				currentWordDoc = currentWordDoc->nextWord;
				printf("\n");
			}
		}
	}
}
void afficherMotNbApparition(WordDocs *index[], int size){
	if(nbMotTotal(index, size)){
		int i,j;
		WordDocs *currentWordDoc;
		printf("╔════════════════════════════════════╦═════════════════════════════════════════╗\n");
		printf("║ Le Mot                             ║ Nombre d'apparition                     ║\n");
		printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
		for(i=0;i<size;i++){
			if(index[i]!=NULL){
				currentWordDoc = index[i];
				while(currentWordDoc != NULL){
					printf("║ %s ", currentWordDoc->word); 
					for(j=0;j<34-strlen(currentWordDoc->word);j++) printf(" ");
					printf("║ %d ",currentWordDoc->nbApparition);
					for(j=0;j<39-nbChiffre(currentWordDoc->nbApparition);j++) printf(" ");
					printf("║\n");
					printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
					currentWordDoc = currentWordDoc->nextWord;
				}
			}
		}
		printf("╚════════════════════════════════════╩═════════════════════════════════════════╝\n");
	} else printf("L'index est vide!\n");
}
int nbMotTotal(WordDocs *index[], int size){
	int i, counter=0;
	WordDocs *currentWordDoc;
	for(i=0;i<size;i++){
		if(index[i]!=NULL){
			currentWordDoc = index[i];
			while(currentWordDoc != NULL){
				counter++;
				currentWordDoc = currentWordDoc->nextWord;
			}
		}
	}
	return counter;
}
int nbMotFigure1fois(WordDocs *index[], int size){
	int i, counter=0;
	WordDocs *currentWordDoc;
	for(i=0;i<size;i++){
		if(index[i]!=NULL){
			currentWordDoc = index[i];
			while(currentWordDoc != NULL){
				if(currentWordDoc->nbApparition ==1) counter++;
				currentWordDoc = currentWordDoc->nextWord;
			}
		}
	}
	return counter;
}

void show_header(){
	printf("╔══════════════════════════════════════════════════════════════════════════════╗\n");
	printf("║                            Projet de compilation                             ║\n");
	printf("║                           Recherche d'information                            ║\n");
	printf("╚══════════════════════════════════════════════════════════════════════════════╝\n");
	printf("\n\n");
}
void show_menu(){
	show_header();
	printf("Index chargé avec succes!\n\n");
	printf("1- Le nombre de mots total du corpus!\n");
	printf("2- Le nombre de mots figurant juste une fois dans le corpus!\n");
	printf("3- La fréquence d’apparition de chaque mot dans le corpus!\n");
	printf("4- Les 4 mots les plus utilisés dans le corpus!\n");
	printf("5- Quit!\n\n\n");

}
int nbChiffre(int a){
	int counter=0;
	while(a!=0){
		counter++;
		a/=10;
	}
	return counter;
}
//***********************Main
int main(){
	FILE* input;
	char mot[200], docName[200];
	int nb; 
	char choix;
	WordDocs *index[1000];
	//Chargement de l'index
	initIndex(index, 1000);
	input = fopen("index.txt", "r");
	while(fscanf(input,"%s %d %s", mot, &nb, docName)!=EOF) addDocToIndex(mot,docName,nb, index);
	sort(index,0,999);
	// Fin de chargement de l'index
	while(1){
		system("cls");
		show_menu();
		// lecture de choix
		do{
			choix = getchar();
		}while(choix<49 || choix > 53);
		//Switch
		switch(choix){
			case '1':
				system("cls");
				show_header();
				printf("Le nombre de mots total du corpus est: %d\n", nbMotTotal(index,1000));
				printf("press any key to go back to main menu!\n");
				getchar();
				getchar();
				break;
			case '2':
				system("cls");
				show_header();
				printf("Le nombre de mots figurant juste une fois dans le corpus est: %d\n", nbMotFigure1fois(index,1000));
				printf("press any key to go back to main menu!\n");
				getchar();
				getchar();
				break;
			case '3':
				system("cls");
				show_header();
				printf("La fréquence d’apparition de chaque mot dans le corpus:\n\n\n");
				afficherMotNbApparition(index,1000);
				//affichage(index,1000);
				printf("press any key to go back to main menu!\n");
				getchar();
				getchar();
				break;
			case '4':
				system("cls");
				show_header();
				int j;
				printf("Les 4 mots les plus utilisés dans le corpus sont:\n\n");
				printf("╔════════════════════════════════════╦═════════════════════════════════════════╗\n");
				printf("║ Le Mot                             ║ Nombre d'apparition                     ║\n");
				printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
				printf("║ %s ", index[0]->word); 
				for(j=0;j<34-strlen(index[0]->word);j++) printf(" ");
				printf("║ %d ",index[0]->nbApparition);
				for(j=0;j<39-nbChiffre(index[0]->nbApparition);j++) printf(" ");
				printf("║\n");
				printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
				printf("║ %s ", index[1]->word); 
				for(j=0;j<34-strlen(index[1]->word);j++) printf(" ");
				printf("║ %d ",index[1]->nbApparition);
				for(j=0;j<39-nbChiffre(index[1]->nbApparition);j++) printf(" ");
				printf("║\n");
				printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
				printf("║ %s ", index[2]->word); 
				for(j=0;j<34-strlen(index[2]->word);j++) printf(" ");
				printf("║ %d ",index[2]->nbApparition);
				for(j=0;j<39-nbChiffre(index[2]->nbApparition);j++) printf(" ");
				printf("║\n");
				printf("╠════════════════════════════════════╬═════════════════════════════════════════╣\n");
				printf("║ %s ", index[3]->word); 
				for(j=0;j<34-strlen(index[3]->word);j++) printf(" ");
				printf("║ %d ",index[3]->nbApparition);
				for(j=0;j<39-nbChiffre(index[3]->nbApparition);j++) printf(" ");
				printf("║\n");
				printf("╚════════════════════════════════════╩═════════════════════════════════════════╝\n");
				printf("press any key to go back to main menu!\n");
				getchar();
				getchar();
				break;
			case '5':
				printf("Good bye!\n");
				break;
		}
		if(choix == '5') break;
	}
	
	//affichage(index, 1000);
	//show_menu();
	fclose(input);
	return 0;
}
