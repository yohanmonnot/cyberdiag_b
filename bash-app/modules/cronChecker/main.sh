#!/bin/bash
# =============================================================================
# Module : cronChecker
# Description : Détecte tâches planifiées suspectes
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_cron() {
    SUSPICIOUS=$(grep -vE '^#|^$' /etc/crontab /etc/cron.d/* 2>/dev/null | grep -vE 'logrotate|anacron' || true)
}

calculate_score() {
    [[ -n "$SUSPICIOUS" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Tâches planifiées suspectes :
$SUSPICIOUS"
}

main() {
    collect_cron
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"