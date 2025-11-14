#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Variables globales ---
PACKAGE_MANAGER=""
NEEDS_SUDO=false
ERROR_MESSAGE=""
UPDATE_COUNT=0
SCORE=5
RECOMMENDATION="Système à jour"

# --- Fonction : sortie JSON ---
output_json() {
    local STATUS="$1"
    local ERROR="$2"
    local SCORE="$3"
    local RECOMMENDATION="$4"
    local UPDATES="$5"
    echo $(jq -n \
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        --argjson updates "$UPDATES" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation, updates: $updates}')
}

# --- Fonction : détection OS et package manager ---
detect_os_and_package_manager() {
    local OS
    OS="$(uname -s)"
    case "$OS" in
        "Linux")
            if command -v apt &>/dev/null; then
                PACKAGE_MANAGER="apt"
                NEEDS_SUDO=false
            elif command -v dnf &>/dev/null; then
                PACKAGE_MANAGER="dnf"
                NEEDS_SUDO=true
            elif command -v yum &>/dev/null; then
                PACKAGE_MANAGER="yum"
                NEEDS_SUDO=true
            elif command -v pacman &>/dev/null; then
                PACKAGE_MANAGER="pacman"
                NEEDS_SUDO=false
            elif command -v zypper &>/dev/null; then
                PACKAGE_MANAGER="zypper"
                NEEDS_SUDO=true
            else
                ERROR_MESSAGE="Aucun gestionnaire de paquets compatible détecté."
            fi
            ;;
        *)
            ERROR_MESSAGE="Système non pris en charge : $OS"
            ;;
    esac

    if [[ -n "$ERROR_MESSAGE" ]]; then
        log_error "[majChecker] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" 0
        exit 0
    fi

    log_info "[majChecker] Gestionnaire détecté : $PACKAGE_MANAGER"
}

# --- Fonction : vérification dépendances sudo ---
check_requirements() {
    if $NEEDS_SUDO && ! command -v sudo &>/dev/null; then
        ERROR_MESSAGE="sudo est requis mais non disponible."
        log_error "[majChecker] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" 0
        exit 0
    fi
}

# --- Fonction : vérifier les mises à jour ---
check_updates() {
    case "$PACKAGE_MANAGER" in
        apt)
            # Mise à jour des listes
            $($NEEDS_SUDO && echo sudo) apt update -qq
            # Comptage des paquets upgradable
            UPDATE_COUNT=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
            ;;
        dnf)
            UPDATE_COUNT=$(dnf check-update --refresh | grep -c '^[a-zA-Z0-9]' || true)
            ;;
        yum)
            UPDATE_COUNT=$(yum check-update | grep -c '^[a-zA-Z0-9]' || true)
            ;;
        pacman)
            UPDATE_COUNT=$(checkupdates 2>/dev/null | wc -l || true)
            ;;
        zypper)
            UPDATE_COUNT=$(zypper lu | grep -c '^v ' || true)
            ;;
    esac

    if [[ -z "$UPDATE_COUNT" ]]; then
        UPDATE_COUNT=0
    fi
    log_info "[majChecker] Nombre de mises à jour disponibles : $UPDATE_COUNT"
}

# --- Fonction : calcul du score et recommandation ---
calculate_score() {
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
}

# --- Main ---
main() {
    log_info "[majChecker] Démarrage du module de vérification des mises à jour..."
    detect_os_and_package_manager
    check_requirements
    check_updates
    calculate_score
    log_info "[majChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION" "$UPDATE_COUNT"
}

main "$@"
