#!/bin/bash

# Import du logger (chemin conservé selon votre script original)
source "$(dirname "$0")/../../utils/logger.sh"

# --- CONFIGURATION DU NOUVEAU RUNTIME ---
# Le dossier runtime est maintenant le dossier déployé par votre script de déploiement
RUNTIME_PATH="$(dirname "$0")/runtime"
MODULE_NAME="edu.cyclonicforce.fr.java.ui"
MAIN_CLASS="edu.cyclonicforce.fr.ui.Main"

# Chemin vers le binaire java interne au runtime
JAVA_BIN="$RUNTIME_PATH/bin/java"

# Vérification de l'existence du runtime
if [ ! -f "$JAVA_BIN" ]; then
    log_error "JavaFX Runtime not found at $RUNTIME_PATH. Please run deployApp.sh first."
    exit 1
fi

log_info "Launching JavaFX GUI from modular runtime: $RUNTIME_PATH"

# Lancement de l'application
# On utilise --module pour lancer le module spécifique
"$JAVA_BIN" --module "${MODULE_NAME}/${MAIN_CLASS}" "$@"

# Récupération du code de sortie de l'application Java
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log_info "JavaFX GUI finished successfully"
else
    log_error "JavaFX GUI exited with error code $EXIT_CODE"
fi

exit $EXIT_CODE