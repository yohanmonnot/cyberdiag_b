# updateConfigChecker

## Description

`updateConfigChecker` est un module Bash permettant de vérifier la configuration des mises à jour automatiques sur un système Linux basé sur Debian/Ubuntu.

Le module analyse les fichiers de configuration `apt` pour déterminer si les mises à jour automatiques sont activées et fournit un score de sécurité ainsi qu’une recommandation pour sécuriser le système.



## Fonctionnalités
* Vérification de l’état des mises à jour automatiques via `/etc/apt/apt.conf.d/`.
* Identification des paramètres `APT::Periodic::Update-Package-Lists`.
* Calcul d’un score sur 5 niveaux selon l’activation des mises à jour automatiques.
* Génération d’une recommandation détaillée sur l’état actuel.
* Mode test interne possible (adaptable).
* Sortie standardisée en JSON incluant :
  * `status` : OK ou FAIL
  * `error` : message d’erreur éventuel
  * `score` : note sur 5
  * `recommendation` : résumé sur la configuration



## Structure

updateConfigChecker/
├── main.sh
├── module.json
└── README.md

* `main.sh` : script principal du module.
* `module.json` : métadonnées du module.
* `README.md` : documentation.



## Logique d’évaluation
* **Score 5** : mises à jour automatiques activées (`APT::Periodic::Update-Package-Lists = 1;`).
* **Score 3** : mises à jour automatiques désactivées ou non définies.
* **Score 0** : erreur lors de la lecture des fichiers de configuration.

## États possibles
* **OK** : vérification réalisée avec succès.
* **FAIL** : fichier de configuration introuvable ou inaccessible.



## Utilisation
```bash
./main.sh --script updateConfigChecker
```

### Mode test
```bash
./main.sh --script updateConfigChecker --test
```



## Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Mises à jour automatiques : undefined"
}
```



## Bonnes pratiques
* Activez les mises à jour automatiques pour les paquets critiques afin de réduire le risque de vulnérabilités.
* Surveillez régulièrement les configurations de mise à jour pour éviter toute désactivation accidentelle.
* Combinez cette vérification avec des audits de sécurité système et des mises à jour manuelles planifiées pour un système toujours protégé.
* Documentez les exceptions éventuelles dans des environnements sensibles ou critiques.