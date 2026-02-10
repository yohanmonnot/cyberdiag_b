#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Variables globales ---
ERROR_MESSAGE=""
SCORE=5
RECOMMENDATION="Pare-feu activé et bien configuré"

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
            if ! command -v ufw &>/dev/null && ! command -v iptables &>/dev/null; then
                ERROR_MESSAGE="Les outils nécessaires pour vérifier le pare-feu ne sont pas installés."
                log_error "[firewallChecker] $ERROR_MESSAGE"
                output_json "FAIL" "$ERROR_MESSAGE" 0 "Installer un gestionnaire de paquets"
                exit 0
            fi
            ;;
        *)
            ERROR_MESSAGE="Système non pris en charge : $OS"
            log_error "[firewallChecker] $ERROR_MESSAGE"
            output_json "FAIL" "$ERROR_MESSAGE" 0 ""
            exit 0
            ;;
    esac
    log_info "[firewallChecker] Système détecté : $OS"
}

# --- Fonction : vérification du pare-feu ---
check_firewall() {
    if command -v ufw &>/dev/null; then
        FIREWALL_STATUS=$(ufw status 2>/dev/null)
        if [[ "$FIREWALL_STATUS" == *"Status: active"* ]]; then
            log_info "[firewallChecker] Le pare-feu (UFW) est activé."
            FIREWALL_CONFIGURED=$(echo "$FIREWALL_STATUS" | grep -q "Default: deny (incoming), allow (outgoing), disabled (routed)" && echo true || echo false)
            if [ "$FIREWALL_CONFIGURED" = true ]; then
                log_info "[firewallChecker] Le pare-feu est bien configuré."
                SCORE=5
                RECOMMENDATION="Pare-feu activé et bien configuré."
            else
                log_warn "[firewallChecker] Le pare-feu n'est pas bien configuré."
                SCORE=3
                RECOMMENDATION="Pare-feu activé mais mal configuré. Configurez le pare-feu pour bloquer les connexions entrantes non désirées."
            fi
        else
            log_warn "[firewallChecker] Le pare-feu (UFW) n'est pas activé."
            SCORE=2
            RECOMMENDATION="Pare-feu détecté mais non activé. Activez le pare-feu."
        fi
    elif command -v iptables &>/dev/null; then
        FIREWALL_STATUS=$(iptables -L 2>/dev/null)
        if echo "$FIREWALL_STATUS" | grep -q "Policy: DROP"; then
            log_info "[firewallChecker] Le pare-feu (iptables) est activé et configuré pour bloquer les connexions entrantes non désirées."
            SCORE=5
            RECOMMENDATION="Pare-feu activé et bien configuré."
        else
            log_warn "[firewallChecker] Le pare-feu (iptables) n'est pas bien configuré."
            SCORE=3
            RECOMMENDATION="Pare-feu détecté mais mal configuré. Configurez le pare-feu pour bloquer les connexions entrantes non désirées."
        fi
    else
        log_warn "[firewallChecker] Aucun pare-feu détecté."
        SCORE=1
        RECOMMENDATION="Aucun pare-feu détecté. Installez et configurez un pare-feu."
    fi
}

# --- Main ---
main() {
    log_info "[firewallChecker] Démarrage du module de vérification du pare-feu..."
    detect_os
    check_firewall
    log_info "[firewallChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
