# diskUsage

## Description
`diskUsage` est un module Bash permettant de surveiller l’utilisation des partitions locales sur un système Linux.
Il collecte les informations des systèmes de fichiers, calcule l’usage en pourcentage et identifie les partitions critiques. Le module fournit un score de santé du stockage et des recommandations détaillées pour la maintenance.

## Fonctionnalités
- Détection automatique des partitions locales exploitables pour l’utilisateur (ext4, xfs, btrfs, ntfs, vfat).
- Collecte des informations :
  - Nom du système de fichiers (`filesystem`)
  - Point de montage (`mounted_on`)
  - Pourcentage d’utilisation (`use_percentage`)
- Calcul du score de santé globale du stockage sur 5 niveaux :
  - 5 : utilisation faible (<70 %)
  - 4 : utilisation modérée (70–79 %)
  - 3 : utilisation élevée (80–89 %)
  - 2 : utilisation critique (90–94 %)
  - 1 : situation critique (≥95 %)
- Identification de la partition la plus saturée.
- Recommandations spécifiques pour chaque niveau d’usage.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations détaillées sur l’utilisation et l’entretien des partitions

## Structure
diskUsage/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : utilisation maximale < 70 % → aucune action nécessaire.
- **Score 4** : utilisation 70–79 % → surveiller l’évolution et identifier les dossiers volumineux.
- **Score 3** : utilisation 80–89 % → nettoyage recommandé des fichiers temporaires et journaux.
- **Score 2** : utilisation 90–94 % → nettoyage urgent et suppression de fichiers inutiles.
- **Score 1** : utilisation ≥ 95 % → situation critique, libérer immédiatement de l’espace.

## Utilisation
```bash
./main.sh --script diskUsage
```


### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Utilisation des partitions locales :\n- / (50%)\n- /home (92%)\n\nPartition la plus critique : /home (92%).\n\nAction recommandée :\nNettoyage urgent requis. Supprimer fichiers volumineux et archives inutiles."
}
```

## Bonnes pratiques
- Vérifiez régulièrement l’espace disque pour anticiper les saturations.
- Supprimez ou archivez les fichiers volumineux et temporaires.
- Surveillez `/var/log` et `/home` pour les fichiers ou journaux générant une croissance rapide.
- Configurez des alertes ou scripts automatiques pour détecter les montées rapides de l’usage disque.
- Évitez d’utiliser la racine (`/`) comme stockage temporaire ou personnel.