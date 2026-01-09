# Privileges Checker

## Description

`privilegesChecker` est un script Bash permettant de **vérifier plusieurs points
liés aux privilèges système sensibles** sur un système Linux.

Il analyse la configuration des accès privilégiés et génère un **rapport au format JSON**,
destiné à être utilisé dans le cadre :

- d’audits de sécurité
- de pipelines CI/CD
- d’outils de supervision ou de diagnostic automatisé

Le script :
- affiche le résultat JSON sur la sortie standard (**stdout**)
- génère également un fichier `module.json`

---

## Vérifications effectuées

Le module réalise les contrôles suivants :

- Vérification de l’exécution du script avec les privilèges **root**
- Vérification de la présence de la commande **sudo**
- Détection des utilisateurs disposant d’un **UID égal à 0**
- Vérification de la **lisibilité du fichier `/etc/sudoers`**

---

## Résultat du script

Le script renvoie un **objet JSON unique** contenant les champs suivants :

```json
{
  "status": "OK" | "WARNING" | "CRITICAL",
  "error": "message d’erreur ou vide",
  "score": 0 à 5,
  "recommendation": "texte de recommandation"
}
