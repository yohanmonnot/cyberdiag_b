<<<<<<< HEAD
# CyberDiag Groupe B



## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/topics/git/add_files/#add-files-to-a-git-repository) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://forgens.univ-ubs.fr/gitlab/but2info/cyberdiag_b.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://forgens.univ-ubs.fr/gitlab/but2info/cyberdiag_b/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Set auto-merge](https://docs.gitlab.com/user/project/merge_requests/auto_merge/)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
=======
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
│   │   ├── cpuUsage/
│   │   ├── memoryUsage/
│   │   ├── diskUsage/
│   │   ├── majChecker/
│   │   ├── antivirusChecker/
│   │   ├── firewallChecker/
│   │   ├── malwareScan/
│   │   ├── passwordChecker/
│   │   ├── privilegesChecker/
│   │   ├── usbChecker/
│   │   ├── wifiChecker/
│   │   ├── cliInterface/
│   │   ├── graphicInterface/
│   │   ├── testArgs/
│   │   └── exampleModule/
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
* Gradle (ou utilisation du wrapper `gradlew`)

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
* `memoryUsage` : suivi mémoire RAM
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
| BLANCHETIÈRE--DRÔLON Nolhan | Communication + Back-end              |
>>>>>>> aae920a (maj bash-app/main.sh)
