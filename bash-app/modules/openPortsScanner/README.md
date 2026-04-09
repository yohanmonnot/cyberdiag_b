# openPortsScanner

## Description

`openPortsScanner` est un module Bash permettant de scanner les ports ouverts sur un système Linux.

Il analyse les services en écoute sur la machine afin d’évaluer la surface d’exposition réseau et d’identifier d’éventuels risques liés à un trop grand nombre de ports ouverts.

Le module fournit un score de sécurité ainsi qu’une recommandation pour limiter les risques d’attaque.



## Fonctionnalités

* Vérification de la disponibilité de la commande `ss` (iproute2).
* Scan des ports ouverts en écoute (TCP/UDP).
* Comptage du nombre total de ports ouverts.
* Évaluation de la surface d’exposition réseau.
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération d’une recommandation adaptée.
* Mode test simple (`--test`).
* Intégration avec :

  * système de logs (`logger.sh`)
  * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

  * `status` : OK / FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : analyse de l’exposition réseau


## Structure

openPortsScanner/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : peu de ports ouverts (≤ 5) → surface d’exposition minimale.
* **Score 4** : nombre de ports raisonnable (entre 6 et 15).
* **Score 3** : trop de ports ouverts (> 15) → risque accru.

### États possibles

* **OK** : analyse réalisée.
* **FAIL** : dépendance manquante (`ss`).



## Utilisation

```bash 
./main.sh --script openPortsScanner
```

### Mode test

```bash 
./main.sh --script openPortsScanner --test
```



## Exemple de sortie JSON

```json 
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Nombre de ports raisonnable (8)."
}
```



## Bonnes pratiques

* Fermer les ports inutilisés.
* Désactiver les services non nécessaires.
* Utiliser un pare-feu (iptables, nftables, ufw).
* Surveiller régulièrement les ports ouverts.
* Limiter l’exposition des services critiques.
* Intégrer ce module dans un audit de sécurité global.


