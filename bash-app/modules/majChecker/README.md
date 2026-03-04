# majChecker

## Description
`majChecker` est un module Bash permettant de vérifier si le système Linux est à jour.
Il détecte le gestionnaire de paquets du système (apt, dnf, yum, pacman, zypper), identifie les mises à jour disponibles et fournit un score de sécurité ainsi que des recommandations pour maintenir le système à jour et sécurisé.

## Fonctionnalités
- Détection automatique du système d’exploitation et du gestionnaire de paquets.
- Vérification des dépendances nécessaires (`sudo` si requis).
- Détection du nombre de mises à jour disponibles selon le gestionnaire :
  - apt
  - dnf
  - yum
  - pacman
  - zypper
- Calcul d’un score de mise à jour sur 5 niveaux :
  - 5 : système à jour
  - 4 : quelques mises à jour mineures disponibles
  - 3 : plusieurs mises à jour disponibles
  - 2 : nombreuses mises à jour critiques en attente
  - 1 : système potentiellement vulnérable
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées pour mettre à jour le système

## Structure
majChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : système à jour → aucune action nécessaire.
- **Score 4** : quelques mises à jour mineures → appliquer les mises à jour pour améliorer corrections et fonctionnalités.
- **Score 3** : plusieurs mises à jour → appliquer rapidement pour maintenir sécurité et stabilité.
- **Score 2** : nombreuses mises à jour → système potentiellement vulnérable, mise à jour fortement recommandée.
- **Score 1** : grand nombre de mises à jour critiques → système potentiellement dangereux, mise à jour immédiate obligatoire.

## Utilisation
```bash
./main.sh --script majChecker
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Plusieurs mises à jour sont en attente. Appliquez-les afin de maintenir la sécurité et la stabilité du système.\nNombre total de mises à jour disponibles : 12"
}
```

## Bonnes pratiques
- Vérifiez régulièrement les mises à jour de votre système pour rester protégé contre les vulnérabilités.
- Appliquez systématiquement les mises à jour de sécurité dès qu’elles sont disponibles.
- Préférez planifier les mises à jour lors de périodes de faible activité pour éviter toute interruption.
- Pour les systèmes critiques, utilisez des outils d’automatisation pour gérer les mises à jour et générer des rapports réguliers.
- Ne négligez pas les mises à jour de paquets tiers ou des dépôts additionnels.