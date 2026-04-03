# passwordChecker

## Description

`check_password` est un module Bash permettant de vérifier la politique de mot de passe configurée sur un système Linux via PAM.

Il analyse les paramètres de sécurité liés aux mots de passe (longueur minimale, complexité, historique) à partir des fichiers de configuration système et évalue leur conformité avec les bonnes pratiques.

Le module fournit un score global ainsi que des recommandations afin d’améliorer la sécurité des mots de passe.



## Fonctionnalités

* Vérification des dépendances (`jq`).
* Analyse automatique des fichiers PAM :

  * `/etc/pam.d/common-password`
  * `/etc/pam.d/system-auth`
  * `/etc/pam.d/password-auth`
* Lecture des paramètres depuis :

  * `/etc/security/pwquality.conf`
  * ou les modules `pam_pwquality` / `pam_cracklib`
* Vérification des critères de sécurité :

  * Longueur minimale (`minlen`)
  * Complexité :

    * majuscules (`ucredit`)
    * minuscules (`lcredit`)
    * chiffres (`dcredit`)
    * caractères spéciaux (`ocredit`)
  * Différence avec anciens mots de passe (`difok`)
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération de recommandations adaptées.
* Mode test interne (`--test`).
* Sortie standardisée en JSON incluant :

  * `status` : OK / WARNING / CRITICAL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : conseil de sécurité



## Structure

check_password/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : politique conforme aux recommandations (tous les critères respectés).
* **Score intermédiaire (2 à 4)** : certains critères ne sont pas respectés.
* **Score 1** : configuration critique ou absence de fichiers PAM.

### États possibles

* **OK** : politique conforme.
* **WARNING** : plusieurs améliorations recommandées.
* **CRITICAL** : problème majeur (ex : fichiers absents).



## Utilisation

```bash
./main.sh --script passwordChecker
```

### Mode test 

```bash
./main.sh --script passwordChecker --test
```



## Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Des améliorations de la politique de mot de passe sont recommandées."
}
```



## Bonnes pratiques

* Utiliser une longueur minimale de mot de passe d’au moins 12 caractères.
* Exiger une combinaison de :

  * majuscules
  * minuscules
  * chiffres
  * caractères spéciaux
* Empêcher la réutilisation des anciens mots de passe (`difok`).
* Vérifier régulièrement la configuration PAM.
* Centraliser les politiques dans `pwquality.conf` pour plus de cohérence.
* Intégrer ce module dans un processus d’audit de sécurité automatisé.


