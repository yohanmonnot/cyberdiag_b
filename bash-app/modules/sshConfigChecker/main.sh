#!/bin/bash
# =============================================================================
# Module : sshConfigChecker
# Description : Vérifie la configuration SSH (PermitRootLogin, PasswordAuth)
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_ssh_config() {
    SSH_CONF="/etc/ssh/sshd_config"
    [[ ! -r $SSH_CONF ]] && { output_json "FAIL" "Fichier $SSH_CONF inaccessible" 0 ""; exit 0; }
    PERMIT_ROOT=$(grep -Ei '^PermitRootLogin' $SSH_CONF | awk '{print $2}' || echo "undefined")
    PASSWORD_AUTH=$(grep -Ei '^PasswordAuthentication' $SSH_CONF | awk '{print $2}' || echo "undefined")
}

calculate_score() {
    [[ "$PERMIT_ROOT" == "yes" || "$PASSWORD_AUTH" == "yes" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="PermitRootLogin: $PERMIT_ROOT
PasswordAuthentication: $PASSWORD_AUTH"
}

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" permit_root="$2" password_auth="$3" expected_score="$4"
        ((total++))
        PERMIT_ROOT="$permit_root"
        PASSWORD_AUTH="$password_auth"
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

    run_case "SSH durci" "no" "no" 5
    run_case "SSH risqué" "yes" "yes" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_ssh_config
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"