# cliInterface

## Description

`cliInterface` est un module Bash qui fournit une interface en ligne de commande (CLI) factice pour démonstration ou test. Il affiche un menu simple et journalise les actions effectuées.

Ce module est principalement destiné aux tests et à la simulation d’une interface CLI sans exécuter de logique métier réelle.



## Fonctionnalités
* Affichage d’un menu CLI minimal :
    1) Lancer test
    2) Quitter
* Journalisation des étapes via `logger.sh` :
    * Début de la CLI
    * Affichage du menu
    * Fin de la CLI
* Démonstration du flux d’une interface utilisateur en terminal.



## Structure

cliInterface/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal de la CLI factice.
* `README.md` : documentation du module.



## Utilisation
```bash
./main.sh --script cliInterface
```



## Exemple de sortie

=== CLI FACTICE ===
1) Lancer test
2) Quitter



## Journalisation
Les logs générés via `logger.sh` ressemblent à ceci :

```
INFO: cliInterface: lancement CLI factice
INFO: cliInterface: affichage menu factice
INFO: cliInterface: fin factice
```



## Bonnes pratiques
Utile pour tester l’intégration des modules CLI dans l’application.
Peut être étendu pour exécuter des actions réelles en réponse aux choix de menu.
Assurer que `logger.sh` est disponible pour que la journalisation fonctionne correctement.