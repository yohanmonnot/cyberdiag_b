# SAÉ CyberDiag

## Table des matières

* [Description](#description)
* [Arborescence principale](#arborescence-principale)
* [Prérequis](#prérequis)
* [Utilisation](#utilisation)

  * [Modes disponibles](#modes-disponibles)
  * [Options pour `--script`](#options-pour---script)
  * [Exemples](#exemples)
* [Modules inclus](#modules-inclus)
* [Contribution](#contribution)
* [Équipe](#équipe)

---

## Description

**CyberDiag** est un outil de diagnostic et de suivi des ressources système, conçu pour être :

* **Modulaire** : ajout et mise à jour facile de modules indépendants.
* **Polyvalent** : utilisable en mode terminal Bash ou via interface graphique Java.
* **Centralisé** : le script principal `bash-app/main.sh` gère le lancement de tous les modules et interfaces.
* **Profilable** : exécution possible par profils de diagnostics (`diagnosticRapide`, `diagnosticReseau`, etc.).

Il fonctionne en réseau isolé (version portable) ou modulable avec Internet (version modulaire).

---

## Arborescence principale

```
cyberdiag_b/
├── bash-app/
│   ├── main.sh              # Script principal centralisant tous les modules
│   ├── modules/             # Modules fonctionnels
│   │   ├── antivirusChecker/
│   │   ├── arpTableChecker/
│   │   ├── bluetoothChecker/
│   │   ├── cliInterface/
│   │   ├── cpuUsage/
│   │   ├── cronChecker/
│   │   ├── diagTest/
│   │   ├── diskUsage/
│   │   ├── encryptionChecker/
│   │   ├── externallpChecker/
│   │   ├── firewallChecker/
│   │   ├── firewallRulesAudit/
│   │   ├── gatewayReachabilityTest/
│   │   ├── graphicInterface/
│   │   ├── internetConnectivityTest/
│   │   ├── listeningServicesChecker/
│   │   ├── logAnalyzer/
│   │   ├── macSpoofChecker/
│   │   ├── majChecker/
│   │   ├── macSpoofChecker/
│   │   ├── malwareScan/
│   │   ├── networkConfigChecker/
│   │   ├── networkTrafficMonitor/
│   │   ├── openPortsScanner/
│   │   ├── osInfo/
│   │   ├── passwordChecker/
│   │   ├── privilegesChecker/
│   │   ├── processChecker/
│   │   ├── proxyChecker/
│   │   ├── quizExample/
│   │   ├── ramUsage/
│   │   ├── reports/
│   │   ├── rogueDhcpChecker/
│   │   ├── secureBootChecker/
│   │   ├── serviceChecker/
│   │   ├── sshConfigChecker/
│   │   ├── sudoConfigChecker/
│   │   ├── suidSgidChecker/
│   │   ├── tlsChecker/
│   │   ├── updateConfigChecker/
│   │   ├── usbChecker/
│   │   ├── userAccountChecker/
│   │   ├── vpnChecker/
│   │   └── wifiChecker/
│   └── utils/               # Scripts utilitaires (env, logger)
├── java-ui/                 # Interface graphique Java
├── Documentations/          # Documents clients et veille technologique
└── README.md
```

Chaque module contient :

* `main.sh` : script exécuté par `main.sh`
* `module.json` : métadonnées du module
* `README.md` : documentation propre au module

---

## Prérequis

* Linux ou macOS pour Bash
* `jq` pour parser les fichiers JSON
* Java 17+ pour l’interface graphique
* Maven

---

## Utilisation

Le script `bash-app/main.sh` centralise tous les modules et modes.

### Modes disponibles

| Mode                         | Description                                                         |
| ---------------------------- | ------------------------------------------------------------------- |
| `--gui`                      | Lance l’interface graphique (`graphicInterface`)                    |
| `--cli`                      | Lance l’interface textuelle (`cliInterface`)                        |
| `--test`                     | Lance les tests globaux des modules via `utils/test_modules.sh`     |
| `--script <module> [args...]`| Exécute un module en ligne de commande avec ses arguments éventuels |
| `--interface <module_name>`  | Lance un module d’interface spécifique                              |

### Options pour `--script`

| Option            | Description                                                   |
| ----------------- | ------------------------------------------------------------- |
| `--filter <type>` | Filtre les modules par type (`cpu`, `memory`, etc.)           |
| `--sort <field>`  | Trie la liste des modules par `name`, `type` ou `description` |
| `list`            | Affiche la liste des modules disponibles avec filtrage et tri |

### Exemples

* Lancer l’interface graphique :

```bash
./main.sh --gui
```
ou
```bash
./main.sh
```

* Lancer l’interface CLI :

```bash
./main.sh --cli
```

* Exécuter un module :

```bash
./main.sh --script cpuUsage
```

* Exécuter le test d'un module :

```bash
./main.sh --script cpuUsage --test
```

* Exécuter le test de tous les modules:

```bash
./main.sh --test
```

* Lister tous les modules filtrés par type `monitoring` et triés par description :

```bash
./main.sh --script list --filter monitoring --sort description
```

* Lancer les tests globaux :

```bash
./main.sh --test
```

* Exécuter un profil de diagnostic :

```bash
./main.sh --script diagnosticRapide
```

* Lancer un module d’interface spécifique :

```bash
./main.sh --interface graphicInterface
```

---

## Modules inclus

### Module de Monitoring et système

* `cpuUsage` : suivi CPU et utilisation processeur
* `diskUsage` : suivi espace disque
* `externalIpChecker` : récupération de l’adresse IP publique
* `gatewayReachabilityTest` : test de disponibilité de la passerelle réseau
* `internetConnectivityTest` : vérification de l’accès à Internet
* `networkConfigChecker` : contrôle de la configuration réseau (IP, DNS, gateway)
* `networkTrafficMonitor` : surveillance du trafic réseau
* `osInfo` : récupération des informations système (OS, kernel)
* `ramUsage` : suivi mémoire RAM


### Modules de maintenance

* `majChecker` : vérification des mises à jour système
* `updateConfigChecker` : contrôle de la configuration des mises à jour automatiques
* `logAnalyzer` : analyse rapide des logs système et de sécurité

### Modules de sécurité

* `antivirusChecker` : analyse l'état de fonctionnement de l'antivirus
* `arpTableChecker` : détection d’anomalies dans la table ARP (ARP poisoning)
* `bluetoothChecker` : analyse de l’état et des risques liés au Bluetooth
* `cronChecker` : détection de tâches planifiées suspectes
* `encryptionChecker` : vérification du chiffrement des disques (LUKS)
* `firewallChecker` : vérification du pare-feu et sa configuration
* `firewallRulesAudit` : audit des règles firewall et détection de règles permissives
* `listeningServicesChecker` : identification des services réseau suspects
* `macSpoofChecker` : détection de spoofing d’adresse MAC
* `malwareScan` : analyse des malwares sur le système
* `openPortsScanner` : détection des ports ouverts exposés
* `passwordChecker` : vérification et analyse des mots de passe
* `privilegesChecker` : analyse des privilèges utilisateurs et élévations
* `processChecker` : détection de processus suspects
* `proxyChecker` : détection de configuration proxy potentiellement risquée
* `rogueDhcpChecker` : détection de serveurs DHCP non autorisés
* `secureBootChecker` : vérification de l’état du Secure Boot
* `serviceChecker` : identification de services inutiles ou dangereux
* `sshConfigChecker` : audit de la configuration SSH
* `sudoConfigChecker` : analyse des règles sudo à risque
* `suidSgidChecker` : détection de binaires SUID/SGID sensibles
* `tlsChecker` : vérification du support TLS sécurisé
* `usbChecker` : détection et contrôle des appareils USB
* `userAccountChecker` : détection de comptes utilisateurs suspects ou inactifs
* `vpnChecker` : vérification de la présence et de l’état d’un VPN
* `wifiChecker` : vérification des connexions réseau et recommandations de sécurité


### Interfaces et support

* `cliInterface` : interface terminal textuelle
* `diagTest` : module de test global pour validation du système
* `graphicInterface` : interface graphique Java
* `quizExample` : module d’exemple interactif
* `reports` : génération de rapports d’analyse


### Profils de diagnostics

* `diagnosticRapide`
* `diagnosticReseau`
* `diagnosticSecuriteSysteme`
* `diagnosticOutils`
* `diagnosticInterfaces`
* `diagnosticComplet`

Total : **48 modules**

---

## Contribution

1. Se placer sur `dev` :

```bash
git checkout dev
```

2. Créer une branche pour la nouvelle fonctionnalité :

```bash
git checkout -b feature/nom-fonctionnalité
```

3. Développer, tester, committer et pousser.
4. Pull request vers `dev` et merge.
5. Supprimer la branche de développement une fois le merge effectué.
6. Les merges vers `main` sont réservés aux versions stables.

---

## Équipe

| Nom                         | Rôle principal                        |
| --------------------------- | ------------------------------------- |
| TOUZEAU Célian              | Chef de Projet + Back-end Bash        |
| HUBERT Mathis               | Graphiste + Contenu visuel            |
| LÉTANG Augustin             | SCRUM Master + Front-end et Graphisme |
| MONNOT Yohan                | Développement Front-end + Contenu     |
| BD Nolhan | Communication + Back-end              |
