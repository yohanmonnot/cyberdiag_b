# diagnosticReseau

## Description
`diagnosticReseau` est un module Bash de profil diagnostique pour les verifications reseau. Il fournit un lot de modules axes connectivite, ports, trafic et securite reseau.

Le module lit `diag.json` et retourne le profil en JSON compact.

## Fonctionnalites
- Exposition d'un profil reseau pret a executer.
- Verification de la presence de `diag.json`.
- Retour JSON compact pour integration dans une UI de selection.

## Structure
diagnosticReseau/
├── main.sh
├── module.json
├── diag.json
└── README.md

## Modules inclus
- networkConfigChecker
- openPortsScanner
- listeningServicesChecker
- wifiChecker
- vpnChecker
- tlsChecker
- proxyChecker
- externalIpChecker
- networkTrafficMonitor
- arpTableChecker
- rogueDhcpChecker
- macSpoofChecker

## Utilisation
```bash
sudo ./main.sh --script diagnosticReseau
```

### Exemple de sortie JSON
```json
{"categorie 1":["networkConfigChecker","openPortsScanner","listeningServicesChecker","wifiChecker","vpnChecker","tlsChecker","proxyChecker","externalIpChecker","networkTrafficMonitor","arpTableChecker","rogueDhcpChecker","macSpoofChecker"]}
```

## Bonnes pratiques
- Regrouper ici tous les checks reseau du projet.
- Eviter de melanger des modules purement UI dans ce profil.
