# cronChecker

## Description

`cronChecker` est un module Bash permettant de détecter des tâches planifiées potentiellement suspectes sur un système Linux.

Le module analyse les fichiers de configuration cron système afin d’identifier des tâches inhabituelles ou non standard. Il fournit un score de sécurité ainsi qu’une recommandation basée sur la présence de tâches suspectes.



## Fonctionnalités
* Analyse des fichiers de planification :
  * `/etc/crontab`
  * `/etc/cron.d/*`
* Filtrage des commentaires et lignes vides.
* Exclusion des tâches connues et légitimes (ex : `logrotate`, `anacron`).
* Détection de tâches potentiellement suspectes ou non identifiées.
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération d’une recommandation détaillée listant les tâches détectées.
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé des tâches suspectes



## Structure

cronChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : aucune tâche suspecte détectée.
* **Score 2** : présence de tâches planifiées suspectes.
* **Score 0** : impossible d’analyser les fichiers cron.

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : erreur critique empêchant l’analyse.



## Utilisation
```bash
./main.sh --script cronChecker 
```

### Mode test
```bash
./main.sh --script cronChecker --test
```



## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Tâches planifiées suspectes :\n* * * * * root /tmp/script.sh"
}
```


## Bonnes pratiques
* Vérifiez régulièrement les tâches cron pour détecter toute activité inhabituelle.
* Supprimez les scripts inconnus ou non documentés.
* Restreignez les permissions des fichiers cron.
* Évitez l’exécution de scripts depuis des répertoires temporaires (`/tmp`).
* Combinez ce module avec une analyse des processus et des logs pour une meilleure détection d’intrusion.