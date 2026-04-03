#!/bin/bash
# Module : openPortsScanner
# Description : Scan des ports locaux ouverts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# Couleurs & JSON standard
output_json() {
    echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

analyze_ports() {
    local PORT_COUNT=$1
    SCORE=5
    if [ "$PORT_COUNT" -gt 15 ]; then SCORE=3; RECOMMENDATION="Trop de ports ouverts ($PORT_COUNT). Fermez les services inutiles.";
    elif [ "$PORT_COUNT" -gt 5 ]; then SCORE=4; RECOMMENDATION="Nombre de ports raisonnable ($PORT_COUNT).";
    else RECOMMENDATION="Surface d'exposition minimale."; fi
}

check_real() {
    if ! command -v ss &>/dev/null; then
        output_json "FAIL" "ss (iproute2) manquant" 0 ""; exit 0
    fi
    local PORTS=$(ss -tulpnH | wc -l)
    analyze_ports "$PORTS"
}

main() {
    [[ "$1" == "--test" ]] && { analyze_ports 20; echo "Test Score: $SCORE"; exit 0; }
    check_real
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}
main "$@"