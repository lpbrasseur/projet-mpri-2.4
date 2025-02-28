# Compte-rendu

## Travail effectué

### Tâche 1 : uninitialied_places dataflow analysis

J'ai eu du mal à comprendre dans un premier temps la structure du code MiniMIR, en particulier certaines transformations comme `let mut x : S;` dans le test 32, ou le fait qu'un programme MiniMIR correspond à une unique fontion, et non tout le fichier. J'ai cependant décidé de ne pas implémenter de pretty-printer par manque de temps.
Finalement, j'ai pu en discutant avec mes camarades comprendre toute la structure du code MiniMIR et complèter correctement sans grosse difficultée les deux fonctions.

### Tâche 2 : mutable borrow below shared write/create check

Ici, à nouveau j'ai eu du mal à comprendre comment MiniMIR distingue une assignation et une définition; ce qui au final n'est pas fait directement dans les instructions. Une fois cette subtilité comprise, j'ai écrit deux fonctions qui testent les propriétés et produisent une erreur s'il le faut pour les cas de places et right value. Il faut ensuite donc simplement parcourir les instructions et effectuer les tests si ce sont des assignations ou un appel de fonction.

### Tâche 3 : generating lifetime constraints 

J'ai d'abord écrit quelques fonctions pour ajouter inductivement les contraintes sur les types, avec unification ou outlive. Ensuite, je parcours les instructions et j'unifie correctement pour les assignations, en distinguant le cas d'un borrow. Pour le cas d'un make, il faut générer les nouveaux types avec `fields_types_fresh`. Pour le cas des fonctions également, mais il faut en plus générer les contraintes renvoyées par la fonction de génération `fn_prototype_fresh`. Pour les living constraints, j'iter directement sur les free lifetimes de chaque live local, puis sur les generic lifetimes.

### Tâche 4 : checking lifetime declared are enough

J'écris une fonction qui fait le test et produit une erreur, une autre qui itère ce test sur les lifetimes lft' telles ques lft : lft' pour lft donnée. Puis j'itère sur toutes les lifetimes lft.

### Tâche 5 : conflicting borrows

J'ai ajouté le cas Icall, cependant j'ai l'impression que ce test est déjà fait par le type checker, et je passais tous les tests avant de la remplire.

## Retour

J'ai eu du mal à prendre le code en main, notamment à comprendre quelles instructions MiniMIR sont produites. N'ayant jamais programmé en Rust avant ce cours, j'ai passé également un temps considérable à comprendre le fonctionnement des borrows, et des lifetimes.