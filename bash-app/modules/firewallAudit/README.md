# firewallAudit

## Description
Le module **firewallAudit** permet d’auditer la configuration du firewall du système Linux et de générer un rapport au format JSON.  
Il vérifie notamment si les services essentiels sont correctement filtrés, si le firewall est actif et si les règles de base sont présentes.

Ce module est conçu pour les administrateurs système souhaitant vérifier rapidement la sécurité réseau de leurs serveurs.

---

## Fonctionnalités

- Vérifie si le firewall (iptables ou nftables) est actif.
- Vérifie la présence des règles de filtrage essentielles.
- Génère un fichier `module.json` contenant :
  - **status** : `OK`, `WARNING` ou `CRITICAL`.
  - **error** : description de l’erreur si applicable.
  - **score** : note de conformité (0 à 5).
  - **recommendation** : conseils pour améliorer la sécurité.

---

## Fichiers

- main.sh # Script principal (privileges checker)
- test.sh # Test automatique du module
- module.json # Fichier JSON généré (à l’exécution)
- README.md