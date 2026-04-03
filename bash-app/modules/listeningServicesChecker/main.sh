#!/bin/bash
# Module : listeningServicesChecker
# Description : Analyse les processus rattachés aux ports ouverts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

output_json() {
    echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

evaluate_services() {
    local SUSPICIOUS_COUNT=$1
    local LIST="$2"
    SCORE=5
    RECOMMENDATION="Tous les services semblent légitimes."

    if [ "$SUSPICIOUS_COUNT" -gt 0 ]; then
        SCORE=2
        RECOMMENDATION="Services suspects ou non identifiés détectés : $LIST"
    fi
}

check_real() {
    # Nécessite souvent sudo pour voir les noms de processus (PID)
    local SUSPICIOUS=0
    local SERVICES_FOUND=""
    
    # On cherche des services qui ne sont pas dans une whitelist de base (ex: sshd, systemd-resolved)
    while read -r line; do
        if [[ ! "$line" =~ (sshd|systemd-resolved|cupsd|apache2|nginx|docker) ]]; then
            ((SUSPICIOUS++))
            SERVICES_FOUND+="$(echo $line | awk '{print $1}'), "
        fi
    done < <(ss -tulpn | grep "LISTEN" | awk '{print $7}' | cut -d'"' -f2 | sort -u)

    evaluate_services "$SUSPICIOUS" "$SERVICES_FOUND"
}

main() {
    [[ "$1" == "--test" ]] && { evaluate_services 1 "nc"; echo "Score: $SCORE"; exit 0; }
    check_real
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}
main "$@"