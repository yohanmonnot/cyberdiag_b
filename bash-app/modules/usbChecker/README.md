# usbChecker

## Description
`usbChecker` est un module Bash permettant de **surveiller les périphériques USB connectés** sur un système Linux.
Il détecte les périphériques physiques branchés, identifie les risques potentiels liés aux périphériques de stockage ou inconnus, et fournit un **score de sécurité USB** ainsi que des recommandations.

Le module :
- affiche le résultat JSON sur la sortie standard (**stdout**)
- peut identifier : périphériques de stockage, smartphones, périphériques inconnus et périphériques d’entrée (clavier, souris)

## Fonctionnalités
- Détection automatique des périphériques USB connectés avec `lsusb`.
- Identification des types de périphériques :
  - Stockage USB (clé, disque, etc.)
  - Smartphones et tablettes
  - Périphériques inconnus
  - Périphériques d’entrée connus (clavier, souris)
- Calcul d’un **score de risque USB sur 5 niveaux** :
  - 5 : aucun périphérique externe ou uniquement périphériques d’entrée connus
  - 4 : appareil mobile connecté
  - 3 : périphérique de stockage USB connecté
  - 1 : périphérique inconnu détecté
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées pour la gestion des périphériques USB

## Structure
usbChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module
- `module.json` : métadonnées du module
- `README.md` : documentation du module

## Logique d’évaluation
- **Score 5** : aucun périphérique externe ou uniquement périphériques d’entrée connus → système sécurisé
- **Score 4** : appareil mobile détecté → vérifier le mode de connexion (charge uniquement recommandé)
- **Score 3** : périphérique de stockage détecté → risque d’infection ou d’exfiltration
- **Score 1** : périphérique inconnu détecté → risque critique

## Utilisation

```bash
./main.sh --script usbChecker
```

### Mode test
```bash
./main.sh --script usbChecker --test
```

### Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Périphérique de stockage USB détecté. Risque d'infection ou d'exfiltration.\n\nDétails :\n- SanDisk Ultra (Vendor ID: 0781)\n\nRecommandations supplémentaires :\n- Ne connectez jamais de clé USB inconnue.\n- Désactivez l'exécution automatique.\n- Utilisez un antivirus pour scanner tout stockage externe.\n- Sur poste sensible, limitez l'accès aux ports USB."
}
```

## Bonnes pratiques
- Ne connectez jamais de périphériques USB inconnus ou non sécurisés.
- Désactivez l’exécution automatique pour tous les périphériques externes.
- Analysez tout périphérique de stockage avec un antivirus avant utilisation.
- Sur les postes sensibles, limitez l’accès physique aux ports USB.
- Favorisez les périphériques connus et fiables (clavier, souris, écran, stockage sécurisé).