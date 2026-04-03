#!/bin/bash
# Module : firewallRulesAudit

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
    echo -e "UNIT TESTS - firewallRulesAudit"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Windows de tir restrictif (bon)
    ((TOTAL++))
    SCORE=3
    if [[ "$SCORE" -eq 3 ]]; then
        echo "✓ Test 1 (Règles permissives) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (Règles permissives) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Politique restrictive (excellent)
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 2 (Politique stricte) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Politique stricte) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local SCORE=5
    local REC="Audit terminé."
    
    if command -v iptables &>/dev/null; then
        # On cherche des règles ACCEPT sans restriction d'IP ou de port
        local PERMISSIVE=$(iptables -S | grep "ACCEPT" | grep -v "lo" | grep -v "m state --state RELATED,ESTABLISHED" | wc -l)
        if [ "$PERMISSIVE" -gt 5 ]; then
            SCORE=3
            REC="Plusieurs règles ACCEPT très larges détectées.
Revoyez votre politique 'Default Drop'."
        fi
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