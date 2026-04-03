#!/bin/bash
# Module : tlsChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    # Test contre un endpoint qui refuse le vieux SSL
    if curl -s --max-time 5 --tlsv1.2 https://google.com > /dev/null; then
        SCORE=5
        REC="Support TLS 1.2+ opérationnel."
    else
        SCORE=2
        REC="Échec de connexion TLS 1.2. Votre bibliothèque OpenSSL est peut-être obsolète."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"