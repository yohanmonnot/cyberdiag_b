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
MEM_TOTAL=""
MEM_USED=""
MEM_FREE=""
MEM_SHARED=""
MEM_BUFF_CACHE=""
MEM_AVAILABLE=""
SWAP_TOTAL=""
SWAP_USED=""
SWAP_FREE=""
USED_PERCENTAGE=0
SCORE=5
RECOMMENDATION="Utilisation mémoire normale"

# --- Fonction : sortie JSON ---
output_json() {
    local STATUS="$1"
    local ERROR="$2"
    local SCORE="$3"
    local RECOMMENDATION="$4"
    
    echo $(jq -n \
        --argjson status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{exitCode: $status, error: $error, score: $score, recommendation: $recommendation}')
}

# --- Fonction : vérification dépendances ---
check_requirements() {
    if ! command -v free &>/dev/null; then
        ERROR_MESSAGE="La commande 'free' n'est pas disponible."
        log_error "[memoryUsage] $ERROR_MESSAGE"
        output_json 1 "$ERROR_MESSAGE" 0 "" "{}" "{}"
        exit 0
    fi
    
    if ! command -v jq &>/dev/null; then
        ERROR_MESSAGE="La commande 'jq' n'est pas disponible."
        log_error "[memoryUsage] $ERROR_MESSAGE"
        output_json 1 "$ERROR_MESSAGE" 0 "" "{}" "{}"
        exit 0
    fi
}

# --- Fonction : collecte des données mémoire ---
collect_memory_data() {
    local memory_usage_raw
    memory_usage_raw=$(free -m | grep "Mem:")
    
    if [[ -z "$memory_usage_raw" ]]; then
        ERROR_MESSAGE="Impossible de récupérer les données mémoire."
        log_error "[memoryUsage] $ERROR_MESSAGE"
        output_json 1 "$ERROR_MESSAGE" 0 "" "{}" "{}"
        exit 0
    fi
    
    MEM_TOTAL=$(echo "$memory_usage_raw" | awk '{print $2}')
    MEM_USED=$(echo "$memory_usage_raw" | awk '{print $3}')
    MEM_FREE=$(echo "$memory_usage_raw" | awk '{print $4}')
    MEM_SHARED=$(echo "$memory_usage_raw" | awk '{print $5}')
    MEM_BUFF_CACHE=$(echo "$memory_usage_raw" | awk '{print $6}')
    MEM_AVAILABLE=$(echo "$memory_usage_raw" | awk '{print $7}')
    
    # Calcul du pourcentage d'utilisation
    if [[ $MEM_TOTAL -gt 0 ]]; then
        USED_PERCENTAGE=$((100 * MEM_USED / MEM_TOTAL))
    else
        USED_PERCENTAGE=0
    fi
    
    log_info "[memoryUsage] Mémoire utilisée : ${USED_PERCENTAGE}% (${MEM_USED}MB/${MEM_TOTAL}MB)"
}

# --- Fonction : collecte des données swap ---
collect_swap_data() {
    local swap_usage_raw
    swap_usage_raw=$(free -m | grep "Swap:")
    
    if [[ -n "$swap_usage_raw" ]]; then
        SWAP_TOTAL=$(echo "$swap_usage_raw" | awk '{print $2}')
        SWAP_USED=$(echo "$swap_usage_raw" | awk '{print $3}')
        SWAP_FREE=$(echo "$swap_usage_raw" | awk '{print $4}')
    else
        SWAP_TOTAL="0"
        SWAP_USED="0"
        SWAP_FREE="0"
    fi
    
    log_info "[memoryUsage] Swap utilisé : ${SWAP_USED}MB/${SWAP_TOTAL}MB"
}

# --- Fonction : calcul du score et recommandation ---
calculate_score() {
    SCORE=5
    RECOMMENDATION="Utilisation mémoire normale"
    
    if [[ $USED_PERCENTAGE -lt 20 ]]; then
        SCORE=5
        RECOMMENDATION="Utilisation mémoire très faible, système peu sollicité."
    elif [[ $USED_PERCENTAGE -lt 40 ]]; then
        SCORE=4
        RECOMMENDATION="Utilisation mémoire faible, système optimal."
    elif [[ $USED_PERCENTAGE -lt 60 ]]; then
        SCORE=3
        RECOMMENDATION="Utilisation mémoire modérée, surveillance recommandée."
    elif [[ $USED_PERCENTAGE -lt 80 ]]; then
        SCORE=2
        RECOMMENDATION="Utilisation mémoire élevée, fermer les applications inutiles."
    else
        SCORE=1
        RECOMMENDATION="Utilisation mémoire critique, risque de ralentissement."
    fi
}

# --- Self-testing functionality ---
# --- Self-testing functionality ---
run_self_tests() {
    echo "============================================="
    echo "Running internal function tests (memoryUsage)"
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

    # --- Test : output_json ---
    test_case "output_json produces valid JSON" bash -c 'output_json 0 "" 5 "Test" | jq . >/dev/null 2>&1'

    # --- Test : check_requirements ---
    if command -v free &>/dev/null && command -v jq &>/dev/null; then
        test_case "check_requirements executes without error" check_requirements
    else
        echo -e "${YELLOW}SKIP${RESET} - command 'free' or 'jq' not available"
    fi

    # --- Test : collect_memory_data ---
    test_case "collect_memory_data runs without crash" collect_memory_data
    if [[ $USED_PERCENTAGE -ge 0 && $USED_PERCENTAGE -le 100 ]]; then
        echo -e "${GREEN}PASS${RESET} - USED_PERCENTAGE value valid (${USED_PERCENTAGE}%)"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - USED_PERCENTAGE value invalid (${USED_PERCENTAGE}%)"
        ((failed++))
    fi

    # --- Test : collect_swap_data ---
    test_case "collect_swap_data runs without crash" collect_swap_data
    if [[ -n "$SWAP_TOTAL" && -n "$SWAP_USED" ]]; then
        echo -e "${GREEN}PASS${RESET} - Swap data collected (${SWAP_USED}/${SWAP_TOTAL} MB)"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - Swap data not collected properly"
        ((failed++))
    fi

    # --- Test : calculate_score ---
    USED_PERCENTAGE=85
    calculate_score
    if [[ "$SCORE" -eq 1 && "$RECOMMENDATION" == *"critique"* ]]; then
        echo -e "${GREEN}PASS${RESET} - calculate_score logic consistent"
        ((passed++))
    else
        echo -e "${RED}FAIL${RESET} - calculate_score logic inconsistent"
        ((failed++))
    fi

    # --- Résumé ---
    echo -e "-------------------------------------------"
    echo -e "${CYAN}Total:${RESET} $((passed + failed)) | ${GREEN}Passed:${RESET} $passed | ${RED}Failed:${RESET} $failed"
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

    log_info "[memoryUsage] Démarrage du module de vérification mémoire..."
    
    check_requirements
    collect_memory_data
    collect_swap_data
    calculate_score
    
    log_info "[memoryUsage] Vérification terminée avec un score de $SCORE/5"
    output_json 0 "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
