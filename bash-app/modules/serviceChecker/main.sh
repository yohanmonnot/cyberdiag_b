#!/bin/bash
# =============================================================================
# Module : serviceChecker
# Description : Vérifie services actifs et identifie services inutiles
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""; ERROR=""

output_json() {
    local STATUS="$1"; local ERROR="$2"; local SCORE="$3"; local RECOMMENDATION="$4"
    echo $(jq -n --arg status "$STATUS" --arg error "$ERROR" --argjson score "$SCORE" --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

check_requirements() {
    command -v systemctl >/dev/null 2>&1 || { output_json "FAIL" "systemctl introuvable" 0 ""; exit 0; }
}

collect_services() {
    ACTIVE_SERVICES=$(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}')
    SUSPICIOUS_SERVICES=$(echo "$ACTIVE_SERVICES" | grep -E 'telnet|ftp|rsh' || true)
}

calculate_score() {
    [[ -n "$SUSPICIOUS_SERVICES" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Services actifs :
$ACTIVE_SERVICES
Services potentiellement inutiles ou risqués :
$SUSPICIOUS_SERVICES"
}

main() {
    check_requirements
    collect_services
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"