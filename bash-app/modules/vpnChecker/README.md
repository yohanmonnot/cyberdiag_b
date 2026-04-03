# vpnChecker

## Description

`vpnChecker` est un module Bash permettant de vérifier la présence d’un VPN ou d’un tunnel réseau actif sur un système Linux.

Il analyse les interfaces réseau pour détecter l’utilisation de tunnels (VPN) et évalue le niveau de sécurité associé à la configuration réseau actuelle.

Le module fournit un score simple ainsi qu’une recommandation afin d’identifier rapidement si le trafic réseau est sécurisé ou potentiellement exposé.



## Fonctionnalités

* Détection automatique des interfaces réseau liées aux VPN :

  * `tun*`
  * `tap*`
  * `wg*` (WireGuard)
  * `ppp*`
* Analyse de la présence d’un tunnel actif.
* Évaluation du niveau de sécurité réseau.
* Calcul d’un score de sécurité sur 5 niveaux.
* Génération d’une recommandation claire.
* Mode test interne (`--test`).
* Intégration avec :

  * système de logs (`logger.sh`)
  * variables d’environnement (`env.sh`)
* Sortie standardisée en JSON incluant :

  * `status` : OK
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé de l’état du VPN



## Structure

vpnChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : au moins une interface VPN/tunnel détectée (connexion sécurisée).
* **Score 3** : aucun VPN détecté (trafic potentiellement exposé).

### États possibles

* **OK** : évaluation réalisée avec succès.



## Utilisation

```bash
./main.sh
```

### Mode test interne

```bash
./main.sh --test
```



## Exemple de sortie JSON

```json
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "VPN/Tunnel actif (Sécurisé)."
}
```



## Bonnes pratiques

* Utiliser un VPN lors de connexions sur des réseaux publics.
* Vérifier régulièrement la présence d’interfaces VPN actives.
* Privilégier des solutions sécurisées comme WireGuard ou OpenVPN.
* Automatiser la vérification pour détecter toute perte de tunnel.
* Compléter avec d’autres modules de sécurité réseau pour un audit complet.


