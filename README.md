# LA-Godot-Demo

## Tuto des trucs qu'on a hardcodé sur cette branche


### Faire des commentaires sur les noeuds React :

Sur le nom d'un noeud : . _Commentaire Bob
    => Affichera "Bob" en jeu.
    Pensez au point !

### Pour déplacer un pnj : 

Dire ". {action} {action} {action} ..."
action : M (= Move) / {Direction} / Cases (< 10)
        PM (Player Move) / {Direction} / Cases (< 10)
        L (= Look) / {Direction}
        PL (Player Look) / {Direction}
=> MN5 déplacera le pnj de 5 cases vers le nord.
=> LS fera regarder le pnj vers le sud.
=> PME4 déplacera le joueur de 4 cases vers l'est.
=> PLO fera regarder le joueur vers l'ouest.
(Directions = N = Nord / S = Sud / E = Est / O = Ouest)

(Note : Il existe également un mot LOOK)
(LOOK N => fera regarder le pnj vers le nord)
(Il est juste utile maintenant si vous ne voulez pas qu'un pnj vous regarde quand vous interagissez)
(Un pnj regardant au nord par défaut, si sa première action est un "LOOK N", il  ne se tournera pas pour vous parler)


### Pour faire disparaitre un pnj :

Dire : "DISPARAITRE"

### Pour faire apparaitre un pnj :

Il faut que par défaut, il ne soit pas visible.
Pour cela, dans son, rajoutez un commentaire "_NV" (= Non Visible)
Exemple : ". _NV Bob" => Bob ne sera pas visible par défaut.

Dire : "APPARAITRE" le rendra visible


### Pour faire disparaitre les collisions d'un pnj :
Dire : "OFF_COLLISION"
(Attention, les collisions réapparaissent si le pnj bouge.)



### Autres mots-clés plus spécifiques : 

Dire :
"WARP" => Téléporte dans la maison H1_F0 de LAlini
"WARPEND" => Téléporte à la fin du jeu.
"ACTE3" => Par défaut, les noeuds d'id > 215 et < 300 sont cachés
            (si vous voulez retirer ça, c'est une simple boucle for, dans le _ready du script "actions_manager")

            Cette action fait disparaitre les pnj d'id -20 à 200, fait appariatre tout les autres, sauf ceux ayant _NV
            (Oui c'est très spécifique. Ca m'a surtout permis de pas me casser la tête à faire disparaitre tout les pnjs - Joris)