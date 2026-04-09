# secureBootChecker

## Description

`secureBootChecker` est un module Bash permettant de vérifier si le Secure Boot est activé sur un système Linux.

Le module analyse les variables EFI du système pour déterminer l’état du Secure Boot, calcule un score de sécurité et fournit une recommandation en fonction de son activation.



## Fonctionnalités
* Détection de la présence de l’environnement EFI.
* Lecture du statut Secure Boot via `/sys/firmware/efi/efivars`.
* Identification de l’état :
  * Activé
  * Désactivé
  * Non détecté
* Calcul d’un score sur 5 niveaux selon l’état du Secure Boot.
* Génération d’une recommandation claire.
* Mode test interne possible (adaptable).
* Sortie standardisée en JSON incluant :
  * status : OK ou FAIL
  * error : message d’erreur éventuel
  * score : note sur 5
  * recommendation : résumé de l’état du Secure Boot



## Structure

secureBootChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : Secure Boot activé.
* **Score 2** : Secure Boot désactivé ou non détecté.
* **Score 0** : erreur lors de la lecture des variables EFI.

## États possibles
* **OK** : vérification réalisée avec succès.
* **FAIL** : accès aux variables EFI impossible.



## Utilisation
```bash
./main.sh --script secureBootChecker 
```

### Mode test
```bash
./main.sh --script secureBootChecker --test
```


## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "Secure Boot : Activé"
}
```



## Bonnes pratiques
* Activez le Secure Boot pour renforcer la sécurité au démarrage.
* Vérifiez sa configuration après toute modification BIOS/UEFI.
* Utilisez ce module dans un audit global de sécurité système.
* Combinez avec des contrôles d’intégrité système pour une protection renforcée contre les malwares au boot.