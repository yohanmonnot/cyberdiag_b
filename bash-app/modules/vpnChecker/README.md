# vpnChecker

## Description
`vpnChecker` est un module Bash permettant de vérifier la présence et l’état des interfaces VPN sur un système Linux.
Il analyse les interfaces réseau susceptibles d’être utilisées par un VPN, vérifie leur état (UP/DOWN), récupère l’adresse IP publique et calcule un score de sécurité global.

Le module fournit une évaluation simple de la situation VPN du système ainsi que des recommandations adaptées.

## Fonctionnalités
- Vérification des dépendances système (`ip`, `jq`, `curl`).
- Détection automatique des interfaces VPN potentielles :
  - `tun*`
  - `tap*`
  - `wg*`
- Analyse de l’état des interfaces détectées (UP/DOWN).
- Récupération de l’adresse IP publique via API externe.
- Calcul d’un score de sécurité sur 5 niveaux.
- Génération d’une recommandation détaillée.
- Retour structuré en JSON incluant :
  - `status` : OK ou FAIL
  - `error` : message d’erreur le cas échéant
  - `score` : note sur 5
  - `recommendation` : résumé détaillé de l’état VPN

## Structure
vpnChecker/
├── main.sh
├── module.json
└── README.md

- `main.sh` : script principal du module.
- `module.json` : métadonnées du module.
- `test.sh` : script de test automatisé.
- `README.md` : documentation du module.

## Logique d’évaluation
- **Score 5** : au moins une interface VPN active (UP) avec IP publique détectée.
- **Score 4** : au moins une interface VPN active mais IP publique non vérifiée.
- **Score 2** : interface VPN détectée mais inactive.
- **Score 1** : aucune interface VPN détectée.

## Utilisation
```bash
./main.sh --script vpnChecker
```


### Exemple de sortie JSON
```json
{
  "status": "OK",
  "error": "",
  "score": 4,
  "recommendation": "État des interfaces VPN :\n- tun0 (UP)\n\nIP publique détectée : Non détectée\n\nAction recommandée :\nVPN actif mais IP publique non vérifiée."
}
```

## Bonnes pratiques
- Vérifiez que les interfaces VPN attendues sont bien actives (état UP).
- Assurez-vous que l’IP publique est cohérente avec votre fournisseur VPN.
- Surveillez régulièrement l’état des interfaces après redémarrage système.
- Automatisez l’exécution du module pour détecter toute désactivation accidentelle du VPN.
- Combinez ce module avec d’autres contrôles réseau pour un audit de sécurité complet.