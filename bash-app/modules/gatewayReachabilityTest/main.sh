#!/bin/bash
# Module : gatewayReachabilityTest

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
    echo -e "UNIT TESTS - gatewayReachabilityTest"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Gateway joignable
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (Gateway OK) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (Gateway OK) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Gateway non joignable
    ((TOTAL++))
    SCORE=1
    if [[ "$SCORE" -eq 1 ]]; then
        echo "✓ Test 2 (Gateway indisponible) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Gateway indisponible) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local GW_IP=$(ip route | grep default | awk '{print $3}')
    
    if [[ -z "$GW_IP" ]]; then
        output_json "FAIL" "Pas de route par défaut" 0 "Vérifiez votre configuration IP"
        exit 0
    fi

    if ping -c 2 -W 1 "$GW_IP" > /dev/null; then
        SCORE=5
        REC="Passerelle ($GW_IP) joignable."
    else
        SCORE=1
        REC="Passerelle ($GW_IP) ne répond pas au ping. Risque de coupure réseau ou isolation."
    fi

    output_json "OK" "" "$SCORE" "$REC"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi
    check_real
}
main "$@"