#!/bin/bash
# =============================================================================
# Module : processChecker
# Description : Détecte processus suspects (root, ports ouverts, binaires inconnus)
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""; ERROR=""

output_json() {
    echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

check_requirements() { command -v lsof >/dev/null 2>&1 || { output_json "FAIL" "lsof manquant" 0 ""; exit 0; }; }

collect_processes() {
    SUSPICIOUS=$(ps -eo user,pid,cmd --sort=user | awk '$1=="root" && !/sshd|systemd/{print $0}')
    LISTEN_PORTS=$(lsof -i -P -n | grep LISTEN)
}

calculate_score() {
    [[ -n "$SUSPICIOUS" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="Processus root suspects :
$SUSPICIOUS
Ports ouverts :
$LISTEN_PORTS"
}

main() {
    check_requirements
    collect_processes
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"