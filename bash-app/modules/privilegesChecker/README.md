# Privileges Checker

## Description

`privilegesChecker` est un script Bash permettant de vérifier plusieurs points
liés aux privilèges système sensibles sur un système Linux.
Il analyse la configuration et génère un rapport **au format JSON** utilisable
pour des audits de sécurité, de la CI/CD ou des outils de supervision.

Le script :
- affiche le résultat JSON sur la sortie standard (stdout)
- génère également un fichier `privilegesChecker.json`

---

## Vérifications effectuées

- Exécution du script avec les privilèges root
- Présence de la commande `sudo`
- Détection des utilisateurs avec un UID égal à `0`
- Lisibilité du fichier `/etc/sudoers`

---

## Fichiers

- main.sh # Script principal (privileges checker)
- test_privilegesChecker.sh # Test automatique du module
- result.json # Fichier JSON généré (à l’exécution)
- README.md