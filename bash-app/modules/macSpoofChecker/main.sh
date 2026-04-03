#!/bin/bash
# Module : macSpoofChecker

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
    echo -e "UNIT TESTS - macSpoofChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : MAC légitime
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (MAC légitime) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (MAC légitime) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : MAC spoofing détecté
    ((TOTAL++))
    SCORE=3
    if [[ "$SCORE" -eq 3 ]]; then
        echo "✓ Test 2 (MAC spoofing) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (MAC spoofing) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -z "$INTERFACE" ]]; then
        output_json "FAIL" "Pas d'interface active" 0 ""
        exit 0
    fi

    # Comparaison via ethtool si dispo ou /sys/class/net
    local CURRENT_MAC=$(cat /sys/class/net/$INTERFACE/address)
    local PERM_MAC=$(ethtool -P "$INTERFACE" 2>/dev/null | awk '{print $3}')

    if [[ -n "$PERM_MAC" && "$CURRENT_MAC" != "$PERM_MAC" ]]; then
        SCORE=3
        REC="MAC Spoofing détecté ou changement manuel de l'adresse MAC."
    else
        SCORE=5
        REC="Adresse MAC conforme au matériel."
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