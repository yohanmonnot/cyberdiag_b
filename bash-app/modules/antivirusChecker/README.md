# antivirusChecker

## Description
`antivirusChecker` est un module Bash conçu pour vérifier la présence et l’état de fonctionnement des antivirus sur un système Linux. Il détecte plusieurs antivirus connus (ClamAV, Sophos, ESET NOD32, Comodo), contrôle la disponibilité des outils associés et l’état des bases virales ou du service actif, puis fournit une évaluation de sécurité accompagnée de recommandations détaillées.  

Le module produit un retour JSON structuré, utile pour l’intégration dans des outils de diagnostic ou de supervision de sécurité.

## Fonctionnalités
- Détection automatique du système d’exploitation (Linux uniquement).
- Vérification de la présence de plusieurs antivirus :
  - **ClamAV**
  - **Sophos Antivirus**
  - **ESET NOD32**
  - **Comodo Antivirus**
- Vérification de l’état des bases virales ou des services antivirus :
  - Bases virales à jour
  - Services actifs
- Calcul d’un score de sécurité sur 5 basé sur la présence, l’état et la mise à jour de l’antivirus.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur si applicable
  - `score` : note sur 5
  - `recommendation` : recommandations de sécurité détaillées avec description des vérifications

## Structure
antivirusChecker/
├── main.sh        # Script principal du module
├── module.json    # Métadonnées du module
└── README.md      # Documentation complète

## Logique d’évaluation

| Score | Condition                                                                 | Interprétation et recommandations |
|-------|---------------------------------------------------------------------------|---------------------------------|
| 5     | Antivirus détecté et fonctionnel, bases virales à jour, service actif     | Système protégé et sécurisé. Maintenir les mises à jour régulières. |
| 3     | Antivirus détecté mais certaines vérifications (bases ou service) non optimales | Vérifiez l’antivirus et mettez à jour si nécessaire. |
| 2     | Antivirus détecté mais service inactif ou bases virales obsolètes        | Vérification urgente et mise à jour recommandée immédiatement. |
| 1     | Aucun antivirus détecté                                                   | Installez un antivirus reconnu pour protéger le système. |
| 0     | Système non supporté ou environnement insuffisant                        | Aucun diagnostic possible. |

## Utilisation
Exécution en ligne de commande :
```bash
./main.sh --script antivirusChecker
```

### Mode test
```bash
./main.sh --script antivirusChecker --test
```

### Exemple de sortie JSON :
```json
{
  "status": "OK",
  "error": "",
  "score": 3,
  "recommendation": "Antivirus détecté mais certaines vérifications (bases virales ou service) ne sont pas optimales.\nVérifiez et mettez à jour l'antivirus.\nDétails : ClamAV détecté. Bases virales ClamAV non vérifiables ou obsolètes. "
}
```

## Bonnes pratiques
- Maintenir les antivirus installés à jour.
- Vérifier régulièrement que les services antivirus sont actifs.
- Surveiller l’absence d’antivirus et installer une solution reconnue si nécessaire.
- Intégrer ce module dans des audits réguliers de sécurité ou des outils de monitoring.

## Mode test (`--test`)
Le module intègre un protocole de tests complet accessible via :
```bash
./main.sh --script antivirusChecker --test
```

### Objectif
Valider :
* La logique de calcul du score
* La cohérence des recommandations
* La structure du JSON généré
* La couverture complète des scénarios possibles

### Contenu des tests
Le mode `--test` exécute trois phases :

#### 1. Tests unitaires simulés
Simulation contrôlée des combinaisons suivantes :
* Aucun antivirus
* ClamAV à jour
* ClamAV obsolète
* Sophos actif
* Sophos inactif
* Combinaisons multiples

Chaque test affiche :
* Les paramètres simulés
* Le score attendu
* Le score obtenu
* Le résultat (SUCCÈS / ÉCHEC)

#### 2. Test d’intégration réel
Exécution réelle du module dans l’environnement courant :
* Génération du JSON
* Validation de sa syntaxe via `jq`
* Vérification des champs obligatoires :
  * `status`
  * `score`
  * `recommendation`

#### 3. Vérification de couverture logique
Contrôle que toutes les branches critiques du code sont couvertes :
* Présence / absence antivirus
* Antivirus à jour / obsolète
* Service actif / inactif
* Dégradation correcte du score


### Garantie apportée
Le mode test garantit :
* Fiabilité du calcul du score
* Cohérence des recommandations
* Conformité du format JSON
* Robustesse face aux différents états système

Ce protocole permet d’intégrer le module dans un pipeline CI/CD ou un processus d’audit automatisé en toute confiance.