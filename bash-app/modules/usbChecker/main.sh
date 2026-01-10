#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Variables globales ---
ERROR_MESSAGE=""
SCORE=5
RECOMMENDATION="Aucun équipement USB inconnu détecté"

# --- Fonction : sortie JSON ---
output_json() {
    local STATUS="$1"
    local ERROR="$2"
    local SCORE="$3"
    local RECOMMENDATION="$4"
    echo $(jq -n \
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

# --- Fonction : détection OS ---
detect_os() {
    local OS
    OS="$(uname -s)"
    case "$OS" in
        "Linux")
            # Vérifier si les outils nécessaires sont disponibles
            if ! command -v lsusb &>/dev/null; then
                ERROR_MESSAGE="Les outils nécessaires pour vérifier les équipements USB ne sont pas installés."
                log_error "[usbChecker] $ERROR_MESSAGE"
                output_json "FAIL" "$ERROR_MESSAGE" 0 "Installer les outils nécessaires"
                exit 0
            fi
            ;;
        *)
            ERROR_MESSAGE="Système non pris en charge : $OS"
            log_error "[usbChecker] $ERROR_MESSAGE"
            output_json "FAIL" "$ERROR_MESSAGE" 0 ""
            exit 0
            ;;
    esac
    log_info "[usbChecker] Système détecté : $OS"
}

# --- Fonction : vérification des équipements USB ---
check_usb() {
    if lsusb 2>/dev/null | grep -q "Unknown"; then
        log_warn "[usbChecker] Équipements USB inconnus détectés."
        SCORE=3
        RECOMMENDATION="Équipements USB inconnus détectés. Évitez d'utiliser des équipements inconnus ou abandonnés."
    else
        log_info "[usbChecker] Aucun équipement USB inconnu détecté."
        SCORE=5
        RECOMMENDATION="Aucun équipement USB inconnu détecté."
    fi
}

# --- Main ---
main() {
    log_info "[usbChecker] Démarrage du module de vérification des équipements USB..."
    detect_os
    check_usb
    log_info "[usbChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
