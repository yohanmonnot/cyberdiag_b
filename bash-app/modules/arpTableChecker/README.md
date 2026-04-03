# arpTableChecker

## Description

`arpTableChecker` est un module Bash permettant de détecter les anomalies dans la table ARP d’un système Linux, notamment les doublons d’adresses MAC pouvant indiquer un ARP poisoning.

Le module analyse la table ARP locale, calcule un score de sécurité et fournit des recommandations selon la présence ou non de doublons.



## Fonctionnalités
* Analyse de la table ARP via `ip neigh show`.
* Détection des doublons de MAC associées à plusieurs IP.
* Calcul d’un score sur 5 niveaux selon la santé de la table ARP.
* Génération d’une recommandation détaillée.
* Mode test interne (`--test`) pour simuler différents scénarios.
* Intégration avec :
    * système de logs (`logger.sh`)
    * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé sur l’état de la table ARP



## Structure

arpTableChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : table ARP saine, aucune duplication détectée.
* **Score 1** : duplication de MAC détectée (suspicion d’ARP Poisoning).
* **Score 0** : table ARP inaccessible ou erreur de lecture.

## États possibles
* **OK** : vérification réalisée avec succès.
* **FAIL** : table ARP inaccessible ou erreur lors de la lecture.



## Utilisation
```bash
./main.sh --script arpTableChecker
```

## Mode test 
```bash
./main.sh --script arpTableChecker --test
```



## Exemple de sortie JSON
Cas sain :
```json
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "Table ARP saine. Aucune duplication détectée."
}
```
Cas ARP Poisoning :
```json
{
  "status": "OK",
  "error": "",
  "score": 1,
  "recommendation": "Alerte : Plusieurs adresses IP partagent la même adresse MAC (00:11:22:33:44:55). Suspicion d'ARP Poisoning."
}
```



## Bonnes pratiques
* Vérifiez régulièrement votre table ARP pour détecter toute anomalie.
* Utilisez ce module dans un audit complet de sécurité réseau.
* Combinez avec la surveillance DHCP et les logs de switch pour identifier d’éventuels intrus.
* Surveillez les doublons MAC dans des environnements sensibles ou publics.