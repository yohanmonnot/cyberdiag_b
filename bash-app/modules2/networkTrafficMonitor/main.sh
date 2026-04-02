#!/bin/bash
# Module : networkTrafficMonitor

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local INTERFACE=$(ip route | grep default | awk '{print $5}')
    # On utilise /proc/net/dev pour éviter tcpdump (souvent absent)
    local RX_BEFORE=$(cat /proc/net/dev | grep "$INTERFACE" | awk '{print $2}')
    sleep 5
    local RX_AFTER=$(cat /proc/net/dev | grep "$INTERFACE" | awk '{print $2}')
    
    local DIFF=$(( (RX_AFTER - RX_BEFORE) / 5 )) # Octets par seconde
    
    if [ "$DIFF" -gt 10485760 ]; then # > 10 Mo/s en idle ?
        SCORE=3; REC="Trafic entrant élevé détecté (>10Mo/s). Analyse recommandée."
    else
        SCORE=5; REC="Volume de trafic normal."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"