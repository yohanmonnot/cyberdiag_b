#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# Couleurs ANSI
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

# --- Variables globales ---
ERROR_MESSAGE=""
CPU_USER=""
CPU_SYSTEM=""
CPU_NICE=""
CPU_IDLE=""
CPU_WAIT=""
CPU_HW_INT=""
CPU_SW_INT=""
CPU_STOLEN=""
USED_PERCENTAGE=0
SCORE=5
RECOMMENDATION="Utilisation CPU normale"

# --- Fonction : sortie JSON ---
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

# --- Fonction : vérification dépendances ---
check_requirements() {
    if ! command -v top &>/dev/null; then
        ERROR_MESSAGE="La commande 'top' n'est pas disponible."
        log_error "[cpuUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}"
        exit 0
    fi
    
    if ! command -v jq &>/dev/null; then
        ERROR_MESSAGE="La commande 'jq' n'est pas disponible."
        log_error "[cpuUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}"
        exit 0
    fi
}

# --- Fonction : collecte des données CPU ---
collect_cpu_data() {
    local cpu_usage_raw
    cpu_usage_raw=$(top -bn1 | grep "Cpu(s)")
    
    if [[ -z "$cpu_usage_raw" ]]; then
        ERROR_MESSAGE="Impossible de récupérer les données CPU."
        log_error "[cpuUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}"
        exit 0
    fi
    
    CPU_USER=$(echo "$cpu_usage_raw" | awk '{print $2}' | tr -d ',')
    CPU_SYSTEM=$(echo "$cpu_usage_raw" | awk '{print $4}' | tr -d ',')
    CPU_NICE=$(echo "$cpu_usage_raw" | awk '{print $6}' | tr -d ',')
    CPU_IDLE=$(echo "$cpu_usage_raw" | awk '{print $8}' | tr -d ',')
    CPU_WAIT=$(echo "$cpu_usage_raw" | awk '{print $10}' | tr -d ',')
    CPU_HW_INT=$(echo "$cpu_usage_raw" | awk '{print $12}' | tr -d ',')
    CPU_SW_INT=$(echo "$cpu_usage_raw" | awk '{print $14}' | tr -d ',')
    CPU_STOLEN=$(echo "$cpu_usage_raw" | awk '{print $16}' | tr -d ',')
    
    # Calcul du pourcentage d'utilisation
    USED_PERCENTAGE=$(echo "100 - $CPU_IDLE" | bc | cut -d'.' -f1)
    
    log_info "[cpuUsage] CPU utilisé : ${USED_PERCENTAGE}%"
}

# --- Fonction : calcul du score et recommandation ---
calculate_score() {
    SCORE=5
    RECOMMENDATION="Utilisation CPU normale"
    
    if [[ $USED_PERCENTAGE -lt 20 ]]; then
        SCORE=5
        RECOMMENDATION="Utilisation CPU très faible, système au repos."
    elif [[ $USED_PERCENTAGE -lt 40 ]]; then
        SCORE=4
        RECOMMENDATION="Utilisation CPU faible, système peu sollicité."
    elif [[ $USED_PERCENTAGE -lt 60 ]]; then
        SCORE=3
        RECOMMENDATION="Utilisation CPU modérée, surveillance recommandée."
    elif [[ $USED_PERCENTAGE -lt 80 ]]; then
        SCORE=2
        RECOMMENDATION="Utilisation CPU élevée, identifier les processus gourmands."
    else
        SCORE=1
        RECOMMENDATION="Utilisation CPU critique, optimisation urgente nécessaire."
    fi
}

# --- Self-testing functionality ---
run_self_tests() {
    echo "============================================="
    echo "Running internal function tests (cpuUsage)"
    echo "============================================="

    local passed=0
    local failed=0

    test_case() {
        local name="$1"
        shift
        if "$@"; then
            echo -e "${GREEN}PASS${RESET} - $name"
            ((passed++))
        else
            echo -e "${RED}FAIL${RESET} - $name"
            ((failed++))
        fi
    }

    # --- Test output_json ---
    test_case "output_json returns valid JSON" bash -c '
        source "'"$PROJECT_ROOT/utils/env.sh"'" 2>/dev/null || true
        source "'"$PROJECT_ROOT/utils/logger.sh"'" 2>/dev/null || true
        source "'"$SCRIPT_DIR/$(basename "$0")"'" output_json >/dev/null 2>&1
        declare -f output_json >/dev/null &&
        output_json "OK" "" 5 "Test" | jq . >/dev/null 2>&1
    '

    # --- Test check_requirements ---
    test_case "check_requirements executes without crash" check_requirements

    # --- Test collect_cpu_data ---
    test_case "collect_cpu_data executes without crash" collect_cpu_data

    # --- Test calculate_score ---
    USED_PERCENTAGE=85  # Simule une forte utilisation
    calculate_score
    if [[ "$SCORE" -eq 1 ]]; then
        echo -e "${GREEN}PASS${RESET} - calculate_score logic correct"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - calculate_score logic incorrect"
        ((failed++))
    fi

    echo -e "-------------------------------------------"
    echo -e "${CYAN}Total:${RESET} $((passed+failed)) | ${GREEN}Passed:${RESET} $passed | ${RED}Failed:${RESET} $failed"
    echo -e "-------------------------------------------"

    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}All internal tests passed.${RESET}"
    else
        echo -e "${RED}Some internal tests failed.${RESET}"
    fi
}


# --- Main ---
main() {
    if [[ "$1" == "--test" ]]; then
        run_self_tests
        exit 0
    fi

    log_info "[cpuUsage] Démarrage du module de vérification CPU..."
    
    check_requirements
    collect_cpu_data
    calculate_score
    
    log_info "[cpuUsage] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
