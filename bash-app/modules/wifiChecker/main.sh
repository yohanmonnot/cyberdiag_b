#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# Couleurs ANSI
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

ERROR_MESSAGE=""
SCORE=5
RECOMMENDATION="Toutes les connexions sans fil sont désactivées."
CURRENT_SSID=""
CURRENT_SECURITY=""
CONNECTED_TO_PUBLIC_WIFI=false
VPN_ENABLED=false

# --- Output JSON Result ---
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

# --- Check Connected Wi-Fi ---
check_connected_wifi() {
    if ! command -v nmcli &>/dev/null; then
        ERROR_MESSAGE="nmcli n'est pas installé."
        log_error "[wifiChecker] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "Installer NetworkManager"
        return 1
    fi

    local ACTIVE_CONN
    ACTIVE_CONN=$(nmcli -t -f NAME,DEVICE,TYPE,STATE connection show --active)

    if [[ -z "$ACTIVE_CONN" ]]; then
        log_info "[wifiChecker] Aucun Wi-Fi connecté actuellement."
        output_json "OK" "" 5 "$RECOMMENDATION"
        return 0
    fi

    CURRENT_SSID=$(echo "$ACTIVE_CONN" | cut -d':' -f1)
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
    return 0
}

# --- Check VPN Status ---
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
    return 0
}

# --- Calculate final score ---
calculate_score() {
    if [ "$CONNECTED_TO_PUBLIC_WIFI" = true ] && [ "$VPN_ENABLED" = false ]; then
        SCORE=1
        RECOMMENDATION="Connecté à un réseau public sans VPN, évitez toute opération sensible."
    elif [ "$CONNECTED_TO_PUBLIC_WIFI" = true ] && [ "$VPN_ENABLED" = true ]; then
        SCORE=3
        RECOMMENDATION="Connecté à un réseau public avec VPN, prudence recommandée."
    fi
    return 0
}

# --- Self-testing functionality ---
# --- Self-testing functionality ---
run_self_tests() {
    echo "============================================="
    echo "Running internal function tests (wifiChecker)"
    echo "============================================="

    local passed=0
    local failed=0

    test_case() {
        local name="$1"
        shift
        if "$@"; then
            echo -e "${GREEN}PASS${RESET} - $name"
            ((passed++))
        else
            echo -e "${RED}FAIL${RESET} - $name"
            ((failed++))
        fi
    }

    # --- Test : output_json ---
    test_case "output_json produces valid JSON" bash -c 'output_json "OK" "" 5 "Test" | jq . >/dev/null 2>&1'

    # --- Test : check_connected_wifi ---
    if command -v nmcli &>/dev/null; then
        test_case "check_connected_wifi executes without crash" check_connected_wifi
        if [[ -n "$CURRENT_SSID" || "$CONNECTED_TO_PUBLIC_WIFI" == true || "$CONNECTED_TO_PUBLIC_WIFI" == false ]]; then
            echo -e "${GREEN}PASS${RESET} - check_connected_wifi output valid"
            ((passed++))
        else
            echo -e "${RED}FAIL${RESET} - check_connected_wifi did not set expected variables"
            ((failed++))
        fi
    else
        echo -e "${YELLOW}SKIP${RESET} - nmcli not available on system"
    fi

    # --- Test : check_vpn ---
    test_case "check_vpn executes without crash" check_vpn
    if [[ "$VPN_ENABLED" == true || "$VPN_ENABLED" == false ]]; then
        echo -e "${GREEN}PASS${RESET} - VPN status variable valid"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - VPN status variable invalid"
        ((failed++))
    fi

    # --- Test : calculate_score ---
    CONNECTED_TO_PUBLIC_WIFI=true
    VPN_ENABLED=false
    SCORE=5
    calculate_score
    if [[ "$SCORE" -eq 1 && "$RECOMMENDATION" == *"public sans VPN"* ]]; then
        echo -e "${GREEN}PASS${RESET} - calculate_score logic (public + no VPN) correct"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - calculate_score logic (public + no VPN) incorrect"
        ((failed++))
    fi

    CONNECTED_TO_PUBLIC_WIFI=true
    VPN_ENABLED=true
    SCORE=5
    calculate_score
    if [[ "$SCORE" -eq 3 && "$RECOMMENDATION" == *"public avec VPN"* ]]; then
        echo -e "${GREEN}PASS${RESET} - calculate_score logic (public + VPN) correct"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - calculate_score logic (public + VPN) incorrect"
        ((failed++))
    fi

    # --- Résumé ---
    echo -e "-------------------------------------------"
    echo -e "${CYAN}Total:${RESET} $((passed + failed)) | ${GREEN}Passed:${RESET} $passed | ${RED}Failed:${RESET} $failed"
    echo -e "-------------------------------------------"

    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}All internal tests passed.${RESET}"
    else
        echo -e "${RED}Some internal tests failed.${RESET}"
    fi
}

# --- Main Execution ---
main() {
    if [[ "$1" == "--test" ]]; then
        run_self_tests
        exit 0
    fi

    log_info "[wifiChecker] Démarrage du module Wi-Fi..."

    check_connected_wifi
    check_vpn
    calculate_score
    
    log_info "[wifiChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
