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

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" inactive_users="$2" old_users="$3" expected_score="$4"
        ((total++))
        INACTIVE_USERS="$inactive_users"
        OLD_USERS="$old_users"
        SCORE=5
        calculate_score
        if [[ "$SCORE" -eq "$expected_score" ]]; then
            ((pass++))
            echo "PASS - $label"
        else
            ((fail++))
            echo "FAIL - $label (score=$SCORE, attendu=$expected_score)"
        fi
    }

    run_case "Aucun compte suspect" "" "" 5
    run_case "Comptes suspects detectes" "user1 /bin/bash" "user2 90 days" 3

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_users
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"