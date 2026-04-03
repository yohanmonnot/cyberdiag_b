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

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" suspicious="$2" expected_score="$3"
        ((total++))
        SUSPICIOUS="$suspicious"
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

    run_case "Aucune tache suspecte" "" 5
    run_case "Tache suspecte detectee" "*/5 * * * * root /tmp/script.sh" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_cron
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"