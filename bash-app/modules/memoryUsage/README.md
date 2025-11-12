# memoryUsage

## Description

**memoryUsage** est un module Bash conçu pour surveiller l'utilisation de la mémoire RAM et du swap de votre système Linux.

Il collecte les métriques détaillées de la mémoire (totale, utilisée, disponible, buffers/cache, etc.) et calcule un score sur 5 basé sur le pourcentage d'utilisation de la RAM.

## Fonctionnalités

- Détection automatique du système Linux
- Vérification de la disponibilité de la commande `free`
- Collecte de toutes les métriques mémoire (RAM et swap)
- Calcul d'un score de performance de 1 à 5 selon l'utilisation mémoire
- Retour structuré en JSON, incluant :
  - `status` : OK ou FAIL
  - `error` : message d'erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : texte de recommandation
  - `memory_data` : objet contenant toutes les métriques RAM
  - `swap_data` : objet contenant toutes les métriques swap
- Intégration complète avec le système de logging du projet (logger.sh)

## Structure

```
memoryUsage/
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
./main.sh --script memoryUsage
```

### Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Utilisation mémoire faible, système optimal.",
  "memory_data": {
    "total_mb": 16384,
    "used_mb": 4096,
    "free_mb": 8192,
    "shared_mb": 256,
    "buff_cache_mb": 4096,
    "available_mb": 12288,
    "used_percentage": 25
  },
  "swap_data": {
    "total_mb": 2048,
    "used_mb": 0,
    "free_mb": 2048
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
- **recommendation** : suggestion d'action basée sur l'utilisation mémoire
- **memory_data** : objet contenant les métriques détaillées de la RAM (en MB)
- **swap_data** : objet contenant les métriques détaillées du swap (en MB)

## Dépendances

- Bash >= 4
- `free` pour collecter les données mémoire
- `jq` pour générer le JSON

## Notes

- Le module utilise `free -m` pour obtenir les valeurs en mégaoctets (MB)
- Le pourcentage d'utilisation est calculé comme : `(used / total) * 100`
- Les valeurs incluent la mémoire physique (RAM) et la mémoire d'échange (swap)
- Si le swap n'est pas configuré, les valeurs seront à 0
- Les systèmes autres que Linux ne sont pas pris en charge
