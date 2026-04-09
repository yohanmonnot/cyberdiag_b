#!/bin/bash
# =============================================================================
# Module : encryptionChecker
# Description : Vérifie si les disques sont chiffrés avec LUKS
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_disks() {
    DISKS=$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/" $1}')
    ENCRYPTED=""
    UNENCRYPTED=""
    for disk in $DISKS; do
        cryptsetup isLuks "$disk" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            ENCRYPTED+="$disk"$'\n'
        else
            UNENCRYPTED+="$disk"$'\n'
        fi
    done
}

calculate_score() {
    [[ -n "$UNENCRYPTED" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Disques chiffrés :
$ENCRYPTED
Disques non chiffrés :
$UNENCRYPTED"
}

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" encrypted="$2" unencrypted="$3" expected_score="$4"
        ((total++))
        ENCRYPTED="$encrypted"
        UNENCRYPTED="$unencrypted"
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

    run_case "Tous les disques chiffrés" "/dev/sda1" "" 5
    run_case "Disque non chiffré" "/dev/sda1" "/dev/sdb1" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    collect_disks
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"