# cpuUsage

## Description

**cpuUsage** est un module Bash conçu pour surveiller l'utilisation du processeur (CPU) de votre système Linux.

Il collecte les différentes métriques CPU (user, system, nice, idle, etc.) et calcule un score sur 5 basé sur le pourcentage d'utilisation global du processeur.

## Fonctionnalités

- Détection automatique du système Linux
- Vérification de la disponibilité de la commande `top`
- Collecte de toutes les métriques CPU détaillées
- Calcul d'un score de performance de 1 à 5 selon l'utilisation CPU
- Retour structuré en JSON, incluant :
  - `status` : OK ou FAIL
  - `error` : message d'erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : texte de recommandation
  - `cpu_data` : objet contenant toutes les métriques CPU
- Intégration complète avec le système de logging du projet (logger.sh)

## Structure

```
cpuUsage/
├── main.sh
├── module.json
└── README.md
```

- `main.sh` : script principal du module
- `module.json` : métadonnées du module
- `README.md` : cette documentation

## Utilisation

### En ligne de commande

```bash
./main.sh --script cpuUsage
```

### Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Utilisation CPU faible, système peu sollicité.",
  "cpu_data": {
    "user": "5.2",
    "system": "2.1",
    "nice": "0.0",
    "idle": "92.0",
    "wait": "0.5",
    "hardware_interrupts": "0.0",
    "software_interrupts": "0.2",
    "stolen": "0.0",
    "used_percentage": 8
  }
}
```

### Description des champs

- **status** : indique si la vérification s'est correctement déroulée
- **error** : contient un message si une erreur est survenue
- **score** : note de performance sur 5
  - 5 : Utilisation très faible (<20%)
  - 4 : Utilisation faible (20-40%)
  - 3 : Utilisation modérée (40-60%)
  - 2 : Utilisation élevée (60-80%)
  - 1 : Utilisation critique (>80%)
- **recommendation** : suggestion d'action basée sur l'utilisation CPU
- **cpu_data** : objet contenant les métriques détaillées du CPU

## Dépendances

- Bash >= 4
- `top` pour collecter les données CPU
- `jq` pour générer le JSON
- `bc` pour les calculs arithmétiques

## Notes

- Le module utilise `top -bn1` pour obtenir un snapshot instantané de l'utilisation CPU
- Le pourcentage d'utilisation est calculé comme : `100 - idle`
- Toutes les valeurs sont récupérées depuis la ligne "Cpu(s)" de la sortie de `top`
- Les systèmes autres que Linux ne sont pas pris en charge
