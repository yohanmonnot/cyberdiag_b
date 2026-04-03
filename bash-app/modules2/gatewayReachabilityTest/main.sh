#!/bin/bash
# Module : gatewayReachabilityTest

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local GW_IP=$(ip route | grep default | awk '{print $3}')
    
    if [[ -z "$GW_IP" ]]; then
        echo $(jq -n --arg status "FAIL" --arg error "Pas de Gateway" --argjson score 0 --arg recommendation "" '{status: "FAIL", error: "Pas de route par défaut", score: 0, recommendation: "Vérifiez votre configuration IP"}')
        exit 0
    fi

    if ping -c 2 -W 1 "$GW_IP" > /dev/null; then
        SCORE=5
        REC="Passerelle ($GW_IP) joignable."
    else
        SCORE=1
        REC="Passerelle ($GW_IP) ne répond pas au ping. Risque de coupure réseau ou isolation."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"