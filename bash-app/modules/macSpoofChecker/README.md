# macSpoofChecker

## Description
`macSpoofChecker` est un module Bash permettant de détecter la présence de MAC spoofing sur un système Linux.

Le module compare l’adresse MAC actuelle d’une interface réseau avec l’adresse MAC matérielle originale. Il fournit un score de sécurité et une recommandation selon que l’adresse MAC a été modifiée ou non.



## Fonctionnalités

* Détection de l’interface réseau par défaut.
* Récupération de l’adresse MAC actuelle via `/sys/class/net`.
* Récupération de l’adresse MAC matérielle via `ethtool` (si disponible).
* Comparaison entre MAC actuelle et MAC matérielle.
* Calcul d’un score sur 5 niveaux selon la conformité.
* Génération d’une recommandation détaillée.
* Mode test interne (`--test`) pour simuler différents scénarios.
* Intégration avec :

    * système de logs (`logger.sh`)
    * variables d’environnement (`env.sh`)

* Sortie standardisée en JSON incluant :

    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé sur la conformité de l’adresse MAC



## Structure

macSpoofChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : adresse MAC conforme au matériel.
* **Score 3** : adresse MAC modifiée ou spoofing détecté.
* **Score 0** : aucune interface réseau active ou information indisponible.

## États possibles
* **OK** : vérification réalisée.
* **FAIL** : interface réseau introuvable ou accès refusé.



## Utilisation

```bash
./main.sh --script macSpoofChecker
```

## Mode test 

```bash
./main.sh --script macSpoofChecker --test
```



## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "Adresse MAC conforme au matériel."
}
```



## Bonnes pratiques

* Vérifiez régulièrement les interfaces réseau pour détecter toute modification non autorisée.
* Utilisez ce module dans un audit complet de sécurité réseau.
* Combinez avec la surveillance DHCP et les logs de switch pour identifier  d’éventuels intrus.
* Surveillez les changements de MAC dans des environnements sensibles ou publics.