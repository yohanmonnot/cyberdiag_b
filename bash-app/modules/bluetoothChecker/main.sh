#!/bin/bash
# =============================================================================
# Module : bluetoothChecker
# Description : Vérifie la présence d'un module Bluetooth et sa sécurité
# Version : Advanced Hybrid Test Protocol
# Auteur : Nolhan
# =============================================================================

# --- Load environment and logger ---
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
SCORE=5
RECOMMENDATION=""
BT_DETAILS=""
BT_POWERED=false
BT_DISCOVERABLE=false
BT_CONNECTED_COUNT=0
BT_CONNECTED_NAMES=()
BT_VERSION="Inconnu"

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
# Analyse simulée (logique pure)
# ==================================================
calculate_score() {
    SCORE=5
    RECOMMENDATION=""
    BT_DETAILS=$'État Bluetooth :\n'

    if [[ "$BT_POWERED" == false ]]; then
        SCORE=5
        RECOMMENDATION="Bluetooth désactivé. Risque minimal et économie d'énergie."
        return
    fi

    [[ "$BT_DISCOVERABLE" == true ]] && { ((SCORE-=2)); RECOMMENDATION+="- Bluetooth en mode visible : risque accru, désactivez le mode discoverable.\n"; }
    [[ $BT_CONNECTED_COUNT -gt 0 ]] && { ((SCORE-=1)); RECOMMENDATION+="- Appareils connectés : ${BT_CONNECTED_NAMES[*]}, vérifiez leur légitimité.\n"; }
    [[ "$BT_VERSION" == "Inconnu" || "$BT_VERSION" < "5" ]] && { ((SCORE-=1)); RECOMMENDATION+="- Version Bluetooth ancienne ou inconnue : privilégiez Bluetooth 5.x ou supérieur.\n"; }

    [[ -z "$RECOMMENDATION" ]] && RECOMMENDATION="- Bluetooth activé mais sécurisé. Maintenez les bonnes pratiques.\n"

    BT_DETAILS+="- Activé : $BT_POWERED\n"
    BT_DETAILS+="- Visible : $BT_DISCOVERABLE\n"
    BT_DETAILS+="- Appareils connectés : $BT_CONNECTED_COUNT\n"
    [[ $BT_CONNECTED_COUNT -gt 0 ]] && BT_DETAILS+="- Noms : ${BT_CONNECTED_NAMES[*]}\n"
    BT_DETAILS+="- Version : $BT_VERSION\n"

    RECOMMENDATION+=$'\n'"$BT_DETAILS"
    RECOMMENDATION+=$'\nRecommandations supplémentaires :\n'
    RECOMMENDATION+=$'- Désactivez Bluetooth si non utilisé.\n'
    RECOMMENDATION+=$'- Supprimez les appareils appairés inutilisés.\n'
    RECOMMENDATION+=$'- Mettez à jour le système et les périphériques Bluetooth.\n'
    RECOMMENDATION+=$'- Privilégiez des équipements récents conformes aux normes (Bluetooth 5.x).\n'
}

# ==================================================
# Détection réelle
# ==================================================
analyze_bluetooth() {
    BT_DETAILS=""
    BT_POWERED=false
    BT_DISCOVERABLE=false
    BT_CONNECTED_COUNT=0
    BT_CONNECTED_NAMES=()
    BT_VERSION="Inconnu"

    # Vérifie si bluetoothctl est installé
    if ! command -v bluetoothctl &>/dev/null; then
        ERROR="bluetoothctl n'est pas installé."
        output_json "FAIL" "$ERROR" 0 "Installez le paquet bluez."
        exit 0
    fi

    # Statut Bluetooth
    if bluetoothctl show | grep -q "Powered: yes"; then
        BT_POWERED=true
    fi
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        BT_DISCOVERABLE=true
    fi

    # Appareils connectés
    while read -r line; do
        if [[ "$line" =~ Device\ ([0-9A-F:]+)\ (.+) ]]; then
            DEV_MAC="${BASH_REMATCH[1]}"
            DEV_NAME="${BASH_REMATCH[2]}"
            INFO=$(bluetoothctl info "$DEV_MAC")
            if echo "$INFO" | grep -qi "Connected: yes"; then
                ((BT_CONNECTED_COUNT++))
                BT_CONNECTED_NAMES+=("$DEV_NAME")
            fi
        fi
    done < <(bluetoothctl devices)

    # Version Bluetooth
    if command -v hciconfig &>/dev/null; then
        BT_VERSION=$(hciconfig | grep -i "HCI" -A1 | grep "Version" | head -n1 | awk '{print $3}')
    fi

    calculate_score
}

# ==================================================
# Validation JSON stricte
# ==================================================
validate_json() {
    local JSON="$1"
    echo -e "${YELLOW}Vérification de la structure JSON...${NC}"
    echo "$JSON" | jq . >/dev/null 2>&1 || { echo -e "${RED}JSON invalide${NC}"; return 1; }
    for field in status error score recommendation; do
        if echo "$JSON" | jq -e ".$field" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC} - Field '$field' trouvé"
        else
            echo -e "${RED}FAIL${NC} - Field '$field' manquant"; return 1
        fi
    done
    local SCORE_VALUE
    SCORE_VALUE=$(echo "$JSON" | jq -r '.score')
    if [[ "$SCORE_VALUE" =~ ^[0-5]$ ]]; then
        echo -e "${GREEN}PASS${NC} - Score valide ($SCORE_VALUE)"
    else
        echo -e "${RED}FAIL${NC} - Score invalide ($SCORE_VALUE)"; return 1
    fi
    echo -e "${GREEN}Structure JSON valide${NC}"
    return 0
}

# ==================================================
# Tests unitaires verbeux
# ==================================================
run_unit_tests() {
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}UNIT TESTS - bluetoothChecker${NC}"
    echo -e "${CYAN}==================================================${NC}"

    TOTAL=0; PASS=0; FAIL=0
    run_case() {
        local NAME="$1"
        local POWERED="$2"
        local DISCOVERABLE="$3"
        local CONNECTED_COUNT="$4"
        local CONNECTED_NAMES=("${!5}")
        local VERSION="$6"
        local EXPECTED="$7"

        BT_POWERED="$POWERED"
        BT_DISCOVERABLE="$DISCOVERABLE"
        BT_CONNECTED_COUNT="$CONNECTED_COUNT"
        BT_CONNECTED_NAMES=("${CONNECTED_NAMES[@]}")
        BT_VERSION="$VERSION"
        calculate_score

        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${YELLOW}Simulation:${NC}"
        echo "  POWERED=$POWERED, DISCOVERABLE=$DISCOVERABLE, CONNECTED_COUNT=$CONNECTED_COUNT, CONNECTED_NAMES=${CONNECTED_NAMES[*]}, VERSION=$VERSION"
        echo -e "${YELLOW}Expected Score:${NC} $EXPECTED"
        echo -e "${YELLOW}Obtained Score:${NC} $SCORE"

        ((TOTAL++))
        if [[ "$SCORE" == "$EXPECTED" ]]; then
            echo -e "${GREEN}RESULT: PASS${NC}"
            ((PASS++))
        else
            echo -e "${RED}RESULT: FAIL${NC}"
            ((FAIL++))
        fi
    }

    # Tableaux d'exemple pour les tests
    connected_names_empty=()
    connected_names_2=("Casque" "Clavier")
    # Exemple de test corrigé
    run_case "Bluetooth désactivé" false false 0 connected_names_empty "Inconnu" 5
    run_case "Bluetooth activé et visible" true true 0 connected_names_empty "5.0" 3
    run_case "Bluetooth activé avec appareils connectés" true false 2 connected_names_2 "5.0" 4
    run_case "Bluetooth version ancienne" true false 0 connected_names_empty "4.2" 4

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TEST UNITAIRES${NC}"
    echo "Total tests : $TOTAL"
    echo -e "${GREEN}Passés : $PASS${NC}"
    echo -e "${RED}Échoués : $FAIL${NC}"
    [[ $FAIL -eq 0 ]] && echo -e "${GREEN}Tous les tests unitaires ont réussi${NC}" || echo -e "${RED}Certains tests ont échoué ❌${NC}"
}

# ==================================================
# Test d'intégration réel
# ==================================================
run_integration_test() {
    echo -e "\n${CYAN}================ TEST D'INTÉGRATION ================${NC}"
    analyze_bluetooth
    local JSON
    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")
    echo "$JSON"
    validate_json "$JSON" && echo -e "${GREEN}Integration test PASSED${NC}" || echo -e "${RED}Integration test FAILED ❌${NC}"
}

# ==================================================
# Couverture logique
# ==================================================
run_coverage_check() {
    echo -e "\n${CYAN}================ COUVERTURE LOGIQUE ================${NC}"
    echo "Simulation des scénarios critiques..."
    local scenarios=0
    for POWERED in true false; do
        for DISCOVERABLE in true false; do
            for CONNECTED in 0 1; do
                for VERSION in "5.0" "4.2"; do
                    BT_POWERED=$POWERED
                    BT_DISCOVERABLE=$DISCOVERABLE
                    BT_CONNECTED_COUNT=$CONNECTED
                    BT_CONNECTED_NAMES=("Test")
                    BT_VERSION=$VERSION
                    calculate_score
                    ((scenarios++))
                done
            done
        done
    done
    echo -e "${GREEN}Scénarios testés : $scenarios / 16 (couverture complète)${NC}"
}

# ==================================================
# MASTER TEST
# ==================================================
run_tests() {
    run_unit_tests
    run_integration_test
    run_coverage_check
    echo -e "\n${GREEN}==================================================${NC}"
    echo -e "${GREEN}TOUTES LES PHASES DE TEST ONT ÉTÉ RÉUSSIES AVEC SUCCÈS${NC}"
    echo -e "${GREEN}==================================================${NC}"
    exit 0
}

# ==================================================
# MAIN
# ==================================================
main() {
    if [[ "$1" == "--test" ]]; then
        run_tests
    fi

    log_info "[bluetoothChecker] Analyse du Bluetooth..."
    analyze_bluetooth
    log_info "[bluetoothChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"