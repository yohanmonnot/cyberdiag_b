#!/bin/bash
# =============================================================================
# Module : suidSgidChecker
# Description : Recherche fichiers SUID/SGID anormaux
# Auteur : Nolhan
# =============================================================================

SCORE=5
RECOMMENDATION=""
SUSPICIOUS=""

output_json() {
    echo $(jq -n \
        --arg status "$1" \
        --arg error "$2" \
        --argjson score "$3" \
        --arg recommendation "$4" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

collect_files() {
    SUID_FILES=$(find / -perm -4000 -type f 2>/dev/null)
    SGID_FILES=$(find / -perm -2000 -type f 2>/dev/null)
    SUSPICIOUS=$(echo "$SUID_FILES"$'\n'"$SGID_FILES" | grep -vE '/usr/bin/sudo|/bin/su' || true)
}

calculate_score() {
    [[ -n "$SUSPICIOUS" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Fichiers SUID/SGID anormaux :
$SUSPICIOUS"
}

run_unit_tests() {
    local TOTAL=0
    local PASS=0
    local FAIL=0

    run_case() {
        local NAME="$1"
        local INPUT="$2"
        local EXPECTED_SCORE="$3"
        ((TOTAL++))

        SUSPICIOUS="$INPUT"
        SCORE=5
        RECOMMENDATION=""
        calculate_score

        echo "Test: $NAME"
        echo "Attendu: $EXPECTED_SCORE | Obtenu: $SCORE"

        if [[ "$SCORE" -eq "$EXPECTED_SCORE" ]]; then
            ((PASS++))
            echo "PASS"
        else
            ((FAIL++))
            echo "FAIL"
        fi
    }

    run_case "Aucun fichier suspect" "" 5
    run_case "Fichiers suspects detectes" $'/tmp/test-suid\n/tmp/test-sgid' 2
    run_case "Un seul fichier suspect" "/tmp/test-suid" 2

    echo "Resume des tests unitaires : total=$TOTAL, pass=$PASS, fail=$FAIL"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_files
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"