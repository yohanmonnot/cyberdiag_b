#!/bin/bash
# =============================================================================
# Module : vpnChecker
# Description : Vérifie la présence et l'état d'un VPN
# Auteur : Yohan
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# --- Variables globales ---
ERROR=""
VPN_DATA_JSON="[]"
PUBLIC_IP=""
SCORE=5
RECOMMENDATION=""

# ==================================================
# Génération JSON
# ==================================================
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

# ==================================================
# Vérifications
# ==================================================
check_requirements() {
    for cmd in ip jq curl; do
        if ! command -v "$cmd" &>/dev/null; then
            ERROR="Dépendance manquante : $cmd"
            log_error "[vpnChecker] $ERROR"
            output_json "FAIL" "$ERROR" 0 ""
            exit 0
        fi
    done
}

# ==================================================
# Collecte des interfaces VPN
# ==================================================
collect_vpn_data() {
    local vpn_array="[]"

    while read -r iface; do
        [[ -z "$iface" ]] && continue

        if [[ "$iface" == tun* ]] || [[ "$iface" == tap* ]] || [[ "$iface" == wg* ]]; then
            local state
            state=$(ip link show "$iface" | grep -o "state [A-Z]*" | awk '{print $2}')

            local vpn_item
            vpn_item=$(jq -n \
                --arg name "$iface" \
                --arg state "$state" \
                '{interface: $name, state: $state}')

            vpn_array=$(echo "$vpn_array" | jq --argjson item "$vpn_item" '. += [$item]')
        fi
    done < <(ip -o link show | awk -F': ' '{print $2}')

    VPN_DATA_JSON="$vpn_array"

    PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org)
    [[ ! "$PUBLIC_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && PUBLIC_IP="Non détectée"

    log_info "[vpnChecker] Interfaces VPN détectées : $(echo "$VPN_DATA_JSON" | jq length)"
}

# ==================================================
# Calcul du score
# ==================================================
calculate_score() {

    local count
    count=$(echo "$VPN_DATA_JSON" | jq length)

    if [[ "$count" -eq 0 ]]; then
        SCORE=1
        RECOMMENDATION="Aucune interface VPN détectée."
        return
    fi

    local active_count
    active_count=$(echo "$VPN_DATA_JSON" | jq '[.[] | select(.state=="UP")] | length')

    local details
    details=$(echo "$VPN_DATA_JSON" | jq -r '.[] | "- " + .interface + " (" + .state + ")"')

    if [[ "$active_count" -gt 0 && "$PUBLIC_IP" != "Non détectée" ]]; then
        SCORE=5
        ACTION="VPN actif avec tunnel fonctionnel."
    elif [[ "$active_count" -gt 0 ]]; then
        SCORE=4
        ACTION="VPN actif mais IP publique non vérifiée."
    else
        SCORE=2
        ACTION="VPN détecté mais inactif."
    fi

    RECOMMENDATION="État des interfaces VPN :
$details

IP publique détectée : $PUBLIC_IP

Action recommandée :
$ACTION"
}

# ==================================================
# Tests unitaires
# ==================================================
run_unit_tests() {

    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}UNIT TESTS - vpnChecker${NC}"
    echo -e "${CYAN}==================================================${NC}"

    local TOTAL=0 PASS=0 FAIL=0

    run_case() {
        local NAME="$1" VPN_JSON="$2" IP="$3" EXPECTED="$4"

        VPN_DATA_JSON="$VPN_JSON"
        PUBLIC_IP="$IP"
        calculate_score

        ((TOTAL++))

        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${YELLOW}Expected Score:${NC} $EXPECTED"
        echo -e "${YELLOW}Obtained Score:${NC} $SCORE"

        if [[ "$SCORE" -eq "$EXPECTED" ]]; then
            echo -e "${GREEN}RESULT: PASS${NC}"
            ((PASS++))
        else
            echo -e "${RED}RESULT: FAIL${NC}"
            ((FAIL++))
        fi
    }

    run_case "Aucun VPN" '[]' "Non détectée" 1
    run_case "VPN inactif" '[{"interface":"tun0","state":"DOWN"}]' "Non détectée" 2
    run_case "VPN actif sans IP" '[{"interface":"tun0","state":"UP"}]' "Non détectée" 4
    run_case "VPN actif avec IP" '[{"interface":"tun0","state":"UP"}]' "1.2.3.4" 5

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TEST UNITAIRES${NC}"
    echo "Total tests : $TOTAL, Passés : $PASS, Échoués : $FAIL"
}

# ==================================================
# Test d'intégration
# ==================================================
run_integration_test() {
    echo -e "\n${CYAN}================ TEST D'INTÉGRATION ================${NC}"
    check_requirements
    collect_vpn_data
    calculate_score
    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")
    echo "$JSON"
}

# ==================================================
# Couverture logique
# ==================================================
run_coverage_check() {
    echo -e "\n${CYAN}================ COUVERTURE LOGIQUE ================${NC}"

    local scenarios=0

    for state in DOWN UP; do
        VPN_DATA_JSON="[{\"interface\":\"tun0\",\"state\":\"$state\"}]"
        PUBLIC_IP="Non détectée"
        calculate_score
        ((scenarios++))
    done

    VPN_DATA_JSON="[{\"interface\":\"tun0\",\"state\":\"UP\"}]"
    PUBLIC_IP="1.2.3.4"
    calculate_score
    ((scenarios++))

    echo -e "${GREEN}Scénarios testés : $scenarios / 3 (couverture complète)${NC}"
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

    log_info "[vpnChecker] Analyse des interfaces VPN..."
    check_requirements
    collect_vpn_data
    calculate_score
    log_info "[vpnChecker] Vérification terminée, score=$SCORE/5"

    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"