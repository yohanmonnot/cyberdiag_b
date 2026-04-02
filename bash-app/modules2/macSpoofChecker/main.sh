#!/bin/bash
# Module : macSpoofChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    local INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -z "$INTERFACE" ]]; then
        echo $(jq -n --arg s "FAIL" --arg e "Pas d'interface active" --argjson sc 0 --arg r "" '{status: $s, error: $e, score: $sc, recommendation: $r}')
        exit 0
    fi

    # Comparaison via ethtool si dispo ou /sys/class/net
    local CURRENT_MAC=$(cat /sys/class/net/$INTERFACE/address)
    local PERM_MAC=$(ethtool -P "$INTERFACE" 2>/dev/null | awk '{print $3}')

    if [[ -n "$PERM_MAC" && "$CURRENT_MAC" != "$PERM_MAC" ]]; then
        SCORE=3; REC="MAC Spoofing détecté ou changement manuel de l'adresse MAC."
    else
        SCORE=5; REC="Adresse MAC conforme au matériel."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"