#!/bin/bash
# Module : networkConfigChecker
# Description : Vérifie la cohérence IP, DNS, Gateway

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# Couleurs
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[1;36m'; NC='\033[0m'

output_json() {
    local STATUS="$1" ERROR="$2" SCORE="$3" REC="$4"
    echo $(jq -n --arg status "$STATUS" --arg error "$ERROR" --argjson score "$SCORE" --arg recommendation "$REC" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

evaluate_config() {
    local HAS_IP=$1; local HAS_GW=$2; local HAS_DNS=$3; local IS_APIPA=$4
    SCORE=5; RECOMMENDATION=""
    
    if ! $HAS_IP; then SCORE=0; RECOMMENDATION="Aucune interface réseau n'a d'IP locale."; return; fi
    if $IS_APIPA; then SCORE=1; RECOMMENDATION="Auto-configuration APIPA (169.254.x.x) détectée : pas de serveur DHCP fonctionnel."; return; fi
    if ! $HAS_GW; then ((SCORE-=2)); RECOMMENDATION+="- Aucune passerelle par défaut (Gateway) définie.\n"; fi
    if ! $HAS_DNS; then ((SCORE-=2)); RECOMMENDATION+="- Aucun serveur DNS configuré.\n"; fi
    
    [[ $SCORE -eq 5 ]] && RECOMMENDATION="Configuration réseau locale valide."
}

check_real() {
    local HAS_IP=false; local HAS_GW=false; local HAS_DNS=false; local IS_APIPA=false
    
    [[ -n $(hostname -I) ]] && HAS_IP=true
    ip route | grep -q "default" && HAS_GW=true
    grep -q "nameserver" /etc/resolv.conf 2>/dev/null && HAS_DNS=true
    ip addr | grep -q "169.254." && IS_APIPA=true
    
    evaluate_config "$HAS_IP" "$HAS_GW" "$HAS_DNS" "$IS_APIPA"
}

run_tests() {
    echo -e "${CYAN}--- UNIT TESTS: networkConfigChecker ---${NC}"
    evaluate_config true true true false; [[ $SCORE -eq 5 ]] && echo -e "${GREEN}PASS: Normal${NC}" || echo -e "${RED}FAIL${NC}"
    evaluate_config true true true true; [[ $SCORE -eq 1 ]] && echo -e "${GREEN}PASS: APIPA${NC}" || echo -e "${RED}FAIL${NC}"
    exit 0
}

main() {
    [[ "$1" == "--test" ]] && run_tests
    check_real
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}
main "$@"