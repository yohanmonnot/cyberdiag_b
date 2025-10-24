#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

OUTPUT_JSON="{\"status\":\"OK\",\"error\":\"\",\"score\":5,\"recommendation\":\"Système à jour\"}"

log_info "[majChecker] Démarrage du module de vérification des mises à jour..."

# --- Detect OS ---
OS="$(uname -s)"
PACKAGE_MANAGER=""
CHECK_CMD=""
NEEDS_SUDO=false
ERROR_MESSAGE=""

case "$OS" in
    "Linux")
        if command -v apt-get &>/dev/null; then
            PACKAGE_MANAGER="apt"
            CHECK_CMD="apt-get -s upgrade 2>/dev/null | grep -c '^Inst '"
            NEEDS_SUDO=false
        elif command -v dnf &>/dev/null; then
            PACKAGE_MANAGER="dnf"
            CHECK_CMD="dnf check-update --refresh | grep -c '^[a-zA-Z0-9]'"
            NEEDS_SUDO=true
        elif command -v yum &>/dev/null; then
            PACKAGE_MANAGER="yum"
            CHECK_CMD="yum check-update | grep -c '^[a-zA-Z0-9]'"
            NEEDS_SUDO=true
        elif command -v pacman &>/dev/null; then
            PACKAGE_MANAGER="pacman"
            CHECK_CMD="checkupdates | wc -l"
            NEEDS_SUDO=false
        elif command -v zypper &>/dev/null; then
            PACKAGE_MANAGER="zypper"
            CHECK_CMD="zypper lu | grep -c '^v '"
            NEEDS_SUDO=true
        else
            ERROR_MESSAGE="Aucun gestionnaire de paquets compatible détecté."
        fi
        ;;
esac

# --- Vérification des dépendances ---
if [[ -n "$ERROR_MESSAGE" ]]; then
    log_error "[majChecker] $ERROR_MESSAGE"
    echo "{\"status\":\"FAIL\",\"error\":\"$ERROR_MESSAGE\"}"
    exit 0
fi

if $NEEDS_SUDO && ! command -v sudo &>/dev/null; then
    ERROR_MESSAGE="sudo est requis mais non disponible."
    log_error "[majChecker] $ERROR_MESSAGE"
    echo "{\"status\":\"FAIL\",\"error\":\"$ERROR_MESSAGE\"}"
    exit 0
fi

log_info "[majChecker] Gestionnaire détecté : $PACKAGE_MANAGER"

# --- Exécution du check ---
UPDATE_COUNT=$($CHECK_CMD || true)
if [[ -z "$UPDATE_COUNT" ]]; then
    UPDATE_COUNT=0
fi

if ! [[ "$UPDATE_COUNT" =~ ^[0-9]+$ ]]; then
    ERROR_MESSAGE="Erreur lors de la vérification des mises à jour via $PACKAGE_MANAGER."
    log_error "[majChecker] $ERROR_MESSAGE"
    echo "{\"status\":\"FAIL\",\"error\":\"$ERROR_MESSAGE\"}"
    exit 0
fi

log_info "[majChecker] Nombre de mises à jour disponibles : $UPDATE_COUNT"

# --- Calcul du score et de la recommandation ---
SCORE=5
RECOMMENDATION="Système à jour"

if [[ $UPDATE_COUNT -gt 0 ]]; then
    if [[ $UPDATE_COUNT -le 3 ]]; then
        SCORE=4
        RECOMMENDATION="Quelques mises à jour disponibles."
    elif [[ $UPDATE_COUNT -le 10 ]]; then
        SCORE=3
        RECOMMENDATION="Plusieurs mises à jour en attente."
    elif [[ $UPDATE_COUNT -le 30 ]]; then
        SCORE=2
        RECOMMENDATION="Nombreuses mises à jour non appliquées."
    else
        SCORE=1
        RECOMMENDATION="Système potentiellement vulnérable, appliquer les mises à jour urgemment."
    fi
fi

# --- Génération du JSON final ---
OUTPUT_JSON=$(jq -n \
    --arg status "OK" \
    --arg error "" \
    --argjson score "$SCORE" \
    --arg recommendation "$RECOMMENDATION" \
    '{status: $status, error: $error, score: $score, recommendation: $recommendation}')

log_info "[majChecker] Vérification terminée avec un score de $SCORE/5"
echo "$OUTPUT_JSON"
