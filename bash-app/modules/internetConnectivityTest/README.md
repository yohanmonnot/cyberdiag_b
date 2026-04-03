# internetConnectivityTest

## Description

`internetConnectivityTest` est un module Bash permettant de vérifier la connectivité Internet d’un système Linux.

Le module effectue un test de ping vers une IP publique (par défaut 8.8.8.8) pour déterminer si le système peut accéder à Internet et fournit un score de disponibilité ainsi qu’une recommandation adaptée.



## Fonctionnalités
* Test de connectivité Internet via ping ICMP.
* Détection de l’accessibilité du réseau externe.
* Calcul d’un score sur 5 niveaux selon le succès du test.
* Génération d’une recommandation claire.
* Mode test interne (`--test`) pour simuler les scénarios de succès ou d’échec.
* Sortie JSON standardisée incluant :

    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé de l’état de connectivité



## Structure

internetConnectivityTest/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation du module.



## Logique d’évaluation
* **Score 5** : Internet accessible (ping réussi).
* **Score 0** : Internet inaccessible (ping échoué).

## États possibles
* **OK** : test de connectivité exécuté.
* **FAIL** : impossibilité de réaliser le test (ex: commande ping absente).



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
  "recommendation": "Connexion Internet OK."
}
```



## Bonnes pratiques
* Vérifiez régulièrement la connectivité Internet, surtout pour les systèmes devant accéder à des services distants.
* Combinez ce module avec `vpnChecker` ou `networkTrafficMonitor` pour un audit réseau complet.
* Surveillez la connectivité après changement de routeur, firewall ou configuration réseau.