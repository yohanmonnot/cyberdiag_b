# userAccountChecker

## Description

`userAccountChecker` est un module Bash permettant d’identifier les comptes utilisateurs inutiles ou inactifs sur un système Linux.

Le module analyse les comptes ayant un shell actif et les comptes n’ayant pas été utilisés depuis un certain temps (90 jours par défaut). Il fournit un score de sécurité et des recommandations pour sécuriser les comptes.



## Fonctionnalités
* Détection des comptes avec un shell actif.
* Détection des comptes inactifs depuis plus de 90 jours via `lastlog`.
* Calcul d’un score sur 5 niveaux selon la présence ou non de comptes inactifs ou inutiles.
* Génération d’une recommandation détaillée incluant la liste des comptes concernés.
* Mode test interne possible (adaptable).
* Intégration avec :
  * système de logs (logger.sh)
  * variables d’environnement (env.sh)
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé sur les comptes détectés



## Structure

userAccountChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : aucun compte inutile ou inactif détecté.
* **Score 3** : présence de comptes actifs non utilisés ou inactifs depuis >90 jours.
* **Score 0** : erreur lors de la collecte des informations.

## États possibles
* **OK** : vérification réalisée avec succès.
* **FAIL** : erreur lors de la lecture des comptes ou fichiers systèmes.



## Utilisation
```bash
./main.sh --script userAccountChecker
```
### Mode test
```bash
./main.sh --script userAccountChecker --test
```


## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Comptes avec shell actif :\nuser1 /bin/bash\nuser2 /bin/bash\n\nComptes inactifs depuis >90 jours :\nuser3 01 Jan 2024\nuser4 15 Dec 2023"
}
```



## Bonnes pratiques
* Supprimez ou désactivez les comptes inutiles ou inactifs.
* Appliquez cette vérification régulièrement dans un audit complet des utilisateurs.
* Combinez avec les logs d’accès et les politiques de mot de passe pour sécuriser le système.
* Vérifiez les comptes système sensibles pour éviter toute élévation de privilèges non autorisée.