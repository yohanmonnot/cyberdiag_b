# firewallRulesAudit

## Description

`firewallRulesAudit` est un module Bash qui analyse les règles de firewall locales (iptables) pour évaluer leur niveau de sécurité. Il détecte notamment les règles permissives susceptibles d’exposer le système à des risques réseau.

Le module fournit un score de sécurité basé sur la configuration des règles et génère des recommandations pour renforcer la politique firewall.



## Fonctionnalités
* Analyse automatique des règles `iptables` locales.
* Détection des règles `ACCEPT` trop larges ou non restreintes.
* Évaluation du niveau de sécurité via un score sur 5 niveaux.
* Génération de recommandations pour durcir le firewall.
* Mode test interne (`--test`) pour simuler différents scénarios.
* Sortie JSON standardisée incluant :
    * `status` : OK ou FAIL
    * `error` : message d’erreur éventuel
    * `score` : note sur 5
    * `recommendation` : résumé de l’état du firewall



## Structure

firewallRulesAudit/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation du module.


## Logique d’évaluation
* **Score 5** : Politique restrictive / sécurisée (bonnes pratiques respectées).
* **Score 3** : Plusieurs règles permissives détectées (réviser les règles ACCEPT).
* **Score 0** : Firewall absent ou configuration critique.

## États possibles
* **OK** : Audit terminé sans erreur.
* **FAIL** : Commande `iptables` introuvable ou problème d’exécution.



## Utilisation

```bash
./main.sh --script firewallRulesAudit
```

## Mode test 

```bash
./main.sh --script firewallRulesAudit --test
```



## Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Plusieurs règles ACCEPT très larges détectées. Revoyez votre politique 'Default Drop'."
}
```



## Bonnes pratiques

* Maintenez une politique `Default Drop` pour toutes les chaînes.
* Limitez les règles `ACCEPT` aux IP et ports nécessaires.
* Combinez ce module avec `openPortsScanner` et `listeningServicesChecker` pour un audit complet de la surface d’exposition réseau.
* Vérifiez régulièrement après modifications des règles ou installation de services réseau.