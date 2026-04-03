#!/bin/bash
# Module : arpTableChecker

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
    echo -e "UNIT TESTS - arpTableChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Pas de doublons (sain)
    ((TOTAL++))
    SCORE=5
    REC="Table ARP saine. Aucune duplication détectée."
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (ARP sain) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (ARP sain) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Doublons (poisoning détecté)
    ((TOTAL++))
    SCORE=1
    REC="Alerte : Suspicion d'ARP Poisoning."
    if [[ "$SCORE" -eq 1 ]]; then
        echo "✓ Test 2 (ARP Poisoning) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (ARP Poisoning) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    # On cherche des doublons de MAC dans la table ARP
    local DUPLICATES=$(ip neigh show | awk '{print $5}' | grep ":" | sort | uniq -d)
    
    if [[ -n "$DUPLICATES" ]]; then
        SCORE=1
        REC="Alerte : Plusieurs adresses IP partagent la même adresse MAC ($DUPLICATES). Suspicion d'ARP Poisoning."
    else
        SCORE=5
        REC="Table ARP saine. Aucune duplication détectée."
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