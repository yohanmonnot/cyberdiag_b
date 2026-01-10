# firewallChecker

## Description
`firewallChecker` est un module Bash chargé de vérifier la présence, l’activation et le niveau de configuration du pare-feu sur un système Linux. Il s’appuie sur les outils standards du système (UFW ou iptables) pour déterminer si les connexions réseau entrantes sont correctement filtrées et fournit une évaluation accompagnée de recommandations conformes aux bonnes pratiques de sécurité (ANSSI).

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Vérification de la disponibilité des outils de pare-feu (`ufw` ou `iptables`).
- Détection de la présence d’un pare-feu.
- Vérification de l’activation du pare-feu.
- Analyse basique de la configuration du pare-feu :
  - UFW : règles par défaut sur les connexions entrantes/sortantes.
  - iptables : politique par défaut de type DROP.
- Calcul d’un score de sécurité de 1 à 5.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandation de sécurité associée au résultat

## Structure
firewallChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : Pare-feu actif et correctement configuré (UFW ou iptables).
- **Score 3** : Pare-feu détecté et actif, mais configuration insuffisante ou permissive.
- **Score 2** : Pare-feu détecté mais non activé.
- **Score 1** : Aucun pare-feu détecté.
- **Score 0** : Système non supporté ou outils requis absents.

## Utilisation
En ligne de commande :
```bash
./main.sh --script firewallChecker
