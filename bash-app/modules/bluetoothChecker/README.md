# bluetoothChecker

## Description
`bluetoothChecker` est un module Bash conçu pour analyser l’état et la sécurité des fonctionnalités Bluetooth sur un système Linux. Il détecte si le Bluetooth est activé, le mode visible (discoverable), les appareils connectés et appairés, la version Bluetooth et le protocole de sécurité utilisé. Il fournit ensuite une évaluation du risque, un score de sécurité et des recommandations détaillées pour sécuriser le Bluetooth conformément aux bonnes pratiques.

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Vérification de la présence des outils nécessaires (`bluetoothctl` et optionnellement `hciconfig`).
- Détection de l’état du Bluetooth (activé ou désactivé).
- Vérification si le mode discoverable est actif.
- Détection des appareils actuellement connectés :
  - Nombre d’appareils
  - Noms des appareils
  - Type de sécurité utilisé (Secure Connection ou Legacy Pairing)
- Comptage des appareils appairés.
- Détection de la version du Bluetooth si `hciconfig` est disponible.
- Calcul d’un score de sécurité sur 5 basé sur :
  - Activation du Bluetooth
  - Mode discoverable
  - Appareils connectés
  - Version du protocole Bluetooth
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur si applicable
  - `score` : note sur 5
  - `recommendation` : recommandations de sécurité détaillées et rapport complet de l’état Bluetooth

## Structure
bluetoothChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation complète du module.

## Logique d’évaluation
- **Score 5** : Bluetooth désactivé ou activé et sécurisé (mode non discoverable, appareils connus, version récente ≥ 5.x).
- **Score 4** : Bluetooth activé avec un ou plusieurs appareils connectés, mais sécurité correcte.
- **Score 3** : Bluetooth activé, mode discoverable ou appareils connectés non sécurisés.
- **Score 2** : Bluetooth activé, mode discoverable et version ancienne (< 5), plusieurs appareils connectés.
- **Score 1** : Bluetooth activé en mode discoverable avec appareils connectés inconnus ou version très ancienne.
- **Score 0** : Système non supporté ou outils nécessaires absents.

## Utilisation
En ligne de commande :
```bash
./main.sh --script bluetoothChecker
```

### Mode test
```bash
./main.sh --script bluetoothChecker --test
```

### Exemple de sortie JSON :
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "- Version Bluetooth ancienne ou inconnue : privilégiez Bluetooth 5.x ou supérieur.\n\nÉtat Bluetooth :\n- Bluetooth activé\n- Mode visible désactivé\n- Appareils connectés : 0\n- Appareils appairés : 5\n- Version Bluetooth : Inconnu\n\nRecommandations supplémentaires :\n- Désactivez Bluetooth si non utilisé.\n- Supprimez les appareils appairés inutilisés.\n- Mettez à jour le système et les périphériques Bluetooth.\n- Privilégiez des équipements récents conformes aux normes (Bluetooth 5.x).\n"
}
```

## Bonnes pratiques
- Désactivez le Bluetooth si vous ne l’utilisez pas.
- Désactivez le mode « discoverable » (visible) lorsqu’aucun appairage n’est nécessaire.
- Supprimez les appareils appairés inutilisés pour limiter les risques de connexion non autorisée.
- Vérifiez régulièrement les appareils connectés et assurez-vous de leur légitimité.
- Maintenez à jour le système et les périphériques Bluetooth pour bénéficier des correctifs de sécurité.
- Privilégiez des équipements récents conformes aux normes Bluetooth 5.x ou supérieures.
- Appliquez les bonnes pratiques générales de sécurité : chiffrement des communications et contrôle des accès.