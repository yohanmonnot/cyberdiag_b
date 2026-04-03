# diagnosticInterfaces

## Description
`diagnosticInterfaces` est un module Bash de profil diagnostique pour les modules d'interface et de fonctionnalites transverses.

Il retourne le contenu de `diag.json` pour proposer un lot de modules orientes interaction/visualisation.

## Fonctionnalites
- Regroupement des modules d'interface.
- Sortie JSON compacte pour consommation par le lanceur.
- Format de profil coherent avec les autres diagnostics.

## Structure
diagnosticInterfaces/
├── main.sh
├── module.json
├── diag.json
└── README.md

## Modules inclus
- cliInterface
- graphicInterface
- reports
- diagTest

## Utilisation
```bash
sudo ./main.sh --script diagnosticInterfaces
```

### Exemple de sortie JSON
```json
{"categorie 1":["cliInterface","graphicInterface","reports","diagTest"]}
```

## Bonnes pratiques
- Eviter d'y mettre des modules purement bas niveau.
- Conserver ce profil pour les parcours utilisateur et l'UX.
