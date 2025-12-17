#!/bin/bash

# --- CONFIGURATION ---
# Nom de votre module défini dans module-info.java
MODULE_NAME="edu.cyclonicforce.fr.java.ui"
# Chemin complet vers votre classe Main
MAIN_CLASS="edu.cyclonicforce.fr.ui.Main"

# Détection automatique du dossier de l'image JLink
# On cherche un dossier dans target qui contient "bin/java" mais qui n'est pas le dossier "classes"
# Si votre pom.xml génère 'java-ui-linux', mettez le nom en dur ici si la détection échoue.
JLINK_DIR=$(find target -maxdepth 1 -type d -name "java-ui*" ! -name "classes" ! -name "generated-sources" ! -name "maven-*" | head -n 1)

# Si vous préférez mettre le chemin en dur (recommandé si le nom ne change pas) :
# JLINK_DIR="target/java-ui-linux"

if [ -z "$JLINK_DIR" ] || [ ! -f "$JLINK_DIR/bin/java" ]; then
    echo "❌ Erreur : Impossible de trouver l'image d'exécution."
    echo "   Avez-vous lancé './buildApp.sh' avant ?"
    exit 1
fi

JAVA_EXEC="$JLINK_DIR/bin/java"

echo "=========================================="
echo "🚀 Lancement de l'application..."
echo "   Source : $JLINK_DIR"
echo "   Module : $MODULE_NAME"
echo "=========================================="

# Lancement de l'application
# Note : Pas besoin de classpath, tout est dans le module path de l'image jlink
"$JAVA_EXEC" --module "${MODULE_NAME}/${MAIN_CLASS}"