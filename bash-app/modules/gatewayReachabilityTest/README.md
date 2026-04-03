# gatewayReachabilityTest

## Description

`gatewayReachabilityTest` est un module Bash permettant de vérifier la joignabilité de la passerelle par défaut d’un système Linux.

Le module effectue un test de ping vers la gateway définie dans la table de routage pour déterminer si le système peut communiquer avec sa passerelle locale. Il fournit un score de disponibilité ainsi qu’une recommandation adaptée pour l’administrateur.



## Fonctionnalités

* Détection automatique de la passerelle par défaut.
* Test de ping ICMP vers la gateway.
* Calcul d’un score sur 5 niveaux selon la réussite du test.
* Génération d’une recommandation claire en cas d’échec.
* Mode test interne (`--test`) pour simuler les scénarios de succès ou d’échec.
* Sortie JSON standardisée incluant :
    * status : OK ou FAIL
    * error : message d’erreur éventuel
    * score : note sur 5
    * recommendation : résumé de l’état de la gateway



## Structure

gatewayReachabilityTest/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation du module.



## Logique d’évaluation

* **Score 5** : Passerelle joignable (ping réussi).
* **Score 1** : Passerelle non joignable (ping échoué).

## États possibles

* **OK** : test de connectivité vers la gateway exécuté.
* **FAIL** : aucune route par défaut définie ou commande ping indisponible.



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
  "recommendation": "Passerelle (192.168.1.1) joignable."
}
```



## Bonnes pratiques

* Vérifiez régulièrement la connectivité vers la passerelle pour éviter toute isolation réseau.
* Combinez ce module avec `internetConnectivityTest` et `networkConfigChecker` pour un audit réseau complet.
* Surveillez la disponibilité après modification des configurations réseau ou du routeur.