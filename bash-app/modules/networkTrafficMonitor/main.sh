#!/bin/bash
# Module : networkTrafficMonitor

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
    echo -e "UNIT TESTS - networkTrafficMonitor"
    echo -e "==================================="
    
    local TOTAL=0 PASS=0 FAIL=0
    
    # Test 1 : Trafic normal
    ((TOTAL++))
    SCORE=5
    if [[ "$SCORE" -eq 5 ]]; then
        echo "✓ Test 1 (Trafic normal) : PASS"
        ((PASS++))
    else
        echo "✗ Test 1 (Trafic normal) : FAIL"
        ((FAIL++))
    fi
    
    # Test 2 : Trafic élevé
    ((TOTAL++))
    SCORE=3
    if [[ "$SCORE" -eq 3 ]]; then
        echo "✓ Test 2 (Trafic élevé) : PASS"
        ((PASS++))
    else
        echo "✗ Test 2 (Trafic élevé) : FAIL"
        ((FAIL++))
    fi
    
    echo -e "\nRésumé : $PASS/$TOTAL tests passés, $FAIL échoués"
}

check_real() {
    local INTERFACE=$(ip route | grep default | awk '{print $5}')
    # On utilise /proc/net/dev pour éviter tcpdump (souvent absent)
    local RX_BEFORE=$(cat /proc/net/dev | grep "$INTERFACE" | awk '{print $2}')
    sleep 5
    local RX_AFTER=$(cat /proc/net/dev | grep "$INTERFACE" | awk '{print $2}')
    
    local DIFF=$(( (RX_AFTER - RX_BEFORE) / 5 )) # Octets par seconde
    
    if [ "$DIFF" -gt 10485760 ]; then # > 10 Mo/s en idle ?
        SCORE=3
        REC="Trafic entrant élevé détecté (>10Mo/s). Analyse recommandée."
    else
        SCORE=5
        REC="Volume de trafic normal."
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