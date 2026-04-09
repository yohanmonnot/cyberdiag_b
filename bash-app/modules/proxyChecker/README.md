# proxyChecker

## Description

`proxyChecker` est un module Bash permettant de détecter la présence d’un proxy configuré sur un système Linux.

Il analyse les variables d’environnement liées aux proxys (HTTP/HTTPS) afin d’identifier si le trafic réseau est redirigé via un intermédiaire, ce qui peut être légitime (proxy d’entreprise) ou potentiellement risqué.

Le module fournit un score de sécurité ainsi qu’une recommandation pour évaluer la légitimité de cette configuration.



## Fonctionnalités

* Détection des variables d’environnement proxy :

  * `http_proxy` / `HTTP_PROXY`
  * `https_proxy` / `HTTPS_PROXY`
* Identification de la présence d’un proxy actif.
* Analyse simple du contexte réseau.
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
  * `recommendation` : état du proxy



## Structure

proxyChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation

* **Score 5** : aucun proxy détecté.
* **Score 4** : proxy détecté (configuration potentiellement légitime mais à vérifier).

### États possibles

* **OK** : analyse effectuée avec succès.



## Utilisation

```bash 
./main.sh --script proxyChecker 
```

### Mode test 

```bash 
./main.sh --script proxyChecker  --test
```



## Exemple de sortie JSON

```json 
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "Proxy actif : HTTP Proxy détecté. Vérifiez s'il est légitime."
}
```



## Bonnes pratiques

* Vérifier la légitimité des proxys configurés (entreprise, sécurité, etc.).
* Éviter les proxys inconnus ou non maîtrisés.
* Nettoyer les variables d’environnement inutiles.
* Surveiller les modifications de configuration réseau.
* Intégrer ce module dans un audit de sécurité global.


