#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

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
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

# --- Fonction : vérification dépendances ---
check_requirements() {
    if ! command -v free &>/dev/null; then
        ERROR_MESSAGE="La commande 'free' n'est pas disponible."
        log_error "[memoryUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}" "{}"
        exit 0
    fi
    
    if ! command -v jq &>/dev/null; then
        ERROR_MESSAGE="La commande 'jq' n'est pas disponible."
        log_error "[memoryUsage] $ERROR_MESSAGE"
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}" "{}"
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
        output_json "FAIL" "$ERROR_MESSAGE" 0 "" "{}" "{}"
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

# --- Main ---
main() {
    log_info "[memoryUsage] Démarrage du module de vérification mémoire..."
    
    check_requirements
    collect_memory_data
    collect_swap_data
    calculate_score
    
    log_info "[memoryUsage] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
