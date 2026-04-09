# networkConfigChecker

## Description

`networkConfigChecker` est un module Bash permettant de vérifier la cohérence de la configuration réseau sur un système Linux.

Il contrôle la présence d’une adresse IP locale valide, d’une passerelle par défaut (gateway) et d’un ou plusieurs serveurs DNS. Il détecte également les adresses auto-configurées APIPA (169.254.x.x), indicatrices d’un DHCP non fonctionnel.

Le module fournit un score de sécurité ainsi qu’une recommandation sur l’état global de la configuration réseau.



## Fonctionnalités

* Détection des interfaces réseau avec adresse IP.
* Vérification de la présence d’une passerelle par défaut.
* Vérification de la configuration DNS (`/etc/resolv.conf`).
* Détection des adresses APIPA (169.254.x.x).
* Calcul d’un score de configuration réseau sur 5 niveaux.
* Génération d’une recommandation détaillée.
* Mode test interne (`--test`) pour simuler différents scénarios.
* Intégration avec :

  * système de logs (`logger.sh`)
  * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

  * `status` : OK
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé de la configuration réseau



## Structure

networkConfigChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : configuration réseau normale (IP, gateway et DNS valides).
* **Score 1** : APIPA détectée (DHCP non fonctionnel).
* **Score 3-4** : éléments manquants (gateway ou DNS absent).
* **Score 0** : aucune interface réseau active.

### États possibles

* **OK** : configuration réseau évaluée.
* **FAIL** : conditions critiques détectées.



## Utilisation

```bash 
./main.sh --script networkConfigChecker
```

### Mode test 

```bash 
./main.sh --script networkConfigChecker --test
```



## Exemple de sortie JSON

```json 
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "Configuration réseau locale valide."
}
```



## Bonnes pratiques

* Vérifier que toutes les interfaces réseau attendues ont une IP valide.
* S’assurer qu’une passerelle par défaut est définie pour l’accès externe.
* Configurer correctement les serveurs DNS pour éviter des interruptions de résolution.
* Surveiller l’apparition d’adresses APIPA comme indicateur de problèmes DHCP.
* Intégrer ce module dans un audit de sécurité réseau complet.
* Exécuter régulièrement pour détecter les modifications ou erreurs de configuration.


