# cpuUsage

## Description
`cpuUsage` est un module Bash destiné à surveiller l’utilisation du processeur sur un système Linux. Il calcule la moyenne d’utilisation du CPU sur une période définie, identifie le processus le plus gourmand en ressources et fournit un score de performance accompagné de recommandations claires.  

Le module génère un retour JSON structuré, adapté pour une intégration dans des outils de diagnostic ou de supervision.

## Fonctionnalités
- Collecte de l’utilisation moyenne du CPU sur une période configurable (`SAMPLE_DURATION`).
- Identification du processus le plus consommateur de CPU (nom, PID, pourcentage CPU).
- Calcul d’un score de performance de 1 à 5 basé sur le pourcentage d’utilisation.
- Génération de recommandations détaillées sur la charge CPU et les processus dominants.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur si applicable
  - `score` : note sur 5
  - `recommendation` : informations détaillées sur l’usage CPU et processus dominants

## Structure
cpuUsage/
├── main.sh        # Script principal du module
├── module.json    # Métadonnées du module
└── README.md      # Documentation complète

## Logique d’évaluation
| Score | Utilisation CPU moyenne | Interprétation et recommandations |
|-------|------------------------|---------------------------------|
| 5     | < 20%                  | Charge CPU faible, système fluide. |
| 4     | 20% - 39%              | Charge modérée, aucune action immédiate nécessaire. |
| 3     | 40% - 59%              | Charge moyenne, surveillez les processus gourmands. |
| 2     | 60% - 79%              | Charge élevée, identifier les processus intensifs et optimiser si nécessaire. |
| 1     | ≥ 80%                  | Charge critique, risques de ralentissements. Analyse et actions urgentes recommandées. |

## Utilisation
Exécution en ligne de commande :
```bash
./main.sh --script cpuUsage
```

### Exemple de sortie JSON :
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Moyenne CPU sur 5s : 47%.\n\nProcessus dominant (moyenne sur 5s) :\n- Nom : firefox\n- PID : 1234\n- CPU : 28%"
}
```

## Bonnes pratiques
- Surveillez régulièrement la charge CPU pour détecter les anomalies ou processus suspects.
- Identifiez les processus qui consomment le plus de CPU et analysez leur légitimité.
- Pour les systèmes critiques, automatisez la collecte et l’alerte via ce module intégré dans un outil de supervision.
- Ajustez la durée d’échantillonnage (SAMPLE_DURATION) selon la précision et la réactivité souhaitées.