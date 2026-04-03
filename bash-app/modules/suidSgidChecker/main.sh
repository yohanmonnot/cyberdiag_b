#!/bin/bash
# =============================================================================
# Module : logAnalyzer
# Description : Analyse rapide des logs auth et syslog
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_logs() {
    AUTH_ERRORS=$(grep -iE 'failed|error|invalid' /var/log/auth.log 2>/dev/null | tail -n 20)
    SYS_ERRORS=$(grep -iE 'fail|error' /var/log/syslog 2>/dev/null | tail -n 20)
}

calculate_score() {
    [[ -n "$AUTH_ERRORS$SYS_ERRORS" ]] && SCORE=3 || SCORE=5
    RECOMMENDATION="Dernières erreurs auth :
$AUTH_ERRORS

Dernières erreurs syslog :
$SYS_ERRORS"
}

main() {
    collect_logs
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"