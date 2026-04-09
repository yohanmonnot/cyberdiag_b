# osInfo

## Description

`osInfo` est un module Bash permettant de récupérer des informations essentielles sur le système d’exploitation, notamment le nom de l’OS, sa version, la version du noyau Linux et l’état de support.

Le module évalue si le système est potentiellement à jour ou obsolète et fournit un score de sécurité ainsi qu’une recommandation.



## Fonctionnalités
* Lecture des informations système via `/etc/os-release`.
* Récupération du nom et de la version du système d’exploitation.
* Récupération de la version du noyau via `uname -r`.
* Évaluation du statut de support (simplifiée).
* Calcul d’un score sur 5 niveaux selon la version du système.
* Génération d’une recommandation détaillée.
* Intégration avec :
* système de logs (`logger.sh`)
* variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé des informations système



## Structure

osInfo/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : système récent et probablement supporté.
* **Score 3** : système potentiellement obsolète.
* **Score 0** : fichier `/etc/os-release` inaccessible.

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : informations système indisponibles.



## Utilisation
```bash
./main.sh --script osInfo
```

### Mode test
```bash
./main.sh --script osInfo --test
```


## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "OS: Ubuntu 22.04\nKernel: 5.15.0-84-generic\nSupport: Supported"
}
```



## Bonnes pratiques
* Maintenez votre système à jour avec une version supportée.
* Vérifiez régulièrement la version du noyau pour bénéficier des correctifs de sécurité.
* Planifiez les mises à niveau des systèmes obsolètes.
* Combinez ce module avec `updateConfigChecker` pour un suivi complet des mises à jour.