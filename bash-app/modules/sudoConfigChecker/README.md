# sudoConfigChecker

## Description

`sudoConfigChecker` est un module Bash permettant d’analyser la configuration du fichier `/etc/sudoers` pour détecter des entrées potentiellement risquées, notamment celles autorisant l’usage de sudo sans mot de passe (`NOPASSWD`).

Le module évalue la sécurité des privilèges `sudo`, fournit un score et génère une recommandation pour sécuriser les comptes et les scripts utilisant sudo.



## Fonctionnalités
Vérification de l’accessibilité du fichier `/etc/sudoers`.
Analyse des lignes actives (non commentées) pour détecter `NOPASSWD`.
Calcul d’un score sur 5 niveaux selon la présence d’entrées risquées.
Génération d’une recommandation détaillée listant les lignes suspectes.
Sortie standardisée en JSON incluant :
`status` : OK ou FAIL
`error` : message d’erreur éventuel
`score` : note sur 5
`recommendation` : résumé des entrées sudo risquées



## Structure

sudoConfigChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : aucune entrée risquée détectée.
* **Score 2** : présence d’entrées `NOPASSWD`.
* **Score 0** : fichier `/etc/sudoers` inaccessible ou lecture impossible.

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : fichier sudoers introuvable ou inaccessible.



## Utilisation
```bash
./main.sh --script sudoConfigChecker 
```

## Mode test
```bash
./main.sh --script sudoConfigChecker --test 
```


## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Entrées sudo potentiellement risquées (NOPASSWD) : user ALL=(ALL) NOPASSWD: ALL"
}
```



## Bonnes pratiques
* Limitez l’utilisation de `NOPASSWD` aux scripts ou utilisateurs absolument nécessaires.
* Vérifiez régulièrement le fichier sudoers après modifications ou déploiements automatiques.
* Combinez avec un audit des groupes sudo et des utilisateurs ayant des droits étendus.
* Surveillez les changements de configuration sudo pour détecter toute élévation de privilèges non autorisée.