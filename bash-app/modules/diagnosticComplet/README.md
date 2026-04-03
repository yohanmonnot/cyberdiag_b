# diagnosticComplet

## Description
`diagnosticComplet` est un module Bash de profil diagnostique global. Il expose l'ensemble des modules disponibles dans le projet pour un audit integral.

Le module lit `diag.json` et renvoie le profil complet en JSON compact.

## Fonctionnalites
- Liste complete des modules du projet.
- Sortie JSON compacte pour orchestration de masse.
- Point d'entree unique pour un run global.

## Structure
diagnosticComplet/
├── main.sh
├── module.json
├── diag.json
└── README.md

## Modules inclus
Voir `diag.json` (liste complete maintenue automatiquement selon la structure du dossier modules).

## Utilisation
```bash
sudo ./main.sh --script diagnosticComplet
```

### Exemple de sortie JSON
```json
{"categorie 1":["antivirusChecker","arpTableChecker","bluetoothChecker","cliInterface","cpuUsage","cronChecker","diagTest","diskUsage","encryptionChecker","externalIpChecker","firewallChecker","firewallRulesAudit","gatewayReachabilityTest","graphicInterface","internetConnectivityTest","listeningServicesChecker","logAnalyzer","macSpoofChecker","majChecker","malwareScan","networkConfigChecker","networkTrafficMonitor","openPortsScanner","osInfo","passwordChecker","privilegesChecker","processChecker","proxyChecker","quizExample","ramUsage","reports","rogueDhcpChecker","secureBootChecker","serviceChecker","sshConfigChecker","sudoConfigChecker","suidSgidChecker","tlsChecker","updateConfigChecker","usbChecker","userAccountChecker","vpnChecker","wifiChecker"]}
```

## Bonnes pratiques
- Executer ce profil sur des environnements de test ou lors d'audits planifies.
- Coupler ce profil avec un stockage de rapports pour suivi dans le temps.
