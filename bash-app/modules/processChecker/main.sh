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

run_unit_tests() {
    local total=0 pass=0 fail=0

    run_case() {
        local label="$1" suspicious="$2" listen_ports="$3" expected_score="$4"
        ((total++))
        SUSPICIOUS="$suspicious"
        LISTEN_PORTS="$listen_ports"
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

    run_case "Aucun processus suspect" "" "" 5
    run_case "Processus suspect detecte" "root 123 /bin/bash" "tcp 0 0 0.0.0.0:22 LISTEN" 2

    echo "Resume des tests unitaires : total=$total, pass=$pass, fail=$fail"
}

main() {
    if [[ "$1" == "--test" ]]; then
        run_unit_tests
        exit 0
    fi

    check_requirements
    collect_processes
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"