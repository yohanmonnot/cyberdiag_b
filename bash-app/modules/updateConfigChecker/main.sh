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

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" auto_update_status="$2" expected_score="$3"
        ((total++))
        AUTO_UPDATE_STATUS="$auto_update_status"
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

    run_case "Mises a jour actives" "1;" 5
    run_case "Mises a jour desactivees" "0;" 3

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_update_config
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"