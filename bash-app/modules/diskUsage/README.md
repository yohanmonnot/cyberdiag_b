# diskUsage

## Description

**diskUsage** est un module Bash conçu pour surveiller l'utilisation de l'espace disque de votre système Linux.

Il collecte les métriques détaillées de tous les systèmes de fichiers montés et calcule un score sur 5 basé sur le pourcentage d'utilisation moyen.

## Fonctionnalités

- Détection automatique des systèmes de fichiers montés
- Vérification de la disponibilité de la commande `df`
- Collecte de toutes les métriques disque (taille, utilisé, disponible, pourcentage)
- Filtrage automatique des systèmes de fichiers temporaires (tmpfs, devtmpfs, snap)
- Calcul d'un score de performance de 1 à 5 selon l'utilisation moyenne
- Retour structuré en JSON, incluant :
  - `status` : OK ou FAIL
  - `error` : message d'erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : texte de recommandation
  - `disk_data` : tableau contenant les métriques de chaque système de fichiers
  - `average_usage_percentage` : pourcentage d'utilisation moyen
- Intégration complète avec le système de logging du projet (logger.sh)

## Structure

```
diskUsage/
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
./main.sh --script diskUsage
```

### Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Espace disque confortable.",
  "disk_data": [
    {
      "filesystem": "/dev/sda1",
      "size": "100G",
      "used": "30G",
      "available": "70G",
      "use_percentage": 30,
      "mounted_on": "/"
    },
    {
      "filesystem": "/dev/sda2",
      "size": "500G",
      "used": "200G",
      "available": "300G",
      "use_percentage": 40,
      "mounted_on": "/home"
    }
  ],
  "average_usage_percentage": 35
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
- **recommendation** : suggestion d'action basée sur l'utilisation disque
- **disk_data** : tableau contenant les détails de chaque partition/disque
- **average_usage_percentage** : moyenne d'utilisation de tous les disques

## Dépendances

- Bash >= 4
- `df` pour collecter les données disque
- `jq` pour générer le JSON

## Notes

- Le module utilise `df -h` pour obtenir les valeurs en format humain (K, M, G)
- Les systèmes de fichiers temporaires (tmpfs, devtmpfs) sont automatiquement exclus
- Les partitions snap sont également exclues pour éviter le bruit
- Le score est basé sur l'utilisation moyenne de tous les disques analysés
- Les systèmes autres que Linux ne sont pas pris en charge

## Filtres appliqués

Le module exclut automatiquement :
- `tmpfs` : systèmes de fichiers temporaires en RAM
- `devtmpfs` : systèmes de fichiers de périphériques
- Partitions `/snap/*` : packages snap montés
