#!/bin/bash

# =========================
# Couleurs
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

MODULES_DIR="./modules"

# Modules à exclure
EXCLUDED_MODULES=("cliInterface" "diagTest" "graphicInterface" "reports")

FAILED_MODULES=()
GLOBAL_FAILED=0

is_excluded() {
    local module="$1"
    for excluded in "${EXCLUDED_MODULES[@]}"; do
        if [[ "$module" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

echo -e "${CYAN}===========================================${NC}"
echo -e "${CYAN}Validation globale des modules CyberDiag${NC}"
echo -e "${CYAN}===========================================${NC}"

for d in "$MODULES_DIR"/*/; do

    META="$d/module.json"
    [[ ! -f "$META" ]] && continue

    MODULE_NAME=$(jq -r '.name' "$META")

    if is_excluded "$MODULE_NAME"; then
        echo -e "${YELLOW}SKIP - Module exclu : $MODULE_NAME${NC}"
        continue
    fi

    MAIN_SCRIPT=$(jq -r '.main' "$META")
    SCRIPT_PATH="$d/$MAIN_SCRIPT"

    echo ""
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}Running unit tests for module: $MODULE_NAME${NC}"
    echo -e "${BLUE}===========================================${NC}"

    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo -e "${RED}FAIL - Script introuvable${NC}"
        FAILED_MODULES+=("$MODULE_NAME")
        GLOBAL_FAILED=1
        continue
    fi

    echo -e "${CYAN}Lancement du module : $SCRIPT_PATH${NC}"
    echo ""

    OUTPUT=$(bash "$SCRIPT_PATH" 2>&1)
    EXIT_CODE=$?

    echo -e "${CYAN}Sortie du module :${NC}"
    echo "$OUTPUT"
    echo ""

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo -e "${RED}FAIL - Code retour ≠ 0${NC}"
        FAILED_MODULES+=("$MODULE_NAME")
        GLOBAL_FAILED=1
        continue
    fi

    JSON_OUTPUT=$(echo "$OUTPUT" | grep -oP '^\{.*\}$' | tail -n1)

    if [[ -z "$JSON_OUTPUT" ]]; then
        echo -e "${RED}FAIL - Aucun JSON détecté${NC}"
        FAILED_MODULES+=("$MODULE_NAME")
        GLOBAL_FAILED=1
        continue
    fi

    echo -e "${CYAN}Vérification des champs JSON...${NC}"

    REQUIRED_FIELDS=("status" "error" "score" "recommendation")

    PASSED=0
    FAILED=0

    for field in "${REQUIRED_FIELDS[@]}"; do
        if echo "$JSON_OUTPUT" | jq -e ".$field" >/dev/null 2>&1; then
            echo -e "${GREEN}PASS${NC} - Field '$field' found"
            ((PASSED++))
        else
            echo -e "${RED}FAIL${NC} - Field '$field' missing"
            ((FAILED++))
        fi
    done

    SCORE=$(echo "$JSON_OUTPUT" | jq -r '.score')
    STATUS=$(echo "$JSON_OUTPUT" | jq -r '.status')

    if ! [[ "$SCORE" =~ ^[0-5]$ ]]; then
        echo -e "${RED}FAIL${NC} - Score invalide ($SCORE)"
        ((FAILED++))
    fi

    if [[ "$STATUS" != "OK" && "$STATUS" != "FAIL" ]]; then
        echo -e "${RED}FAIL${NC} - Status invalide ($STATUS)"
        ((FAILED++))
    fi

    TOTAL=$((PASSED + FAILED))

    echo -e "${CYAN}-------------------------------------------${NC}"
    echo -e "Total: $TOTAL | ${GREEN}Passed: $PASSED${NC} | ${RED}Failed: $FAILED${NC}"
    echo -e "${CYAN}-------------------------------------------${NC}"

    if [[ $FAILED -ne 0 ]]; then
        echo -e "${RED}Tests échoués pour $MODULE_NAME${NC}"
        FAILED_MODULES+=("$MODULE_NAME")
        GLOBAL_FAILED=1
    else
        echo -e "${GREEN}Tous les tests ont réussi.${NC}"
    fi

done

echo ""
echo -e "${CYAN}===========================================${NC}"
echo -e "${CYAN}Résumé global${NC}"
echo -e "${CYAN}===========================================${NC}"

if [[ ${#FAILED_MODULES[@]} -ne 0 ]]; then
    echo -e "${RED}Certains tests ont échoué : ${FAILED_MODULES[*]}${NC}"
    exit 1
else
    echo -e "${GREEN}Tous les modules sont valides.${NC}"
    exit 0
fi