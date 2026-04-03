# suidSgidChecker

## Description
`suidSgidChecker` est un module Bash destiné à repérer les fichiers marqués avec les bits SUID et SGID. Il permet d’identifier rapidement des binaires potentiellement sensibles afin d’évaluer le niveau d’exposition du système.

Le module produit un retour JSON structuré, adapté à une intégration dans un outil de diagnostic ou d’audit de sécurité.

## Fonctionnalités
- Recherche des fichiers avec le bit SUID.
- Recherche des fichiers avec le bit SGID.
- Filtrage des cas usuels attendus, comme `sudo` et `su`.
- Calcul d’un score de sécurité sur 5 en fonction des éléments suspects détectés.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur si applicable
  - `score` : note sur 5
  - `recommendation` : synthèse des fichiers détectés

## Structure
suidSgidChecker/
├── main.sh        # Script principal du module
├── module.json    # Métadonnées du module
└── README.md      # Documentation complète

## Logique d’évaluation

| Score | Condition | Interprétation et recommandations |
|-------|-----------|---------------------------------|
| 5     | Aucun fichier suspect détecté | Configuration plutôt saine. Vérifier régulièrement les privilèges spéciaux. |
| 2     | Un ou plusieurs fichiers SUID/SGID suspects détectés | Vérifier la légitimité des binaires trouvés et supprimer les droits inutiles. |

## Utilisation
Exécution en ligne de commande :
```bash
./main.sh --script suidSgidChecker
```

### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 2,
  "recommendation": "Fichiers SUID/SGID anormaux :\n/tmp/test-suid\n/tmp/test-sgid"
}
```

## Bonnes pratiques
- Réduire au strict nécessaire les permissions SUID/SGID.
- Vérifier régulièrement les binaires présents avec ces bits spéciaux.
- Contrôler la légitimité des fichiers détectés avant toute suppression de droit.
- Intégrer ce module dans des audits de durcissement système.

## Mode test (`--test`)
Le module intègre un mode de tests unitaires accessible via :
```bash
./main.sh --script suidSgidChecker --test
```

### Objectif
Valider :
* La logique de calcul du score
* La détection des fichiers suspects simulés
* La cohérence de la recommandation

### Contenu des tests
Le mode `--test` exécute trois cas simulés :
* Aucun fichier suspect
* Un fichier SUID/SGID suspect
* Plusieurs fichiers suspects

Chaque test affiche :
* Le scénario simulé
* Le score attendu
* Le score obtenu
* Le résultat du test

### Garantie apportée
Le mode test permet de vérifier rapidement que la logique de score reste cohérente et que le module continue de produire un JSON exploitable.