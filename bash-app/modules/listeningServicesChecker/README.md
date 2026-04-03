# listeningServicesChecker

## Description

`listeningServicesChecker` est un module Bash permettant d’analyser les services et processus rattachés aux ports ouverts sur un système Linux.

Le module détecte les services en écoute, compare avec une liste blanche de services connus, et fournit un score de sécurité ainsi qu’une recommandation selon la légitimité des services détectés.



## Fonctionnalités
* Analyse des ports en écoute via `ss`.
* Identification des processus associés aux ports ouverts.
* Vérification par rapport à une liste blanche de services standards :
    * `sshd`, `systemd-resolved`, `cupsd`, `apache2`, `nginx`, `docker`
* Détection de services suspects ou non identifiés.
* Calcul d’un score sur 5 niveaux selon la criticité.
* Génération d’une recommandation détaillée.
* Mode test interne (`--test`) pour simuler différents scénarios.
* Sortie standardisée en JSON incluant :
    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé sur la légitimité des services



## Structure

listeningServicesChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation du module.



## Logique d’évaluation
* **Score 5** : tous les services en écoute sont connus et légitimes.
* **Score 2** : un ou plusieurs services suspects détectés.
* **Score 0** : impossible d’analyser les services (ex: permissions insuffisantes).

## États possibles
* **OK** : vérification réalisée.
* **FAIL** : erreur ou impossibilité d’accéder aux informations des services.



## Utilisation

```
./main.sh
```

## Mode test interne

```
./main.sh --test
```



## Exemple de sortie JSON
```
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Services suspects ou non identifiés détectés : nc, xyz"
}
```



## Bonnes pratiques

* Vérifiez régulièrement les services en écoute pour détecter toute activité non autorisée.
* Complétez la liste blanche avec vos services spécifiques autorisés.
* Surveillez les ports ouverts après installation ou mise à jour de nouveaux services.
* Combinez ce module avec openPortsScanner et networkTrafficMonitor pour un audit complet.