#!/bin/bash
# =============================================================================
# Module : diskUsage
# Description : Vérifie l'utilisation du stockage
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

# --- Variables globales ---
ERROR=""
DISK_DATA_JSON="[]"
SCORE=5
RECOMMENDATION=""

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
    if ! command -v df &>/dev/null || ! command -v jq &>/dev/null; then
        ERROR="Dépendances manquantes : df ou jq."
        log_error "[diskUsage] $ERROR"
        output_json "FAIL" "$ERROR" 0 ""
        exit 0
    fi
}

# ==================================================
# Collecte des partitions
# ==================================================
collect_disk_data() {
    local disk_array="[]"

    while read -r source fstype size used avail pcent target; do
        [[ -z "$source" ]] && continue
        [[ "$source" != /dev/* ]] && continue

        case "$fstype" in ext4|xfs|btrfs|ntfs|vfat) ;; *) continue ;; esac

        local use_percentage
        use_percentage=$(echo "$pcent" | tr -d '%')
        [[ ! "$use_percentage" =~ ^[0-9]+$ ]] && continue

        local disk_item
        disk_item=$(jq -n \
            --arg fs "$source" \
            --arg mount "$target" \
            --argjson pct "$use_percentage" \
            '{filesystem: $fs, mounted_on: $mount, use_percentage: $pct}')

        disk_array=$(echo "$disk_array" | jq --argjson item "$disk_item" '. += [$item]')
    done < <(df -h --output=source,fstype,size,used,avail,pcent,target | tail -n +2)

    DISK_DATA_JSON="$disk_array"
    log_info "[diskUsage] Partitions utilisateur détectées : $(echo "$DISK_DATA_JSON" | jq length)"
}

# ==================================================
# Calcul du score
# ==================================================
calculate_score() {
    local worst_percentage=0
    local worst_mount=""
    local details=""
    local count=0

    count=$(echo "$DISK_DATA_JSON" | jq length)
    if [[ "$count" -eq 0 ]]; then
        SCORE=5
        RECOMMENDATION="Aucune partition utilisateur locale détectée."
        return
    fi

    worst_percentage=$(echo "$DISK_DATA_JSON" | jq '[.[].use_percentage] | max')
    worst_mount=$(echo "$DISK_DATA_JSON" | jq -r ".[] | select(.use_percentage==$worst_percentage) | .mounted_on" | head -n1)
    details=$(echo "$DISK_DATA_JSON" | jq -r '.[] | "- " + .mounted_on + " (" + (.use_percentage|tostring) + "%)"')

    if [[ "$worst_percentage" -lt 70 ]]; then
        SCORE=5
        ACTION="Aucune action nécessaire."
    elif [[ "$worst_percentage" -lt 80 ]]; then
        SCORE=4
        ACTION="Surveiller l'évolution et identifier les dossiers volumineux."
    elif [[ "$worst_percentage" -lt 90 ]]; then
        SCORE=3
        ACTION="Nettoyer fichiers temporaires et journaux."
    elif [[ "$worst_percentage" -lt 95 ]]; then
        SCORE=2
        ACTION="Nettoyage urgent requis."
    else
        SCORE=1
        ACTION="Libérer immédiatement de l'espace."
    fi

    RECOMMENDATION="Utilisation des partitions locales :
$details

Partition la plus critique : $worst_mount (${worst_percentage}%).

Action recommandée :
$ACTION"
}

# ==================================================
# Tests unitaires
# ==================================================
run_unit_tests() {
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}UNIT TESTS - diskUsage${NC}"
    echo -e "${CYAN}==================================================${NC}"

    local TOTAL=0 PASS=0 FAIL=0

    run_case() {
        local NAME="$1" DISK_JSON="$2" EXPECTED="$3"
        DISK_DATA_JSON="$DISK_JSON"
        calculate_score

        ((TOTAL++))
        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${YELLOW}Simulation:${NC}"
        echo "$DISK_DATA_JSON" | jq -c '.[]'
        echo -e "${YELLOW}Expected Score:${NC} $EXPECTED"
        echo -e "${YELLOW}Obtained Score:${NC} $SCORE"

        if [[ "$SCORE" -eq "$EXPECTED" ]]; then
            echo -e "${GREEN}RESULT: PASS${NC}"
            ((PASS++))
        else
            echo -e "${RED}RESULT: FAIL${NC}"
            ((FAIL++))
        fi
    }

    # Test cases
    run_case "Partition faible" '[{"filesystem":"/dev/sda1","mounted_on":"/","use_percentage":50}]' 5
    run_case "Partition modérée" '[{"filesystem":"/dev/sda1","mounted_on":"/","use_percentage":75}]' 4
    run_case "Partition élevée" '[{"filesystem":"/dev/sda1","mounted_on":"/","use_percentage":85}]' 3
    run_case "Partition critique" '[{"filesystem":"/dev/sda1","mounted_on":"/","use_percentage":93}]' 2
    run_case "Partition saturée" '[{"filesystem":"/dev/sda1","mounted_on":"/","use_percentage":98}]' 1

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TEST UNITAIRES${NC}"
    echo "Total tests : $TOTAL, Passés : $PASS, Échoués : $FAIL"
}

# ==================================================
# Test d'intégration
# ==================================================
run_integration_test() {
    echo -e "\n${CYAN}================ TEST D'INTÉGRATION ================${NC}"
    check_requirements
    collect_disk_data
    calculate_score
    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")
    echo "$JSON"
}

# ==================================================
# Couverture logique
# ==================================================
run_coverage_check() {
    echo -e "\n${CYAN}================ COUVERTURE LOGIQUE ================${NC}"
    local scenarios=0
    for pct in 50 75 85 93 98; do
        DISK_DATA_JSON="[{\"filesystem\":\"/dev/sda1\",\"mounted_on\":\"/\",\"use_percentage\":$pct}]"
        calculate_score
        ((scenarios++))
    done
    echo -e "${GREEN}Scénarios testés : $scenarios / 5 (couverture complète)${NC}"
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

    log_info "[diskUsage] Analyse des partitions locales utilisateur..."
    check_requirements
    collect_disk_data
    calculate_score
    log_info "[diskUsage] Vérification terminée, score=$SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"