# diagnosticRapide

## Description
`diagnosticRapide` est un module Bash de profil diagnostique. Il expose une liste de modules prioritaires a executer pour un controle rapide de l'etat de la machine.

Le module lit le fichier `diag.json` du dossier et retourne son contenu en JSON compact. Il est adapte a une integration UI/API pour selectionner un lot de modules.

## Fonctionnalites
- Chargement du profil depuis `diag.json`.
- Verification de la presence du fichier de configuration.
- Retour JSON compact du profil (via `jq -c`).
- Format simple et stable pour orchestration des modules.

## Structure
diagnosticRapide/
├── main.sh        # Script principal du module diagnostique
├── module.json    # Metadonnees du module
├── diag.json      # Liste des modules du profil
└── README.md      # Documentation du module

## Modules inclus
- cpuUsage
- ramUsage
- diskUsage
- internetConnectivityTest
- gatewayReachabilityTest
- passwordChecker

## Utilisation
Execution depuis la racine `bash-app` :
```bash
sudo ./main.sh --script diagnosticRapide
```

### Exemple de sortie JSON
```json
{"categorie 1":["cpuUsage","ramUsage","diskUsage","internetConnectivityTest","gatewayReachabilityTest","passwordChecker"]}
```

## Bonnes pratiques
- Garder ce profil court pour les controles de premiere passe.
- Ajouter uniquement des modules a execution rapide.
- Verifier la coherence des noms de modules dans `diag.json`.
