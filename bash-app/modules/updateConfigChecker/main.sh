#!/bin/bash
# =============================================================================
# Module : updateConfigChecker
# Description : Vérifie la configuration des mises à jour automatiques
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_update_config() {
    AUTO_UPDATE_STATUS=$(grep -Ei 'APT::Periodic::Update-Package-Lists' /etc/apt/apt.conf.d/* 2>/dev/null | awk '{print $3}' || echo "undefined")
}

calculate_score() {
    [[ "$AUTO_UPDATE_STATUS" != "1;" ]] && SCORE=3 || SCORE=5
    RECOMMENDATION="Mises à jour automatiques :
$AUTO_UPDATE_STATUS"
}

main() {
    collect_update_config
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"