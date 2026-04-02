#!/bin/bash
# Module : vpnChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

evaluate_vpn() {
    local TUNNEL_EXISTS=$1
    if $TUNNEL_EXISTS; then
        SCORE=5; RECOMMENDATION="VPN/Tunnel actif (Sécurisé)."
    else
        SCORE=3; RECOMMENDATION="Aucun VPN détecté. Trafic potentiellement exposé sur réseau public."
    fi
}

check_real() {
    local TUNNEL=false
    if ip addr | grep -E "tun|tap|wg|ppp" >/dev/null; then TUNNEL=true; fi
    evaluate_vpn "$TUNNEL"
}

main() {
    [[ "$1" == "--test" ]] && { evaluate_vpn true; echo "Score: $SCORE"; exit 0; }
    check_real
    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}
main "$@"