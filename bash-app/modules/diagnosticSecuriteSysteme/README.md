# diagnosticSecuriteSysteme

## Description
`diagnosticSecuriteSysteme` est un module Bash de profil diagnostique dedie a la securite et au hardening systeme.

Le module retourne la liste JSON des modules de securite definie dans `diag.json`.

## Fonctionnalites
- Centralisation des modules de securite systeme.
- Lecture simple du profil via `diag.json`.
- Sortie JSON compacte pour orchestration.

## Structure
diagnosticSecuriteSysteme/
├── main.sh
├── module.json
├── diag.json
└── README.md

## Modules inclus
- firewallChecker
- firewallRulesAudit
- antivirusChecker
- malwareScan
- privilegesChecker
- sudoConfigChecker
- sshConfigChecker
- suidSgidChecker
- secureBootChecker
- encryptionChecker
- updateConfigChecker
- processChecker
- userAccountChecker
- cronChecker
- serviceChecker
- majChecker
- osInfo

## Utilisation
```bash
sudo ./main.sh --script diagnosticSecuriteSysteme
```

### Exemple de sortie JSON
```json
{"categorie 1":["firewallChecker","firewallRulesAudit","antivirusChecker","malwareScan","privilegesChecker","sudoConfigChecker","sshConfigChecker","suidSgidChecker","secureBootChecker","encryptionChecker","updateConfigChecker","processChecker","userAccountChecker","cronChecker","serviceChecker","majChecker","osInfo"]}
```

## Bonnes pratiques
- Utiliser ce profil pour un audit securite regulier.
- Maintenir la liste des modules alignee avec les politiques de securite.
