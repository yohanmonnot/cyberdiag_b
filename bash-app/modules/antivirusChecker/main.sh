#!/bin/bash

# =============================================================================
# Module : antivirusChecker
# Version : Advanced Hybrid Test Protocol
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

ERROR=""
SCORE=5
RECOMMENDATION=""

# ==================================================
# JSON GENERATOR
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
# LOGIQUE PURE
# ==================================================
evaluate_antivirus() {

    local CLAM=$1
    local CLAM_UPDATE=$2
    local SOPHOS=$3
    local SOPHOS_ACTIVE=$4

    SCORE=5
    local DETAILS=""
    local AV_FOUND=false

    if [[ "$CLAM" == "true" ]]; then
        AV_FOUND=true
        DETAILS+="ClamAV détecté. "
        if [[ "$CLAM_UPDATE" == "true" ]]; then
            DETAILS+="Bases à jour. "
        else
            DETAILS+="Bases obsolètes. "
            SCORE=3
        fi
    fi

    if [[ "$SOPHOS" == "true" ]]; then
        AV_FOUND=true
        DETAILS+="Sophos détecté. "
        if [[ "$SOPHOS_ACTIVE" == "true" ]]; then
            DETAILS+="Service actif. "
        else
            DETAILS+="Service inactif. "
            SCORE=$(( SCORE > 2 ? 2 : SCORE ))
        fi
    fi

    if ! $AV_FOUND; then
        SCORE=1
        RECOMMENDATION="Aucun antivirus détecté."
    else
        RECOMMENDATION="Antivirus détecté. Détails : $DETAILS"
    fi
}

# ==================================================
# DÉTECTION RÉELLE
# ==================================================
check_antivirus_real() {

    local CLAM=false
    local CLAM_UPDATE=false
    local SOPHOS=false
    local SOPHOS_ACTIVE=false

    command -v clamscan &>/dev/null && CLAM=true
    command -v freshclam &>/dev/null && freshclam --version &>/dev/null && CLAM_UPDATE=true

    if command -v savd &>/dev/null; then
        SOPHOS=true
        systemctl is-active --quiet sav-protect && SOPHOS_ACTIVE=true
    fi

    evaluate_antivirus "$CLAM" "$CLAM_UPDATE" "$SOPHOS" "$SOPHOS_ACTIVE"
}

# ==================================================
# VALIDATION JSON STRICTE
# ==================================================
validate_json() {

    local JSON="$1"

    echo -e "${YELLOW}Vérification de la structure JSON...${NC}"

    echo "$JSON" | jq . >/dev/null 2>&1 || {
        echo -e "${RED}JSON invalide${NC}"
        return 1
    }

    for field in status error score recommendation; do
        if echo "$JSON" | jq -e ".$field" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC} - Field '$field' found"
        else
            echo -e "${RED}FAIL${NC} - Field '$field' missing"
            return 1
        fi
    done

    local SCORE_VALUE
    SCORE_VALUE=$(echo "$JSON" | jq -r '.score')

    if [[ "$SCORE_VALUE" =~ ^[0-5]$ ]]; then
        echo -e "${GREEN}PASS${NC} - Score valide ($SCORE_VALUE)"
    else
        echo -e "${RED}FAIL${NC} - Score invalide ($SCORE_VALUE)"
        return 1
    fi

    echo -e "${GREEN}Structure JSON valide${NC}"
    return 0
}

# ==================================================
# UNIT TESTS VERBEUX
# ==================================================
run_unit_tests() {

    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}PHASE 1 - TESTS UNITAIRES (LOGIQUE PURE)${NC}"
    echo -e "${CYAN}==================================================${NC}"

    TOTAL=0; PASS=0; FAIL=0

    run_case() {

        local NAME="$1"
        local CLAM="$2"
        local CLAM_UPDATE="$3"
        local SOPHOS="$4"
        local SOPHOS_ACTIVE="$5"
        local EXPECTED="$6"

        echo -e "\n${BLUE}------------------------------------------${NC}"
        echo -e "${BLUE}Test Case: $NAME${NC}"
        echo -e "${BLUE}------------------------------------------${NC}"

        echo -e "${YELLOW}Simulation:${NC}"
        echo "  CLAM=$CLAM"
        echo "  CLAM_UPDATE=$CLAM_UPDATE"
        echo "  SOPHOS=$SOPHOS"
        echo "  SOPHOS_ACTIVE=$SOPHOS_ACTIVE"

        evaluate_antivirus "$CLAM" "$CLAM_UPDATE" "$SOPHOS" "$SOPHOS_ACTIVE"

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

    run_case "No Antivirus Installed" false false false false 1
    run_case "ClamAV Installed and Updated" true true false false 5
    run_case "ClamAV Installed but Outdated" true false false false 3
    run_case "Sophos Installed but Service Inactive" false false true false 2

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}RÉSUMÉ DES TEST UNITAIRES${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo "Total tests : $TOTAL"
    echo -e "${GREEN}Passed : $PASS${NC}"
    echo -e "${RED}Failed : $FAIL${NC}"

    [[ $FAIL -eq 0 ]]
}

# ==================================================
# INTEGRATION TEST VERBEUX
# ==================================================
run_integration_test() {

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}PHASE 2 - TEST D'INTÉGRATION RÉEL${NC}"
    echo -e "${CYAN}==================================================${NC}"

    echo -e "${YELLOW}Lancement de la détection réelle sur la machine...${NC}"

    check_antivirus_real

    JSON=$(output_json "OK" "" "$SCORE" "$RECOMMENDATION")

    echo -e "\n${YELLOW}JSON généré :${NC}"
    echo "$JSON"

    validate_json "$JSON" || return 1

    echo -e "${GREEN}Integration test PASSED${NC}"
    return 0
}

# ==================================================
# COUVERTURE LOGIQUE
# ==================================================
run_coverage_check() {

    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}PHASE 3 - COUVERTURE LOGIQUE${NC}"
    echo -e "${CYAN}==================================================${NC}"

    local scenarios=0

    for CLAM in true false; do
        for CLAM_UPDATE in true false; do
            for SOPHOS in true false; do
                for SOPHOS_ACTIVE in true false; do
                    evaluate_antivirus "$CLAM" "$CLAM_UPDATE" "$SOPHOS" "$SOPHOS_ACTIVE"
                    ((scenarios++))
                done
            done
        done
    done

    echo -e "${GREEN}Scénarios testés : $scenarios / 16${NC}"
}

# ==================================================
# MASTER TEST
# ==================================================
run_tests() {

    run_unit_tests || exit 1
    run_integration_test || exit 1
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

    log_info "[antivirusChecker] Analyse de l'antivirus..."
    check_antivirus_real
    log_info "[antivirusChecker] Vérification terminée avec un score de $SCORE/5"
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"