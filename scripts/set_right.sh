#!/bin/bash
# Script pour donner les droits d'exécution.
# Accepte un dossier cible en paramètre, sinon utilise les chemins par défaut.

TARGET_DIR="${1:-}"

if [ -n "$TARGET_DIR" ]; then
    # Mode "Build" : on applique les droits sur le dossier cible passé en paramètre (sans sudo)
    echo "Application des droits d'exécution dans le dossier cible : $TARGET_DIR"
    
    if [ -d "$TARGET_DIR" ]; then
        # Tous les scripts .sh
        find "$TARGET_DIR" -type f -name "*.sh" -exec chmod +x {} \;
        
        # Binaires et modules spécifiques (vérification préalable de leur existence)
        if [ -f "$TARGET_DIR/modules/graphicInterface/runtime/bin/java" ]; then
            chmod +x "$TARGET_DIR/modules/graphicInterface/runtime/bin/java"
        fi
        
        if [ -d "$TARGET_DIR/modules/reports" ]; then
            chmod +x "$TARGET_DIR/modules/reports/"*
        fi
        
        echo "Droits appliqués avec succès sur la cible."
    else
        echo "Erreur : Le dossier cible $TARGET_DIR n'existe pas."
        exit 1
    fi

else
    # Mode "Local" : comportement original (avec sudo)
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
        exit 1
    fi
fi
