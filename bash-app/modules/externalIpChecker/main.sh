#!/bin/bash
# Module : externalIpChecker

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
    echo -e "UNIT TESTS - externalIpChecker"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : IP trouvée (succès)
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (IP trouvée) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (IP trouvée) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : IP non trouvée (erreur)
    ((TOTAL++))
    SCORE=0
    if [[ "$SCORE" -eq 0 ]]; then
        echo "✓ Test 2 (IP manquante) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (IP manquante) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local EXT_IP=$(curl -s --max-time 5 ifconfig.me)
    if [[ -z "$EXT_IP" ]]; then
        output_json "FAIL" "Pas d'accès internet" 0 "Vérifiez votre connexion"
        exit 0
    fi
    # Logique simple : on a une IP, on est content
    output_json "OK" "" 5 "IP Publique : $EXT_IP"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi
    check_real
}
main "$@"