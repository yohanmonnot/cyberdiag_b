#!/bin/bash

# --- CONFIGURATION ---
PROJECT_DIR=$(dirname "$0")
cd "$PROJECT_DIR" || exit

echo "=========================================="
echo "🚀 Démarrage du Build de l'application..."
echo "=========================================="

# Vérification que Maven est installé
if ! command -v mvn &> /dev/null; then
    echo "❌ Erreur : Maven ('mvn') n'est pas installé ou n'est pas dans le PATH."
    exit 1
fi

# Exécution de la commande Maven
# clean : nettoie le dossier target
# package : compile et crée les JARs
# javafx:jlink : crée l'image runtime autonome
echo "📦 Exécution de Maven (clean package javafx:jlink)..."
mvn clean package javafx:jlink

# Vérification du succès de la commande précédente
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ BUILD SUCCÈS !"
    echo "   L'image autonome a été créée dans le dossier 'target/'"
    echo "   Vous pouvez la lancer avec ./startApp.sh"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "❌ BUILD ÉCHEC."
    echo "   Vérifiez les erreurs ci-dessus."
    echo "=========================================="
    exit 1
fi