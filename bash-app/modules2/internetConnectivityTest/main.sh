#!/bin/bash
# Module : internetConnectivityTest

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local TARGET="8.8.8.8"
    if ping -c 3 -W 2 $TARGET > /dev/null 2>&1; then
        SCORE=5; REC="Connexion Internet OK."
    else
        SCORE=0; REC="Internet inaccessible."
    fi
    
    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"