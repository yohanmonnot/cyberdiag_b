# majChecker

## Description

`majChecker` est un module Bash conçu pour vérifier si tous les logiciels de votre système Linux sont à jour.
Il détecte automatiquement le gestionnaire de paquets présent et calcule un **score sur 5** basé sur le nombre de mises à jour disponibles, suivant une logique inspirée des recommandations ANSSI.

---

## Fonctionnalités

* Détection automatique du système d’exploitation Linux.
* Support des principaux gestionnaires de paquets :

  * `apt` / `apt-get`
  * `dnf`
  * `yum`
  * `pacman`
  * `zypper`
* Vérification de la présence de `sudo` si nécessaire.
* Calcul d’un score de sécurité de 1 à 5 selon le nombre de mises à jour disponibles.
* Retour structuré en **JSON**, incluant :

  * `status` : `OK` ou `FAIL`
  * `error` : message d’erreur le cas échéant
  * `score` : note sur 5
  * `recommendation` : texte court de recommandation
  * `updates` : nombre de mises à jour détectées
* Intégration complète avec le système de logging du projet (`logger.sh`).

---

## Structure

```
majChecker/
├── main.sh
└── module.json
```

* **main.sh** : script principal du module.
* **module.json** : métadonnées du module.

---

## Utilisation

### En ligne de commande

```bash
./main.sh --script majChecker
```

### Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Plusieurs mises à jour en attente.",
  "updates": 7
}
```

* `status` : indique si la vérification s’est correctement déroulée.
* `error` : contient un message si une erreur est survenue.
* `score` : note de sécurité sur 5, plus le score est bas, plus le système est vulnérable.
* `recommendation` : suggestion d’action basée sur le nombre de mises à jour.
* `updates` : nombre de paquets pouvant être mis à jour.

---

## Dépendances

* Bash >= 4
* `jq` pour générer le JSON
* Accès à Internet pour les mises à jour de listes (`apt update`, etc.)

---

## Notes

* Pour `apt`, le module met à jour la liste des paquets (`apt update -qq`) avant de compter les mises à jour.
* Les mises à jour “kept back” sont incluses dans le comptage pour plus de précision.
* Les systèmes autres que Linux ne sont pas pris en charge.
