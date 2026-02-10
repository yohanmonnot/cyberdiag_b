#!/bin/bash
#Script pour donner les droits d'exécution à tous les scripts dans le dossier bash-app
#A exécuter depuis la racine du projet

if [ -d "bash-app" ]; then
  find bash-app -type f -name "*.sh" -exec chmod +x {} \;
  echo "Droits d'exécution ajoutés à tous les scripts dans bash-app."
  sudo chmod +x ./bash-app/modules/graphicInterface/runtime/bin/java
  echo "Droits d'exécution ajoutés à l'interface java."
  sudo chmod +x ./bash-app/modules/reports/*
  echo "Droits d'exécution ajoutés aux scripts de génération de rapports."
  sudo chmod +x ./scripts/*
  echo "Droits d'exécution ajoutés aux scripts de la racine."
else
  echo "Le dossier bash-app n'existe pas. Veuillez exécuter depuis la racine du projet."
fi