#!/bin/bash
# Module : firewallRulesAudit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local SCORE=5
    local REC="Audit terminé."
    
    if command -v iptables &>/dev/null; then
        # On cherche des règles ACCEPT sans restriction d'IP ou de port
        local PERMISSIVE=$(iptables -S | grep "ACCEPT" | grep -v "lo" | grep -v "m state --state RELATED,ESTABLISHED" | wc -l)
        if [ "$PERMISSIVE" -gt 5 ]; then
            SCORE=3
            REC="Plusieurs règles ACCEPT très larges détectées. Revoyez votre politique 'Default Drop'."
        fi
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"