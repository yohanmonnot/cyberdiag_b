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

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" suspicious_services="$2" expected_score="$3"
        ((total++))
        SUSPICIOUS_SERVICES="$suspicious_services"
        ACTIVE_SERVICES="ssh.service"
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

    run_case "Service sain" "" 5
    run_case "Service risque detecte" "telnet.service" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    check_requirements
    collect_services
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"