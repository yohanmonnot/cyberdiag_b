# privilegesChecker

## Description
`privilegesChecker` est un module Bash permettant de **vérifier les privilèges système sensibles** sur un système Linux.
Il analyse la configuration des accès privilégiés et génère un **rapport JSON** destiné à être utilisé dans le cadre :
- d’audits de sécurité
- de pipelines CI/CD
- d’outils de supervision ou de diagnostic automatisé

Le script :
- affiche le résultat JSON sur la sortie standard (**stdout**)
- peut générer un fichier `module.json` contenant les métadonnées du module

## Fonctionnalités
- Vérifie si le script est exécuté avec les privilèges **root**.
- Vérifie la présence et la configuration de la commande **sudo**.
- Détecte les utilisateurs ayant un **UID égal à 0**.
- Vérifie la **lisibilité et la sécurité du fichier `/etc/sudoers`**.
- Retour structuré en JSON incluant :
  - `status` : OK, WARNING ou CRITICAL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : recommandations pour sécuriser les privilèges

## Structure
privilegesChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module
- `module.json` : métadonnées du module
- `README.md` : documentation du module

## Logique d’évaluation
- **Score 5** : configuration sécurisée, aucun problème détecté.
- **Score 4** : avertissement mineur, recommandations de sécurisation.
- **Score 3** : plusieurs points sensibles détectés, action recommandée.
- **Score 2** : configuration risquée, mise en sécurité urgente.
- **Score 1** : configuration critique, risque élevé, intervention immédiate nécessaire.

## Utilisation
```bash
./main.sh --script privilegesChecker
```

### Mode test 
```bash
./main.sh --script privilegesChecker --test
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Des utilisateurs avec UID 0 ont été détectés.\nLe fichier /etc/sudoers est lisible par des utilisateurs non privilégiés.\nRecommandations :\n1. Limitez les utilisateurs avec UID 0\n2. Vérifiez les permissions de /etc/sudoers\n3. Assurez-vous que sudo est correctement configuré"
}
```

## Bonnes pratiques
- Exécutez régulièrement le module pour détecter toute modification des privilèges.
- Limitez le nombre d’utilisateurs avec UID 0 au strict nécessaire.
- Protégez le fichier `/etc/sudoers` et vérifiez sa lisibilité.
- Configurez sudo de manière sécurisée et documentez les exceptions.
- Intégrez ce module dans des audits automatisés ou des pipelines CI/CD pour la supervision continue.