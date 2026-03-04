# wifiChecker

## Description
`wifiChecker` est un module Bash permettant de **surveiller les connexions Wi-Fi** sur un système Linux.
Il analyse le réseau sans fil auquel l’ordinateur est connecté, identifie si le réseau est public ou sécurisé, et si un VPN est actif, puis fournit un **score de sécurité Wi-Fi** et des recommandations.

Le module :
- affiche le résultat JSON sur la sortie standard (**stdout**)
- détecte : réseau public ou sécurisé, présence d’un VPN

## Fonctionnalités
- Détection automatique de la connexion Wi-Fi active avec `nmcli`.
- Vérification de la sécurité du réseau :
  - Réseau ouvert ou WEP (réseau public)
  - WPA/WPA2/WPA3 (réseau sécurisé)
- Détection de l’état VPN pour sécuriser les communications.
- Calcul d’un **score de sécurité Wi-Fi sur 5 niveaux** :
  - 5 : réseau sécurisé ou aucun réseau
  - 3 : réseau public avec VPN actif
  - 1 : réseau public sans VPN
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées pour la sécurité du réseau

## Structure
wifiChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module
- `module.json` : métadonnées du module
- `README.md` : documentation du module

## Logique d’évaluation
- **Score 5** : aucun réseau ou réseau sécurisé → système sûr
- **Score 3** : réseau public avec VPN actif → communication chiffrée mais vigilance nécessaire
- **Score 1** : réseau public sans VPN → risque critique pour les opérations sensibles

## Utilisation
```bash
./main.sh --script wifiChecker
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 1,
  "recommendation": "Connecté à un réseau public sans VPN.\n\nÉvitez toute opération sensible (banque, mots de passe, fichiers confidentiels).\nUtilisez un VPN immédiatement pour sécuriser vos communications.\n\nDétails de la connexion :\n- SSID : FreeWifi\n- Sécurité : open\n- VPN actif : false"
}
```

## Bonnes pratiques
- Évitez de vous connecter à des réseaux Wi-Fi publics sans VPN.
- Utilisez un VPN pour toutes vos connexions sur des réseaux non sécurisés.
- Préférez les réseaux WPA2/WPA3 pour les opérations sensibles.
- Désactivez le partage automatique de fichiers sur les réseaux publics.
- Surveillez régulièrement les connexions actives et la présence d’un VPN pour protéger vos données.