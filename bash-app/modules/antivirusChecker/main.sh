#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Variables globales ---
ERROR_MESSAGE=""
SCORE=5
RECOMMENDATION="Antivirus à jour et fonctionnel"

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
            if ! command -v apt &>/dev/null && ! command -v dnf &>/dev/null && ! command -v yum &>/dev/null && ! command -v pacman &>/dev/null && ! command -v zypper &>/dev/null; then
                ERROR_MESSAGE="Les outils nécessaires pour vérifier l'antivirus ne sont pas installés."
                log_error "[antivirusChecker] $ERROR_MESSAGE"
                output_json "FAIL" "$ERROR_MESSAGE" 0 "Installer un gestionnaire de paquets"
                exit 0
            fi
            ;;
        *)
            ERROR_MESSAGE="Système non pris en charge : $OS"
            log_error "[antivirusChecker] $ERROR_MESSAGE"
            output_json "FAIL" "$ERROR_MESSAGE" 0 ""
            exit 0
            ;;
    esac
    log_info "[antivirusChecker] Système détecté : $OS"
}

# --- Fonction : vérification de l'antivirus ---
check_antivirus() {
    # Vérifier si un antivirus est installé
    if command -v clamscan &>/dev/null; then
        log_info "[antivirusChecker] Antivirus (ClamAV) est installé."

        # Vérifier si les bases virales sont à jour
        if command -v freshclam &>/dev/null; then
            if freshclam --version &>/dev/null; then
                log_info "[antivirusChecker] Les bases virales de ClamAV sont à jour."
                SCORE=5
                RECOMMENDATION="Antivirus à jour et fonctionnel."
            else
                log_warn "[antivirusChecker] Les bases virales de ClamAV ne sont pas à jour."
                SCORE=2
                RECOMMENDATION="Antivirus installé mais les bases virales ne sont pas à jour. Mettez à jour les bases virales."
            fi
        else
            log_warn "[antivirusChecker] Impossible de vérifier les mises à jour des bases virales de ClamAV."
            SCORE=3
            RECOMMENDATION="Antivirus installé mais impossible de vérifier les mises à jour des bases virales."
        fi
    else
        log_warn "[antivirusChecker] Aucun antivirus détecté."
        SCORE=1
        RECOMMENDATION="Aucun antivirus détecté. Installez un antivirus et mettez à jour ses bases virales."
    fi
}

# --- Main ---
main() {
    log_info "[antivirusChecker] Démarrage du module de vérification de l'antivirus..."
    detect_os
    check_antivirus
    log_info "[antivirusChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
