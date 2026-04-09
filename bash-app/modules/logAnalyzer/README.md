# logAnalyzer

## Description
`logAnalyzer` est un module Bash destiné à analyser rapidement les erreurs récentes dans les journaux système (`auth.log` et `syslog`).

Le module recherche des motifs d’échec courants (`failed`, `error`, `invalid`, `fail`), calcule un score de risque et fournit une recommandation structurée en JSON.

## Fonctionnalités
- Analyse des 20 dernières erreurs dans `/var/log/auth.log`.
- Analyse des 20 dernières erreurs dans `/var/log/syslog`.
- Calcul d’un score de sécurité simple :
  - `5` si aucune erreur détectée
  - `3` si des erreurs sont détectées
- Génération d’une sortie JSON normalisée avec :
  - `status`
  - `error`
  - `score`
  - `recommendation`

## Structure
logAnalyzer/
├── main.sh        # Script principal du module
├── module.json    # Métadonnées du module
└── README.md      # Documentation complète

## Logique d’évaluation

| Score | Condition | Interprétation |
|-------|-----------|----------------|
| 5     | Aucune erreur trouvée dans `auth.log` et `syslog` | Système stable, pas d'alerte immédiate côté logs analysés |
| 3     | Erreurs détectées dans `auth.log` ou `syslog` | Activité à vérifier, audit complémentaire recommandé |

## Utilisation
Exécution en ligne de commande :
```bash
./main.sh --script logAnalyzer
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Dernières erreurs auth :\nFailed password for invalid user ...\n\nDernières erreurs syslog :\nkernel: error ..."
}
```

## Bonnes pratiques
- Surveiller régulièrement les erreurs d’authentification répétées.
- Corréler les erreurs logs avec les heures d’activité suspecte.
- Compléter ce module avec des analyses réseau et processus.

## Mode test (`--test`)
Le module inclut un mode de tests automatiques :
```bash
./main.sh --script logAnalyzer --test
```

### Phases de test
Le mode `--test` exécute :
1. Tests unitaires
   - Cas sans erreur
   - Cas avec erreurs `auth.log`
   - Cas avec erreurs `syslog`
   - Cas combiné
2. Test d’intégration
   - Exécution réelle de la collecte
   - Validation du JSON généré
3. Vérification de couverture logique
   - Parcours des scénarios critiques de scoring

### Garantie apportée
Ce mode assure la cohérence du score, la validité du JSON et la robustesse globale du module face aux cas usuels de logs.

