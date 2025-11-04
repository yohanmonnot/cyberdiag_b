#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

ERROR_MESSAGE=""
SCORE=5
RECOMMENDATION="Toutes les connexions sans fil sont désactivées."
CURRENT_SSID=""
CURRENT_SECURITY=""
CONNECTED_TO_PUBLIC_WIFI=false
VPN_ENABLED=false

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

check_connected_wifi() {
    if ! command -v nmcli &>/dev/null; then
        ERROR_MESSAGE="nmcli n'est pas installé."
        log_error "[wifiChecker] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "Installer NetworkManager"
        exit 0
    fi

    # Récupère la connexion active (plus fiable)
    local ACTIVE_CONN
    ACTIVE_CONN=$(nmcli -t -f NAME,DEVICE,TYPE,STATE connection show --active)

    if [[ -z "$ACTIVE_CONN" ]]; then
        log_info "[wifiChecker] Aucun Wi-Fi connecté actuellement."
        output_json "OK" "" 5 "$RECOMMENDATION"
        exit 0
    fi

    CURRENT_SSID=$(echo "$ACTIVE_CONN" | cut -d':' -f1)
    # Sécurité : récupérer via nmcli dev wifi list et filtrer par SSID
    CURRENT_SECURITY=$(nmcli -t -f SSID,SECURITY dev wifi list | grep "^$CURRENT_SSID:" | cut -d':' -f2)
    log_info "[wifiChecker] Wi-Fi connecté : $CURRENT_SSID"
    log_info "[wifiChecker] Type de sécurité : ${CURRENT_SECURITY:-Inconnu}"

    if [[ -z "$CURRENT_SECURITY" || "$CURRENT_SECURITY" == "--" || "$CURRENT_SECURITY" == *WEP* ]]; then
        CONNECTED_TO_PUBLIC_WIFI=true
        SCORE=2
        RECOMMENDATION="Connecté à un Wi-Fi public ou non sécurisé. Évitez les opérations sensibles et utilisez un VPN si possible."
    else
        CONNECTED_TO_PUBLIC_WIFI=false
        SCORE=5
        RECOMMENDATION="Réseau Wi-Fi sécurisé. Continuez à suivre les bonnes pratiques ANSSI."
    fi
}

check_vpn() {
    if command -v nmcli &>/dev/null; then
        if nmcli connection show --active | grep -qi "vpn"; then
            VPN_ENABLED=true
            log_info "[wifiChecker] VPN actif."
        else
            VPN_ENABLED=false
            log_info "[wifiChecker] VPN inactif."
        fi
    fi
}

calculate_score() {
    if [ "$CONNECTED_TO_PUBLIC_WIFI" = true ] && [ "$VPN_ENABLED" = false ]; then
        SCORE=1
        RECOMMENDATION="Connecté à un réseau public sans VPN, évitez toute opération sensible."
    elif [ "$CONNECTED_TO_PUBLIC_WIFI" = true ] && [ "$VPN_ENABLED" = true ]; then
        SCORE=3
        RECOMMENDATION="Connecté à un réseau public avec VPN, prudence recommandée."
    fi
}

main() {
    log_info "[wifiChecker] Démarrage du module Wi-Fi..."
    check_connected_wifi
    check_vpn
    calculate_score
    log_info "[wifiChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
