# encryptionChecker

## Description

`encryptionChecker` est un module Bash permettant de vérifier si les disques d’un système Linux sont chiffrés.

Le module analyse les périphériques de stockage présents sur la machine et détecte s’ils utilisent un chiffrement de type LUKS. Il fournit un score de sécurité ainsi qu’une recommandation selon la présence ou non de disques non chiffrés.



## Fonctionnalités
* Détection des disques présents via `lsblk`.
* Identification des périphériques de type disque (`TYPE=disk`).
* Vérification du chiffrement avec `cryptsetup isLuks`.
* Distinction entre :
* disques chiffrés
* disques non chiffrés
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération d’une recommandation détaillée listant les disques.
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : état du chiffrement des disques



## Structure

encryptionChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : tous les disques sont chiffrés (LUKS).
* **Score 2** : au moins un disque non chiffré détecté.
* **Score 0** : impossible d’analyser les disques (outil manquant ou erreur).

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : erreur critique empêchant l’analyse.



## Utilisation
```bash
./main.sh --script encryptionChecker 
```

### Mode test
```bash
./main.sh --script encryptionChecker --test
```



## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Disques chiffrés :\n/dev/sda\n\nDisques non chiffrés :\n/dev/sdb"
}
```



## Bonnes pratiques
* Activez le chiffrement des disques avec LUKS pour protéger les données sensibles.
* Évitez de laisser des disques non chiffrés sur des systèmes exposés ou mobiles.
* Vérifiez régulièrement l’état du chiffrement après ajout de nouveaux disques.
* Combinez ce module avec des contrôles d’accès et de sécurité physique.
* Assurez-vous de sauvegarder vos clés de chiffrement en lieu sûr.