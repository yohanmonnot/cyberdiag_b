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
DISK_DATA_JSON="[]"
TOTAL_USED_PERCENTAGE=0
AVERAGE_USED_PERCENTAGE=0
FILESYSTEM_COUNT=0
SCORE=5
RECOMMENDATION="Espace disque suffisant"

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
    if ! command -v df &>/dev/null; then
        ERROR_MESSAGE="La commande 'df' n'est pas disponible."
        log_error "[diskUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "[]" 0
        exit 0
    fi
    
    if ! command -v jq &>/dev/null; then
        ERROR_MESSAGE="La commande 'jq' n'est pas disponible."
        log_error "[diskUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "[]" 0
        exit 0
    fi
}

# --- Fonction : collecte des données disque ---
collect_disk_data() {
    local disk_output
    disk_output=$(df -h --output=source,size,used,avail,pcent,target 2>/dev/null)
    
    if [[ -z "$disk_output" ]]; then
        # Fallback si --output n'est pas supporté
        disk_output=$(df -h)
    fi
    
    local disk_array="[]"
    local line_count=0
    
    while IFS= read -r line; do
        # Ignorer l'en-tête
        if [[ $line_count -eq 0 ]] || [[ $line == *"Filesystem"* ]] || [[ $line == *"Sys. de fichiers"* ]]; then
            line_count=$((line_count + 1))
            continue
        fi
        
        # Filtrer les systèmes de fichiers temporaires et virtuels
        if [[ $line == tmpfs* ]] || [[ $line == devtmpfs* ]] || [[ $line == *"/snap/"* ]]; then
            continue
        fi
        
        local filesystem=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local used=$(echo "$line" | awk '{print $3}')
        local available=$(echo "$line" | awk '{print $4}')
        local use_percentage=$(echo "$line" | awk '{print $5}' | tr -d '%')
        local mounted_on=$(echo "$line" | awk '{print $6}')
        
        # Vérifier que use_percentage est un nombre valide
        if [[ ! "$use_percentage" =~ ^[0-9]+$ ]]; then
            continue
        fi
        
        # Ajouter au JSON array
        local disk_item
        disk_item=$(jq -n \
            --arg fs "$filesystem" \
            --arg size "$size" \
            --arg used "$used" \
            --arg avail "$available" \
            --argjson pct "$use_percentage" \
            --arg mount "$mounted_on" \
            '{filesystem: $fs, size: $size, used: $used, available: $avail, use_percentage: $pct, mounted_on: $mount}')
        
        disk_array=$(echo "$disk_array" | jq --argjson item "$disk_item" '. += [$item]')
        
        TOTAL_USED_PERCENTAGE=$((TOTAL_USED_PERCENTAGE + use_percentage))
        FILESYSTEM_COUNT=$((FILESYSTEM_COUNT + 1))
        
    done <<< "$disk_output"
    
    DISK_DATA_JSON="$disk_array"
    
    # Calcul de la moyenne
    if [[ $FILESYSTEM_COUNT -gt 0 ]]; then
        AVERAGE_USED_PERCENTAGE=$((TOTAL_USED_PERCENTAGE / FILESYSTEM_COUNT))
    else
        AVERAGE_USED_PERCENTAGE=0
    fi
    
    log_info "[diskUsage] Nombre de systèmes de fichiers analysés : $FILESYSTEM_COUNT"
    log_info "[diskUsage] Utilisation moyenne : ${AVERAGE_USED_PERCENTAGE}%"
}

# --- Fonction : calcul du score et recommandation ---
calculate_score() {
    SCORE=5
    RECOMMENDATION="Espace disque suffisant"
    
    if [[ $AVERAGE_USED_PERCENTAGE -lt 20 ]]; then
        SCORE=5
        RECOMMENDATION="Espace disque largement disponible."
    elif [[ $AVERAGE_USED_PERCENTAGE -lt 40 ]]; then
        SCORE=4
        RECOMMENDATION="Espace disque confortable."
    elif [[ $AVERAGE_USED_PERCENTAGE -lt 60 ]]; then
        SCORE=3
        RECOMMENDATION="Espace disque modéré, surveillance recommandée."
    elif [[ $AVERAGE_USED_PERCENTAGE -lt 80 ]]; then
        SCORE=2
        RECOMMENDATION="Espace disque limité, nettoyage conseillé."
    else
        SCORE=1
        RECOMMENDATION="Espace disque critique, libérer de l'espace urgemment."
    fi
}


# --- Self-testing functionality ---
# --- Self-testing functionality ---
run_self_tests() {
    echo "============================================="
    echo "Running internal function tests (diskUsage)"
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

    # Test output_json (appelle directement la fonction depuis le script)
    test_case "output_json returns valid JSON" bash -c '. "'"$0"'" >/dev/null; output_json "OK" "" 5 "Test" | jq . >/dev/null 2>&1'

    # Test check_requirements
    if command -v df &>/dev/null; then
        test_case "check_requirements executes without crash" check_requirements
    else
        echo "SKIP - df non disponible"
    fi

    if command -v jq &>/dev/null; then
        test_case "check_requirements executes without crash" check_requirements
    else
        echo "SKIP - jq non disponible"
    fi

    # Test collect_disk_data
    test_case "collect_disk_data executes without crash" collect_disk_data

    # Test logique du calcul de score
    # On force la moyenne à différents niveaux pour simuler les cas
    local logic_ok=true

    AVERAGE_USED_PERCENTAGE=10; calculate_score; [[ "$SCORE" -eq 5 ]] || logic_ok=false
    AVERAGE_USED_PERCENTAGE=30; calculate_score; [[ "$SCORE" -eq 4 ]] || logic_ok=false
    AVERAGE_USED_PERCENTAGE=50; calculate_score; [[ "$SCORE" -eq 3 ]] || logic_ok=false
    AVERAGE_USED_PERCENTAGE=70; calculate_score; [[ "$SCORE" -eq 2 ]] || logic_ok=false
    AVERAGE_USED_PERCENTAGE=90; calculate_score; [[ "$SCORE" -eq 1 ]] || logic_ok=false

    if $logic_ok; then
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

    log_info "[diskUsage] Démarrage du module de vérification disque..."
    
    check_requirements
    collect_disk_data
    calculate_score
    
    log_info "[diskUsage] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
