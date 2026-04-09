# rogueDhcpChecker

## Description

`rogueDhcpChecker` est un module Bash permettant de détecter la présence de serveurs DHCP multiples sur un réseau, afin d’identifier d’éventuels **Rogue DHCP**.

Il analyse le réseau via un scan DHCP broadcast et évalue les risques de sécurité liés à la présence de serveurs DHCP non autorisés, pouvant entraîner des attaques de type Man-in-the-Middle.

Le module fournit un score de sécurité ainsi que des recommandations pour sécuriser l’infrastructure réseau.



## Fonctionnalités

* Vérification des dépendances système :

  * `nmap`
  * `ip`
* Détection automatique de l’interface réseau par défaut.
* Scan DHCP via `nmap` (broadcast DHCP discover).
* Comptage du nombre de serveurs DHCP détectés.
* Détection des situations à risque :

  * aucun serveur DHCP
  * plusieurs serveurs DHCP (Rogue DHCP)
* Gestion des droits utilisateur (scan limité sans root).
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération de recommandations détaillées.
* Mode test complet (`--test`) incluant :

  * tests unitaires
  * test d’intégration
  * vérification de couverture logique
* Intégration avec :

  * système de logs (`logger.sh`)
  * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

  * `status` : OK / FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : analyse et actions recommandées



## Structure

rogueDhcpChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : un seul serveur DHCP détecté (comportement normal).
* **Score 3** : scan limité (droits insuffisants).
* **Score 2** : aucun serveur DHCP détecté.
* **Score 1** : plusieurs serveurs DHCP détectés (risque critique).

### États possibles

* **OK** : analyse réalisée.
* **FAIL** : erreur critique (ex : dépendance manquante ou interface introuvable).



## Utilisation

```bash 
./main.sh --script rogueDhcpChecker
```

### Mode test 

```bash 
./main.sh --script rogueDhcpChecker --test
```



## Exemple de sortie JSON

```json 
{
  "status": "OK",
  "error": "",
  "score": 1,
  "recommendation": "Alerte : 2 serveurs DHCP détectés.\n- Risque de Rogue DHCP\n- Risque de Man-in-the-Middle\n\nActions recommandées :\n- Vérifier les équipements réseau\n- Désactiver les DHCP non autorisés\n- Segmenter le réseau (VLAN)\n- Activer DHCP Snooping (switch)"
}
```



## Bonnes pratiques

* Maintenir un seul serveur DHCP actif par segment réseau.
* Surveiller régulièrement le réseau pour détecter les équipements non autorisés.
* Activer des mécanismes de sécurité comme le **DHCP Snooping** sur les switchs.
* Segmenter le réseau avec des VLANs pour limiter les risques.
* Exécuter le module avec les droits root pour une détection complète.
* Intégrer ce contrôle dans un audit de sécurité réseau global.


