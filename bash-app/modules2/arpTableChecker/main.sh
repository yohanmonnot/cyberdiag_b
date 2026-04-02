#!/bin/bash
# Module : arpTableChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    # On cherche des doublons de MAC dans la table ARP
    local DUPLICATES=$(ip neigh show | awk '{print $5}' | grep ":" | sort | uniq -d)
    
    if [[ -n "$DUPLICATES" ]]; then
        SCORE=1
        REC="Alerte : Plusieurs adresses IP partagent la même adresse MAC ($DUPLICATES). Suspicion d'ARP Poisoning."
    else
        SCORE=5
        REC="Table ARP saine. Aucune duplication détectée."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"