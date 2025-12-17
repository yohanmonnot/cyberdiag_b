# wifiChecker

## Description
`wifiChecker` est un module Bash conçu pour vérifier la sécurité des connexions sans fil (Wi-Fi, Bluetooth, NFC) sur un système Linux. Il détecte automatiquement les interfaces sans fil activées, vérifie si l'appareil est connecté à un réseau Wi-Fi public ou inconnu, évalue la sécurité du réseau, et fournit des recommandations basées sur les bonnes pratiques de l'ANSSI (Agence Nationale de la Sécurité des Systèmes d'Information).

## Fonctionnalités
- Détection automatique du système d'exploitation Linux.
- Vérification de l'état des interfaces sans fil (Wi-Fi, Bluetooth, NFC).
- Détection des connexions à des réseaux Wi-Fi publics ou inconnus.
- Vérification de la sécurité du réseau Wi-Fi (WEP, WPA, WPA2, WPA3).
- Vérification de la présence d'une connexion VPN active.
- Détection des réseaux Wi-Fi publics à proximité.
- Vérification des connexions automatiques aux réseaux Wi-Fi.
- Calcul d'un score de sécurité de 1 à 5 basé sur les vérifications effectuées.
- Retour structuré en JSON incluant :
  - `exitCode` : OK ou FAIL
  - `error` : message d'erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : suggestion d'action basée sur les vérifications

## Structure
wifiChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : cette documentation


## Utilisation
En ligne de commande :
```bash
./main.sh --script wifiChecker
