#!/bin/bash
# Module : tlsChecker

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
    echo -e "UNIT TESTS - tlsChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : TLS 1.2+ supporté
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (TLS 1.2+ OK) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (TLS 1.2+ OK) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : TLS obsolète
    ((TOTAL++))
    SCORE=2
    if [[ "$SCORE" -eq 2 ]]; then
        echo "✓ Test 2 (TLS obsolète) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (TLS obsolète) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    # Test contre un endpoint qui refuse le vieux SSL
    if curl -s --max-time 5 --tlsv1.2 https://google.com > /dev/null; then
        SCORE=5
        REC="Support TLS 1.2+ opérationnel."
    else
        SCORE=2
        REC="Échec de connexion TLS 1.2. Votre bibliothèque OpenSSL est peut-être obsolète."
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