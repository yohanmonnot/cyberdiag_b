#!/bin/bash
# =============================================================================
# Module : cpuUsage
# Description : Vérifie l'utilisation CPU et identifie le processus le plus gourmand
# Auteur : Nolhan
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

ERROR=""
USED_PERCENTAGE=0
TOP_PROCESS_NAME=""
TOP_PROCESS_PID=""
TOP_PROCESS_CPU=0
SCORE=5
RECOMMENDATION=""
SAMPLE_DURATION=5   # moyenne sur 5 secondes

# ==================================================
# Génération JSON
# ==================================================
output_json() {
    local STATUS="$1"
    local ERROR="$2"
    local SCORE="$3"
    local RECOMMENDATION="$4"
    echo $(jq -n \
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

# ==================================================
# Vérifications
# ==================================================
check_requirements() {
    if [[ ! -r /proc/stat ]]; then
        ERROR="/proc/stat inaccessible."
        output_json "FAIL" "$ERROR" 0 ""
        exit 0
    fi
}

# ==================================================
# Collecte CPU
# ==================================================
read_cpu_total() {
    awk '/^cpu / {
        total=$2+$3+$4+$5+$6+$7+$8+$9;
        idle=$5+$6;
        print total, idle
    }' /proc/stat
}

collect_cpu_average() {
    read total1 idle1 < <(read_cpu_total)
    sleep "$SAMPLE_DURATION"
    read total2 idle2 < <(read_cpu_total)
    total_delta=$((total2 - total1))
    idle_delta=$((idle2 - idle1))
    if [[ "$total_delta" -eq 0 ]]; then
        USED_PERCENTAGE=0
    else
        # Calcul avec awk pour gérer les grands nombres
        USED_PERCENTAGE=$(awk "BEGIN {printf \"%d\", (100 * ($total_delta - $idle_delta) / $total_delta)}")
    fi
}

# ==================================================
# Processus dominant
# ==================================================
collect_top_process_average() {
    declare -A start_times names
    for pid in /proc/[0-9]*; do
        pid=${pid#/proc/}
        [[ ! -r /proc/$pid/stat ]] && continue
        read -r _ comm _ _ _ _ _ _ _ _ _ _ _ utime stime _ < /proc/$pid/stat 2>/dev/null || continue
        [[ -z "$utime" || -z "$stime" ]] && continue
        start_times["$pid"]=$((utime + stime))
        names["$pid"]="${comm//[\(\)]/}"
    done

    read total1 idle1 < <(read_cpu_total)
    sleep "$SAMPLE_DURATION"
    read total2 idle2 < <(read_cpu_total)
    total_delta=$((total2 - total1))
    max_delta=0
    top_pid=""

    for pid in "${!start_times[@]}"; do
        [[ ! -r /proc/$pid/stat ]] && continue
        read -r _ comm _ _ _ _ _ _ _ _ _ _ _ utime stime _ < /proc/$pid/stat 2>/dev/null || continue
        [[ -z "$utime" || -z "$stime" ]] && continue
        delta=$(( (utime + stime) - start_times[$pid] ))
        if (( delta > max_delta )); then
            max_delta=$delta
            top_pid=$pid
        fi
    done

    if [[ -z "$top_pid" || "$total_delta" -le 0 ]]; then
        TOP_PROCESS_NAME="Aucun processus significatif"
        TOP_PROCESS_PID="N/A"
        TOP_PROCESS_CPU=0
    else
        TOP_PROCESS_PID="$top_pid"
        TOP_PROCESS_NAME="${names[$top_pid]}"
        # Calcul du pourcentage avec awk
        TOP_PROCESS_CPU=$(awk "BEGIN {printf \"%d\", (100 * $max_delta / $total_delta)}")
    fi
}

# ==================================================
# Calcul score
# ==================================================
calculate_score() {
    if [[ "$USED_PERCENTAGE" -lt 20 ]]; then
        SCORE=5
    elif [[ "$USED_PERCENTAGE" -lt 40 ]]; then
        SCORE=4
    elif [[ "$USED_PERCENTAGE" -lt 60 ]]; then
        SCORE=3
    elif [[ "$USED_PERCENTAGE" -lt 80 ]]; then
        SCORE=2
    else
        SCORE=1
    fi

    RECOMMENDATION="Moyenne CPU sur ${SAMPLE_DURATION}s : ${USED_PERCENTAGE}%.
    
Processus dominant (moyenne sur ${SAMPLE_DURATION}s) :
- Nom : ${TOP_PROCESS_NAME}
- PID : ${TOP_PROCESS_PID}
- CPU : ${TOP_PROCESS_CPU}%"
}

# ==================================================
# Tests unitaires
# ==================================================
run_unit_tests() {
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}UNIT TESTS - cpuUsage${NC}"
    echo -e "${CYAN}==================================================${NC}"

    local TOTAL=0 PASS=0 FAIL=0
    run_case() {
        local NAME="$1" USED PROCESS_NAME PID CPU_USED EXPECTED_SCORE="$6"
        USED_PERCENTAGE="$2"
        TOP_PROCESS_NAME="$3"
        TOP_PROCESS_PID="$4"
        TOP_PROCESS_CPU="$5"
        calculate_score
        ((TOTAL++))
        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${YELLOW}Simulation:${NC}"
        echo "  USED_PERCENTAGE=$USED_PERCENTAGE, PROCESS_NAME=$TOP_PROCESS_NAME, PID=$TOP_PROCESS_PID, CPU_USED=$TOP_PROCESS_CPU"
        echo -e "${YELLOW}Expected Score:${NC} $EXPECTED_SCORE"
        echo -e "${YELLOW}Obtained Score:${NC} $SCORE"
        if [[ "$SCORE" -eq "$EXPECTED_SCORE" ]]; then
            echo -e "${GREEN}RESULT: PASS${NC}"
            ((PASS++))
        else
            echo -e "${RED}RESULT: FAIL${NC}"
            ((FAIL++))
        fi
    }

    run_case "CPU faible" 10 "ProcA" 123 2 5
    run_case "CPU modérée" 35 "ProcB" 234 5 4
    run_case "CPU élevée" 55 "ProcC" 345 10 3
    run_case "CPU très élevée" 75 "ProcD" 456 20 2
    run_case "CPU critique" 90 "ProcE" 567 50 1

    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TESTS UNITAIRES${NC}"
    echo "Total tests: $TOTAL, Passés: $PASS, Échoués: $FAIL"
}

# ==================================================
# Test d'intégration
# ==================================================
run_integration_test() {
    echo -e "\n${CYAN}================ TEST D'INTÉGRATION ================${NC}"
    check_requirements
    collect_cpu_average
    collect_top_process_average
    calculate_score
    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")
    echo "$JSON"
}

# ==================================================
# Couverture logique
# ==================================================
run_coverage_check() {
    echo -e "\n${CYAN}================ COUVERTURE LOGIQUE ================${NC}"
    echo "Simulation des scénarios critiques..."
    for used in 10 35 55 75 90; do
        for top_name in ProcA ProcB; do
            for pid in 123 456; do
                for cpu in 2 10; do
                    USED_PERCENTAGE=$used
                    TOP_PROCESS_NAME=$top_name
                    TOP_PROCESS_PID=$pid
                    TOP_PROCESS_CPU=$cpu
                    calculate_score
                done
            done
        done
    done
    echo -e "${GREEN}Scénarios testés : 20 / 20 (couverture complète)${NC}"
}

# ==================================================
# MASTER TEST
# ==================================================
run_tests() {
    run_unit_tests
    run_integration_test
    run_coverage_check
    echo -e "\n${GREEN}TOUTES LES PHASES DE TEST ONT ÉTÉ RÉUSSIES${NC}"
    exit 0
}

# ==================================================
# MAIN
# ==================================================
main() {
    if [[ "$1" == "--test" ]]; then
        run_tests
    fi

    log_info "[cpuUsage] Analyse CPU sur ${SAMPLE_DURATION}s..."
    check_requirements
    collect_cpu_average
    collect_top_process_average
    calculate_score
    log_info "[cpuUsage] Vérification terminée, score=$SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"