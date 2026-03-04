# SAÉ CyberDiag

## Table des matières

* [Description](#description)
* [Arborescence principale](#arborescence-principale)
* [Prérequis](#prérequis)
* [Utilisation](#utilisation)

  * [Modes disponibles](#modes-disponibles)
  * [Options pour `--script`](#options-pour---script)
  * [Exemples](#exemples)
* [Modules inclus et à venir](#modules-inclus-et-à-venir)
* [Contribution](#contribution)
* [Équipe](#équipe)

---

## Description

**CyberDiag** est un outil de diagnostic et de suivi des ressources système, conçu pour être :

* **Modulaire** : ajout et mise à jour facile de modules indépendants.
* **Polyvalent** : utilisable en mode terminal Bash ou via interface graphique Java.
* **Centralisé** : le script principal `bash-app/main.sh` gère le lancement de tous les modules et interfaces.

Il fonctionne en réseau isolé (version portable) ou modulable avec Internet (version modulaire).

---

## Arborescence principale

```
cyberdiag_b/
├── bash-app/
│   ├── main.sh              # Script principal centralisant tous les modules
│   ├── modules/             # Modules fonctionnels
│   │   ├── antivirusChecker/
│   │   ├── bluetoothChecker/
│   │   ├── cpuUsage/
│   │   ├── diskUsage/
│   │   ├── firewallChecker/
│   │   ├── majChecker/
│   │   ├── malwareScan/
│   │   ├── passwordChecker/
│   │   ├── privilegesChecker/
│   │   ├── ramUsage/
│   │   ├── usbChecker/
│   │   ├── wifiChecker/
│   │   ├── cliInterface/
│   │   └── graphicInterface/
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

* Lister tous les modules filtrés par type `monitoring` et triés par description :

```bash
./main.sh --script list --filter monitoring --sort description
```

* Lancer un module d’interface spécifique :

```bash
./main.sh --interface graphicInterface
```

---

## Modules inclus et à venir

### Modules actuellement disponibles

#### 🖥️ Modules de Monitoring

* `cpuUsage` : suivi CPU et utilisation processeur
* `ramUsage` : suivi mémoire RAM
* `diskUsage` : suivi espace disque

#### 🔧 Modules de Maintenance

* `majChecker` : vérification des mises à jour système
* `passwordChecker` : vérification et analyse des mots de passe
* `privilegesChecker` : vérification des droits et permissions utilisateur

#### 🔒 Modules de Sécurité

* `antivirusChecker` : analyse l'état de fonctionnement de l'antivirus
* `firewallChecker` : vérification du pare-feu et sa configuration
* `malwareScan` : analyse des malwares sur le système
* `usbChecker` : détection et contrôle des appareils USB
* `wifiChecker` : vérification des connexions réseau et recommandations de sécurité

#### 🖥️ Interfaces

* `cliInterface` : interface terminal textuelle
* `graphicInterface` : interface graphique Java
* `exampleModule` : modèle pour créer de nouveaux modules

### Modules prévus / futurs

* **Diagnostics réseau avancés** : tests de connectivité, analyse des ports, bande passante, détection des anomalies réseau
* **Diagnostics préconfigurés** : ensembles de tests combinant plusieurs modules pour un audit rapide et complet
* **Rapports d'audit** : génération automatique de rapports PDF/HTML

> Chaque nouveau module est autonome et peut être appelé individuellement via `main.sh --script <module>` ou intégré dans une interface.

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
