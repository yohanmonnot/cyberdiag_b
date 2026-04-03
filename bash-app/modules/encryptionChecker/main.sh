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

main() {
    collect_disks
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"