# tlsChecker

## Description

`tlsChecker` est un module Bash permettant de vérifier la compatibilité du système avec les protocoles TLS modernes.

Il teste la capacité du système à établir une connexion sécurisée en utilisant TLS 1.2 ou supérieur, afin de détecter d’éventuelles configurations obsolètes ou vulnérables.

Le module fournit un score de sécurité ainsi qu’une recommandation pour garantir des communications chiffrées fiables.



## Fonctionnalités

* Vérification du support TLS 1.2+ via une requête HTTPS.
* Test de connexion vers un endpoint sécurisé (ex : Google).
* Détection des bibliothèques TLS/SSL obsolètes.
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
  * `recommendation` : état du support TLS



## Structure

tlsChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : support TLS 1.2+ fonctionnel (connexion sécurisée réussie).
* **Score 2** : échec de connexion TLS 1.2 (configuration obsolète ou incompatible).

### États possibles

* **OK** : test exécuté avec succès.



## Utilisation

```bash id="g7s2kq"
./main.sh --script tlsChecker
```

### Mode test 

```bash id="g7s2kq"
./main.sh --script tlsChecker --test
```



## Exemple de sortie JSON

```json id="6k2dpl"
{
  "status": "OK",
  "error": "",
  "score": 5,
  "recommendation": "Support TLS 1.2+ opérationnel."
}
```



## Bonnes pratiques

* Utiliser uniquement des versions récentes de TLS (1.2 ou 1.3).
* Mettre à jour régulièrement OpenSSL et les bibliothèques système.
* Désactiver les protocoles obsolètes (SSLv3, TLS 1.0, TLS 1.1).
* Vérifier la compatibilité TLS après chaque mise à jour système.
* Intégrer ce module dans un audit de sécurité global.


