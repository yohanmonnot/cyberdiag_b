#!/bin/bash
# Module : externalIpChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local EXT_IP=$(curl -s --max-time 5 ifconfig.me)
    if [[ -z "$EXT_IP" ]]; then
        echo $(jq -n --arg status "FAIL" --arg error "Pas d'accès internet" --argjson score 0 --arg recommendation "Vérifiez votre connexion" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
        exit 0
    fi
    # Logique simple : on a une IP, on est content
    echo $(jq -n --arg status "OK" --arg error "" --argjson score 5 --arg recommendation "IP Publique : $EXT_IP" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"