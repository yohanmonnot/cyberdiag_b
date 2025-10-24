#!/bin/bash

# --- Load environment and logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

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

# --- Main ---
main() {
    log_info "[diskUsage] Démarrage du module de vérification disque..."
    
    check_requirements
    collect_disk_data
    calculate_score
    
    log_info "[diskUsage] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"
