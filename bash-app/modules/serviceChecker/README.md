# serviceChecker

## Description

`serviceChecker` est un module Bash permettant d’analyser les services actifs sur un système Linux afin d’identifier les services inutiles ou potentiellement risqués.

Le module inspecte les services en cours d’exécution via `systemctl`, détecte certains services obsolètes ou dangereux (comme `telnet`, `ftp`, `rsh`) et fournit un score de sécurité accompagné de recommandations.



## Fonctionnalités
* Vérification de la disponibilité de `systemctl`.
* Récupération de la liste des services actifs (running).
* Détection des services potentiellement dangereux :
  * `telnet`
  * `ftp`
  * `rsh`
* Calcul d’un score sur 5 niveaux selon la présence de services risqués.
* Génération d’une recommandation détaillée listant les services actifs et suspects.
* Mode test interne possible (adaptable).
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé de l’état des services



## Structure

serviceChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : aucun service risqué détecté.
* **Score 2** : présence de services potentiellement dangereux (telnet, ftp, rsh).
* **Score 0** : systemctl indisponible ou erreur d’exécution.

## États possibles
* **OK** : analyse réalisée avec succès.
* **FAIL** : systemctl introuvable ou inaccessible.


## Utilisation
```bash
./main.sh --script serviceChecker 
```

### Mode test
```bash
./main.sh --script serviceChecker --test
```


## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Services actifs :\nssh.service\ncron.service\n\nServices potentiellement inutiles ou risqués :\ntelnet.service"
}
```



## Bonnes pratiques
* Désactivez les services inutiles pour réduire la surface d’attaque.
* Évitez l’utilisation de services obsolètes comme telnet ou rsh.
* Privilégiez des alternatives sécurisées comme SSH.
* Surveillez régulièrement les services actifs après installation de nouveaux logiciels.
* Combinez avec des audits réseau pour une vision complète de la sécurité du système.