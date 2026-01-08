# usbChecker

## Description
`usbChecker` est un module Bash destiné à contrôler les équipements USB connectés à un système Linux. Il permet de détecter la présence de périphériques USB inconnus, souvent associés à des risques de sécurité (clé USB piégée, périphérique abandonné, attaque de type BadUSB). Le module fournit une évaluation simple et une recommandation basée sur les bonnes pratiques de sécurité.

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Vérification de la disponibilité de l’outil `lsusb`.
- Inventaire des périphériques USB connectés.
- Détection des équipements USB identifiés comme « Unknown ».
- Calcul d’un score de sécurité de 1 à 5.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandation de sécurité associée au résultat

## Structure
usbChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : Aucun équipement USB inconnu détecté.
- **Score 3** : Présence d’un ou plusieurs équipements USB inconnus.
- **Score 0** : Système non supporté ou outil requis absent.

Le module ne bloque pas les périphériques : il se limite à une détection et à une alerte.

## Utilisation
En ligne de commande :
```bash
./main.sh --script usbChecker
