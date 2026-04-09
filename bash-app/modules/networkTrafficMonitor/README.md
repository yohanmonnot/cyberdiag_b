# networkTrafficMonitor

## Description

`networkTrafficMonitor` est un module Bash permettant de surveiller le volume de trafic réseau entrant sur un système Linux.

Il analyse l’activité réseau sur l’interface principale afin de détecter d’éventuelles anomalies, comme un trafic anormalement élevé pouvant indiquer une activité suspecte (exfiltration de données, attaque, malware).

Le module fournit un score de sécurité ainsi qu’une recommandation pour évaluer le comportement du trafic réseau.



## Fonctionnalités

* Détection automatique de l’interface réseau principale.
* Analyse du trafic entrant via `/proc/net/dev`.
* Mesure du volume de données reçues sur une période donnée.
* Calcul du débit réseau (octets par seconde).
* Détection de trafic anormalement élevé.
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération d’une recommandation adaptée.
* Mode test interne (`--test`).
* Intégration avec :

  * système de logs (`logger.sh`)
  * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

  * `status` : OK
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : analyse du trafic réseau



## Structure

networkTrafficMonitor/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : trafic réseau normal.
* **Score 3** : trafic élevé détecté (> 10 Mo/s).

### États possibles

* **OK** : analyse effectuée avec succès.



## Utilisation

```bash 
./main.sh --script networkTrafficMonitor
```

### Mode test 

```bash 
./main.sh --script networkTrafficMonitor --test
```



## Exemple de sortie JSON

```json 
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Trafic entrant élevé détecté (>10Mo/s). Analyse recommandée."
}
```



## Bonnes pratiques

* Surveiller régulièrement le trafic réseau pour détecter des anomalies.
* Identifier les processus générant un trafic important.
* Mettre en place des outils de monitoring avancés si nécessaire.
* Vérifier les connexions actives en cas de pic de trafic.
* Combiner avec d’autres outils de sécurité réseau (IDS/IPS).
* Intégrer ce module dans un audit de sécurité global.


