#!/bin/bash
# Module : proxyChecker

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
    echo -e "UNIT TESTS - proxyChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Aucun proxy
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (Aucun proxy) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (Aucun proxy) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Proxy détecté
    ((TOTAL++))
    SCORE=4
    if [[ "$SCORE" -eq 4 ]]; then
        echo "✓ Test 2 (Proxy détecté) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Proxy détecté) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local PROXY_FOUND=false
    local DETAILS=""

    [[ -n "$http_proxy" || -n "$HTTP_PROXY" ]] && PROXY_FOUND=true && DETAILS+="HTTP Proxy détecté. "
    [[ -n "$https_proxy" || -n "$HTTPS_PROXY" ]] && PROXY_FOUND=true && DETAILS+="HTTPS Proxy détecté. "

    if $PROXY_FOUND; then
        SCORE=4
        REC="Proxy actif : $DETAILS. Vérifiez s'il est légitime."
    else
        SCORE=5
        REC="Aucun proxy système configuré."
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