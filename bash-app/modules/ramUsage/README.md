# ramUsage

## Description
`ramUsage` est un module Bash permettant de **surveiller l’utilisation de la RAM et du swap** sur un système Linux.
Il collecte les informations mémoire, identifie le processus le plus gourmand et fournit un **score de santé mémoire** ainsi que des recommandations pour maintenir la stabilité du système.

Le module :
- affiche le résultat JSON sur la sortie standard (**stdout**)
- peut être exécuté en mode test pour un retour lisible dans le terminal

## Fonctionnalités
- Collecte des informations mémoire :
  - Total, utilisé, libre et disponible
  - Utilisation du swap
- Identification du **processus consommant le plus de RAM**
- Calcul d’un **score mémoire sur 5 niveaux*- :
  - 5 : utilisation normale (<70 %)
  - 4 : utilisation modérée (70–84 %)
  - 3 : utilisation élevée (85–94 %)
  - 1 : utilisation critique (≥95 %)
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées sur l’utilisation et la gestion de la RAM

## Structure
ramUsage/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module
- `module.json` : métadonnées du module
- `README.md` : documentation du module

## Logique d’évaluation
- **Score 5** : mémoire utilisée <70 %, système stable
- **Score 4** : mémoire 70–84 %, surveiller les applications gourmandes
- **Score 3** : mémoire 85–94 %, risque de ralentissement
- **Score 1** : mémoire ≥95 %, situation critique, fermer les applications inutiles

## Utilisation
```bash
./main.sh --script ramUsage
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Utilisation mémoire : 88% (7.0 GB/8.0 GB).\nSwap utilisé : 500 MB/1.0 GB (50%).\n\nProcessus le plus consommateur de RAM :\n- Nom : firefox\n- PID : 1234\n- Mémoire : 1.5 GB\n\nRecommendation : Mémoire élevée, risque de ralentissement si plusieurs applications gourmandes démarrent."
}
```

## Bonnes pratiques

* Surveillez régulièrement l’utilisation de la RAM et du swap pour anticiper les ralentissements.
* Fermez ou limitez les applications consommant beaucoup de mémoire lorsque le score est critique.
* Configurez des alertes ou scripts automatisés pour détecter les pics d’utilisation.
* Vérifiez le processus le plus gourmand pour identifier les logiciels pouvant être optimisés.
* Pour les serveurs ou systèmes critiques, planifiez les périodes de forte charge et ajustez la mémoire ou le swap si nécessaire.