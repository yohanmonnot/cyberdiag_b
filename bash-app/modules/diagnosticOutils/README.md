# diagnosticOutils

## Description
`diagnosticOutils` est un module Bash de profil diagnostique qui regroupe des modules utilitaires et peripheriques.

Le module lit `diag.json` et renvoie le profil en JSON compact.

## Fonctionnalites
- Profil utilitaire simple et lisible.
- Validation de la presence de `diag.json`.
- Sortie JSON compacte pour UI/API.

## Structure
diagnosticOutils/
├── main.sh
├── module.json
├── diag.json
└── README.md

## Modules inclus
- usbChecker
- bluetoothChecker
- logAnalyzer
- quizExample

## Utilisation
```bash
sudo ./main.sh --script diagnosticOutils
```

### Exemple de sortie JSON
```json
{"categorie 1":["usbChecker","bluetoothChecker","logAnalyzer","quizExample"]}
```

## Bonnes pratiques
- Garder ce profil leger pour tests rapides d'outillage.
- Deplacer les modules critiques vers les profils reseau/securite.
