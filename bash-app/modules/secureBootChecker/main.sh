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

main() {
    collect_secureboot_status
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"