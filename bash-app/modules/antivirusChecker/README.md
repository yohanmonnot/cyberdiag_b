# antivirusChecker

## Description
`antivirusChecker` est un module Bash destiné à vérifier la présence et l’état de fonctionnement d’un antivirus sur un système Linux. Il détecte si un antivirus est installé (actuellement ClamAV), vérifie la disponibilité des outils associés et l’état de mise à jour des bases virales, puis fournit une évaluation simple accompagnée de recommandations alignées avec les bonnes pratiques de sécurité (notamment ANSSI).

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Vérification de la présence d’un gestionnaire de paquets supporté (apt, dnf, yum, pacman, zypper).
- Détection de la présence d’un antivirus (ClamAV).
- Vérification de la disponibilité de l’outil de mise à jour des signatures virales (`freshclam`).
- Évaluation de l’état de mise à jour des bases virales.
- Calcul d’un score de sécurité de 1 à 5.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandation de sécurité associée au résultat

## Structure
antivirusChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : Antivirus installé et bases virales à jour.
- **Score 3** : Antivirus installé mais impossible de vérifier l’état des mises à jour.
- **Score 2** : Antivirus installé mais bases virales obsolètes.
- **Score 1** : Aucun antivirus détecté.
- **Score 0** : Système non supporté ou environnement insuffisant.

## Utilisation
En ligne de commande :
```bash
./main.sh --script antivirusChecker
