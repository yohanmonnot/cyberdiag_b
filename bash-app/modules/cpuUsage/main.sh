#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

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

# --- Main ---
main() {
    log_info "[cpuUsage] Démarrage du module de vérification CPU..."
    
    check_requirements
    collect_cpu_data
    calculate_score
    
    log_info "[cpuUsage] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
