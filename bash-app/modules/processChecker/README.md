# processChecker

## Description

`processChecker` est un module Bash permettant d’analyser les processus actifs sur un système Linux afin de détecter des comportements suspects.

Le module identifie notamment les processus exécutés en tant que root non standards ainsi que les ports ouverts associés. Il fournit un score de sécurité et une recommandation basée sur les anomalies détectées.



## Fonctionnalités
* Vérification de la présence de la commande `lsof`.
* Analyse des processus actifs via `ps`.
* Détection des processus root suspects (hors processus système connus comme `sshd` ou `systemd`).
* Analyse des ports ouverts en écoute (`LISTEN`) via `lsof`.
* Calcul d’un score sur 5 niveaux selon la présence d’anomalies.
* Génération d’une recommandation détaillée incluant les processus suspects et les ports ouverts.
* Mode test interne possible (adaptable).
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé des processus et ports détectés



## Structure

processChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : aucun processus suspect détecté.
* **Score 2** : présence de processus root suspects.
* **Score 0** : dépendance manquante (`lsof`) ou erreur d’exécution.

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : `lsof` introuvable ou inaccessible.



## Utilisation
```bash
./main.sh --script processChecker 
```

### Mode test
```bash
./main.sh --script processChecker --test
```



## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Processus root suspects :\nroot 1234 /tmp/malware\n\nPorts ouverts :\ntcp LISTEN 0 128 0.0.0.0:8080"
}
```



## Bonnes pratiques
* Surveillez régulièrement les processus exécutés en tant que root.
* Analysez les ports ouverts pour identifier les services non nécessaires.
* Supprimez ou investigatez tout processus inconnu ou suspect.
* Combinez ce module avec `openPortsScanner` et `listeningServicesChecker` pour une analyse complète.
* Utilisez des outils de monitoring pour détecter en temps réel les comportements anormaux.