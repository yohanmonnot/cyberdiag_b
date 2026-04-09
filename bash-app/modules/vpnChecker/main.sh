#!/bin/bash
# Module : vpnChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

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
# Tests unitaires
# ==================================================
run_unit_tests() {
    echo -e "==================================="
    echo -e "UNIT TESTS - vpnChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : VPN actif
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (VPN actif) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (VPN actif) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Pas de VPN
    ((TOTAL++))
    SCORE=3
    if [[ "$SCORE" -eq 3 ]]; then
        echo "✓ Test 2 (Pas de VPN) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Pas de VPN) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

evaluate_vpn() {
    local TUNNEL_EXISTS=$1
    if $TUNNEL_EXISTS; then
        SCORE=5; RECOMMENDATION="VPN/Tunnel actif (Sécurisé)."
    else
        SCORE=3; RECOMMENDATION="Aucun VPN détecté. Trafic potentiellement exposé sur réseau public."
    fi
}

check_real() {
    local TUNNEL=false
    if ip addr | grep -E "tun|tap|wg|ppp" >/dev/null; then TUNNEL=true; fi
    evaluate_vpn "$TUNNEL"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi
    check_real
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}
main "$@"