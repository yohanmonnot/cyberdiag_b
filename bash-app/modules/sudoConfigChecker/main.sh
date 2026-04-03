#!/bin/bash
# =============================================================================
# Module : sudoConfigChecker
# Description : Analyse la configuration sudo et détecte les entrées risquées
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_sudoers() {
    if [[ ! -r /etc/sudoers ]]; then
        output_json "FAIL" "/etc/sudoers inaccessible" 0 ""
        exit 0
    fi
    SUSPICIOUS=$(grep -v '^#' /etc/sudoers | grep -E 'NOPASSWD' || true)
}

calculate_score() {
    [[ -n "$SUSPICIOUS" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Entrées sudo potentiellement risquées (NOPASSWD) :
$SUSPICIOUS"
}

main() {
    collect_sudoers
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"