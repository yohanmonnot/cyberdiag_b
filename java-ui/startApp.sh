#!/bin/bash

# --- CONFIGURATION ---
# Nom de votre module défini dans module-info.java
MODULE_NAME="edu.cyclonicforce.fr.java.ui"
# Chemin complet vers votre classe Main
MAIN_CLASS="edu.cyclonicforce.fr.ui.Main"

# Détection automatique du dossier de l'image JLink
JLINK_DIR=$(find target -maxdepth 1 -type d -name "java-ui*" ! -name "classes" ! -name "generated-sources" ! -name "maven-*" | head -n 1)

# Si vous préférez mettre le chemin en dur :
# JLINK_DIR="target/java-ui-linux"

if [ -z "$JLINK_DIR" ] || [ ! -f "$JLINK_DIR/bin/java" ]; then
    echo "❌ Erreur : Impossible de trouver l'image d'exécution."
    echo "   Avez-vous lancé './buildApp.sh' avant ?"
    exit 1
fi

JAVA_EXEC="$JLINK_DIR/bin/java"

# --- MENU DE SÉLECTION ---
echo "=========================================="
echo "🎯 Options de lancement pour $MODULE_NAME"
echo "=========================================="
echo "1) Lancement normal (Aucun argument)"
echo "2) Aide (--help)"
echo "3) Version (--version)"
echo "4) Mode Verbeux (--verbose)"
echo "5) Mode Debug (--debug)"
echo "6) Arguments personnalisés (ex: --logs-output ./logs)"
echo "q) Quitter"
echo "------------------------------------------"

read -p "Votre choix : " choice

APP_ARGS=""

case $choice in
    1)
        echo "👉 Lancement standard..."
        APP_ARGS=""
        ;;
    2)
        echo "👉 Affichage de l'aide..."
        APP_ARGS="--help"
        ;;
    3)
        echo "👉 Affichage de la version..."
        APP_ARGS="--version"
        ;;
    4)
        echo "👉 Lancement en mode Verbeux..."
        APP_ARGS="--verbose"
        ;;
    5)
        echo "👉 Lancement en mode Debug..."
        APP_ARGS="--debug"
        ;;
    6)
        read -p "✍️  Entrez vos arguments : " custom_args
        APP_ARGS="$custom_args"
        ;;
    q|Q)
        echo "👋 Au revoir !"
        exit 0
        ;;
    *)
        echo "⚠️  Choix invalide. Lancement standard par défaut."
        APP_ARGS=""
        ;;
esac

echo "=========================================="
echo "🚀 Exécution..."
echo "   Commande : $JAVA_EXEC --module ${MODULE_NAME}/${MAIN_CLASS} $APP_ARGS"
echo "=========================================="

# Lancement de l'application avec les arguments choisis
"$JAVA_EXEC" --module "${MODULE_NAME}/${MAIN_CLASS}" $APP_ARGS