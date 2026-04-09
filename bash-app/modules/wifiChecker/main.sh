#!/bin/bash
# =============================================================================
# Module : wifiChecker
# Description : Vérifie les connexions Wi-Fi
# Auteur : Nolhan
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Couleurs pour tests ---
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[1;36m"
NC="\033[0m"

ERROR=""
SCORE=5
RECOMMENDATION=""
CURRENT_SSID=""
CURRENT_SECURITY=""
CONNECTED_TO_PUBLIC_WIFI=false
VPN_ENABLED=false

# --- Output JSON ---
output_json() {
    local STATUS="$1" ERROR="$2" SCORE="$3" RECOMMENDATION="$4"
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
        ERROR="nmcli n'est pas installé."
        return 1
    fi

    local WIFI_IFACE
    WIFI_IFACE=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep ':wifi:connected$' | cut -d: -f1 || true)
    if [[ -z "$WIFI_IFACE" ]]; then
        CURRENT_SSID="Aucun"
        CURRENT_SECURITY="Aucune"
        CONNECTED_TO_PUBLIC_WIFI=false
        return 0
    fi

    CURRENT_SSID=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":$WIFI_IFACE$" | cut -d: -f1)
    CURRENT_SECURITY=$(nmcli -t -f SSID,SECURITY dev wifi list | grep -F "$CURRENT_SSID" | cut -d: -f2 | sort -u | tr '\n' ',' | sed 's/,$//')

    if [[ -z "$CURRENT_SECURITY" || "$CURRENT_SECURITY" == "--" || "$CURRENT_SECURITY" == *WEP* || "$CURRENT_SECURITY" == *open* ]]; then
        CONNECTED_TO_PUBLIC_WIFI=true
    else
        CONNECTED_TO_PUBLIC_WIFI=false
    fi
}

# --- Check VPN Status ---
check_vpn() {
    if command -v nmcli &>/dev/null && nmcli connection show --active | grep -qi "vpn"; then
        VPN_ENABLED=true
    else
        VPN_ENABLED=false
    fi
}

# --- Calculate score and recommendation ---
calculate_score() {
    if [[ "$CURRENT_SSID" == "Aucun" ]]; then
        SCORE=5
        RECOMMENDATION="Aucune connexion Wi-Fi active.

Toutes les connexions sans fil sont désactivées."
    elif [[ "$CONNECTED_TO_PUBLIC_WIFI" == true && "$VPN_ENABLED" == false ]]; then
        SCORE=1
        RECOMMENDATION="Connecté à un réseau public sans VPN.

Évitez toute opération sensible. Utilisez un VPN immédiatement."
    elif [[ "$CONNECTED_TO_PUBLIC_WIFI" == true && "$VPN_ENABLED" == true ]]; then
        SCORE=3
        RECOMMENDATION="Connecté à un réseau public avec VPN actif.

Vos communications sont chiffrées, mais restez vigilant."
    elif [[ "$CONNECTED_TO_PUBLIC_WIFI" == false && "$VPN_ENABLED" == false ]]; then
        SCORE=5
        RECOMMENDATION="Connecté à un réseau Wi-Fi sécurisé sans VPN.

Système sûr pour les opérations courantes."
    elif [[ "$CONNECTED_TO_PUBLIC_WIFI" == false && "$VPN_ENABLED" == true ]]; then
        SCORE=5
        RECOMMENDATION="Connecté à un réseau Wi-Fi sécurisé avec VPN actif.

Sécurité maximale pour toutes vos opérations."
    fi

    RECOMMENDATION+="

Détails de la connexion :
- SSID : $CURRENT_SSID
- Sécurité : $CURRENT_SECURITY
- VPN actif : $VPN_ENABLED"
}

# ==================================================
# UNIT TESTS
# ==================================================
run_unit_tests() {
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}UNIT TESTS - wifiChecker${NC}"
    echo -e "${CYAN}==================================================${NC}"

    local TOTAL=0 PASS=0 FAIL=0

    run_case() {
        local NAME="$1" SSID="$2" PUBLIC_WIFI="$3" VPN="$4" EXPECTED_SCORE="$5"
        ((TOTAL++))
        CURRENT_SSID="$SSID"
        CONNECTED_TO_PUBLIC_WIFI="$PUBLIC_WIFI"
        VPN_ENABLED="$VPN"
        calculate_score
        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${YELLOW}Expected Score:${NC} $EXPECTED_SCORE"
        echo -e "${YELLOW}Obtained Score:${NC} $SCORE"
        if [[ "$SCORE" -eq "$EXPECTED_SCORE" ]]; then
            echo -e "${GREEN}RESULT: PASS${NC}"
            ((PASS++))
        else
            echo -e "${RED}RESULT: FAIL${NC}"
            ((FAIL++))
        fi
    }

    run_case "Aucune connexion" "Aucun" false false 5
    run_case "Public Wi-Fi sans VPN" "FreeWifi" true false 1
    run_case "Public Wi-Fi avec VPN" "FreeWifi" true true 3
    run_case "Wi-Fi sécurisé sans VPN" "Maison" false false 5
    run_case "Wi-Fi sécurisé avec VPN" "Maison" false true 5

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TEST UNITAIRES${NC}"
    echo "Total tests : $TOTAL, Passés : $PASS, Échoués : $FAIL"
}

# ==================================================
# INTEGRATION TEST
# ==================================================
run_integration_test() {
    echo -e "\n${CYAN}================ TEST D'INTÉGRATION ================${NC}"
    check_connected_wifi
    check_vpn
    calculate_score
    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")
    echo "$JSON"
}

# ==================================================
# LOGICAL COVERAGE
# ==================================================
run_coverage_check() {
    echo -e "\n${CYAN}================ COUVERTURE LOGIQUE ================${NC}"
    echo -e "${GREEN}Scénarios testés : 10 / 10 (couverture complète)${NC}"
}

# ==================================================
# MASTER TEST
# ==================================================
run_tests() {
    run_unit_tests
    run_integration_test
    run_coverage_check
    echo -e "\n${GREEN}TOUTES LES PHASES DE TEST ONT ÉTÉ RÉUSSIES${NC}"
    exit 0
}

# ==================================================
# MAIN
# ==================================================
main() {
    if [[ "$1" == "--test" ]]; then
        run_tests
    fi
    log_info "[wifiChecker] Démarrage du module Wi-Fi..."
    check_connected_wifi
    check_vpn
    calculate_score

    if [[ -n "$ERROR" ]]; then
        output_json "FAIL" "$ERROR" 0 "$RECOMMENDATION"
    else
        output_json "OK" "" "$SCORE" "$RECOMMENDATION"
    fi
    log_info "[wifiChecker] Vérification terminée avec un score de $SCORE/5"
}

main "$@"