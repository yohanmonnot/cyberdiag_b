# sshConfigChecker

## Description

`sshConfigChecker` est un module Bash permettant de vérifier la configuration du service SSH sur un système Linux.

Le module analyse les paramètres critiques du fichier `sshd_config`, notamment `PermitRootLogin` et `PasswordAuthentication`, afin d’identifier des configurations potentiellement risquées. Il fournit un score de sécurité et une recommandation adaptée.



## Fonctionnalités
* Vérification de l’accessibilité du fichier `/etc/ssh/sshd_config`.
* Analyse des paramètres critiques :
  * `PermitRootLogin`
  * `PasswordAuthentication`
* Détection des configurations faibles (connexion root autorisée ou authentification par mot de passe activée).
* Calcul d’un score sur 5 niveaux selon la configuration SSH.
* Génération d’une recommandation détaillée.
* Mode test interne possible (adaptable).
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé de la configuration SSH



## Structure

sshConfigChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : configuration sécurisée (root désactivé et authentification par clé recommandée).
* **Score 2** : configuration risquée (root autorisé ou authentification par mot de passe activée).
* **Score 0** : fichier de configuration inaccessible.

## États possibles
* **OK** : vérification réalisée avec succès.
* **FAIL** : fichier sshd_config introuvable ou inaccessible.



## Utilisation
```bash
./main.sh --script sshConfigChecker 
```

### Mode test
```bash
./main.sh --script sshConfigChecker --test
```

## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "PermitRootLogin: yes\nPasswordAuthentication: yes"
}
```



## Bonnes pratiques
* Désactivez `PermitRootLogin` pour éviter les connexions directes en root.
* Désactivez `PasswordAuthentication` et privilégiez l’authentification par clé SSH.
* Restreignez l’accès SSH via des règles firewall ou des listes d’IP autorisées.
* Surveillez régulièrement la configuration SSH pour détecter toute modification non autorisée.