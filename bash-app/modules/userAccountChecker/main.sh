#!/bin/bash
# =============================================================================
# Module : userAccountChecker
# Description : Détecte comptes inutiles ou inactifs
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_users() {
    INACTIVE_USERS=$(awk -F: '($3>=1000)&&($7!="/usr/sbin/nologin") { print $1,$7 }' /etc/passwd)
    OLD_USERS=$(lastlog -b 90 | awk 'NR>1 && $4!="**Never**" {print $1,$4,$5,$6}' || true)
}

calculate_score() {
    [[ -n "$INACTIVE_USERS$OLD_USERS" ]] && SCORE=3 || SCORE=5
    RECOMMENDATION="Comptes avec shell actif :
$INACTIVE_USERS

Comptes inactifs depuis >90 jours :
$OLD_USERS"
}

main() {
    collect_users
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"