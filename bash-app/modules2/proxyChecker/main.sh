#!/bin/bash
# Module : proxyChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

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

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"