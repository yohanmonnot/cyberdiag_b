# firewallChecker

## Description
`firewallChecker` est un module Bash conçu pour vérifier la présence et la configuration d’un pare-feu sur un système Linux.
Il détecte les principaux pare-feu disponibles (UFW, iptables, nftables, firewalld), analyse leur état et leur configuration, calcule un score de sécurité et fournit des recommandations pour renforcer la protection réseau.

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Détection des pare-feu installés :
  - UFW
  - iptables
  - nftables
  - firewalld
- Analyse détaillée :
  - État du service (actif ou non)
  - Règle par défaut (deny/drop)
  - Nombre de ports entrants ouverts
  - Liste des zones et services pour firewalld
- Calcul d’un score de sécurité sur 5 niveaux :
  - 5 : pare-feu actif et règles sécurisées
  - 4 : pare-feu actif mais quelques ports ouverts
  - 3 : configuration partiellement sécurisée
  - 2 : pare-feu installé mais non actif ou règles par défaut non sécurisées
  - 1 : aucun pare-feu détecté
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées et état du pare-feu

## Structure

firewallChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : pare-feu actif, règles par défaut sécurisées, peu ou pas de ports ouverts.
- **Score 4** : pare-feu actif, règles par défaut correctes, quelques ports ouverts.
- **Score 3** : configuration partiellement sécurisée (règles par défaut incomplètes ou trop de ports ouverts).
- **Score 2** : pare-feu installé mais inactif ou règles par défaut non sécurisées.
- **Score 1** : aucun pare-feu détecté.

## Utilisation
```bash
./main.sh --script firewallChecker
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Pare-feu UFW détecté.\nStatus: active\nDefault: deny (incoming)\n2 ports entrants ouverts.\n\nDétails :\n[UFW status complet]\n\nRecommandations supplémentaires :\n- Activez le pare-feu si nécessaire.\n- Configurez les règles par défaut pour bloquer les entrées non désirées.\n- Fermez les ports inutilisés."
}
```

## Bonnes pratiques
- Toujours activer un pare-feu sur les systèmes exposés.
- Configurez la politique par défaut pour bloquer toutes les connexions entrantes non nécessaires (deny/drop).
- Limitez le nombre de ports ouverts et fermez ceux inutilisés.
- Surveillez régulièrement les règles et les services associés.
- Documentez les exceptions et les zones de confiance pour éviter les failles de configuration.
