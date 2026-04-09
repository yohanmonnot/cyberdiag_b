#!/bin/bash
# =============================================================================
# Module : secureBootChecker
# Description : Vérifie si le Secure Boot est activé
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() {
    echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

collect_secureboot_status() {
    if [[ -f /sys/firmware/efi/efivars/SecureBoot-*/data ]]; then
        SECUREBOOT=$(od -An -t u1 /sys/firmware/efi/efivars/SecureBoot-*/data | awk '{print $1}')
        [[ "$SECUREBOOT" == "1" ]] && STATUS="Activé" || STATUS="Désactivé"
    else
        STATUS="Non détecté"
    fi
}

calculate_score() {
    [[ "$STATUS" == "Activé" ]] && SCORE=5 || SCORE=2
    RECOMMENDATION="Secure Boot : $STATUS"
}

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" status_value="$2" expected_score="$3"
        ((total++))
        STATUS="$status_value"
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

    run_case "Secure Boot active" "Activé" 5
    run_case "Secure Boot desactive ou absent" "Non détecté" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_secureboot_status
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"