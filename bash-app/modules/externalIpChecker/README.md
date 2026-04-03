# externalIpChecker

## Description

`externalIpChecker` est un module Bash qui vérifie l'adresse IP publique de la machine en interrogeant un service externe (`ifconfig.me`). Il permet de confirmer la connectivité Internet et de récupérer l’IP visible sur le réseau public.

Le module génère un score simple et fournit des recommandations en cas d’absence de connectivité ou de problème d’accès à Internet.



## Fonctionnalités
* Détection de l’adresse IP publique via curl.
* Vérification de la connectivité Internet.
* Attribution d’un score sur 5 basé sur la disponibilité de l’IP.
* Génération de recommandations et messages d’erreur.
* Mode test interne (`--test`) pour simuler les différents cas.
* Sortie JSON standardisée incluant :

    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé de l’état du réseau



## Structure

externalIpChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation du module.



## Logique d’évaluation
* **Score 5** : IP publique récupérée avec succès.
* **Score 0** : Impossible d’accéder à Internet ou IP non détectée.

## États possibles
* **OK** : IP publique récupérée et Internet accessible.
* **FAIL** : Pas d’accès Internet ou service externe indisponible.



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
  "score": 5,
  "recommendation": "IP Publique : 203.0.113.42"
}
```



## Bonnes pratiques

* Vérifier que curl est installé sur la machine.
* Exécuter ce module pour confirmer la connectivité avant des opérations réseau sensibles.
* Peut être utilisé conjointement avec `internetConnectivityTest` pour un audit complet de la connectivité.