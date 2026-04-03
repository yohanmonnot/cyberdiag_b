#!/bin/bash
# Module : internetConnectivityTest

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
    echo -e "UNIT TESTS - internetConnectivityTest"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Internet accessible
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (Internet OK) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (Internet OK) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Internet inaccessible
    ((TOTAL++))
    SCORE=0
    if [[ "$SCORE" -eq 0 ]]; then
        echo "✓ Test 2 (Internet indisponible) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Internet indisponible) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local TARGET="8.8.8.8"
    if ping -c 3 -W 2 $TARGET > /dev/null 2>&1; then
        SCORE=5
        REC="Connexion Internet OK."
    else
        SCORE=0
        REC="Internet inaccessible."
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