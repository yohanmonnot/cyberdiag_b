#!/bin/bash
# Module : rogueDhcpChecker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

check_real() {
    if ! command -v nmap &>/dev/null; then
        echo $(output_json "FAIL" "nmap manquant" 0 "Installez nmap."); exit 0
    fi

    # Scan broadcast DHCP (nécessite privilèges root)
    local DHCP_SERVERS=$(sudo nmap --script broadcast-dhcp-discover -e $(ip route | grep default | awk '{print $5}') | grep "IP Address" | wc -l)

    if [ "$DHCP_SERVERS" -gt 1 ]; then
        SCORE=1
        REC="Alerte : $DHCP_SERVERS serveurs DHCP détectés. Risque de Rogue DHCP / Man-in-the-Middle."
    else
        SCORE=5
        REC="Un seul serveur DHCP légitime détecté."
    fi

    echo $(jq -n --arg status "OK" --arg error "" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

main() {
    check_real
}
main "$@"