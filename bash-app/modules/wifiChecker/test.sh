#!/bin/bash

# Couleurs ANSI
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

MODULE_DIR="$(cd "$(dirname "$0")" && pwd)"
META_FILE="$MODULE_DIR/module.json"

# Lecture des chemins dans module.json
MAIN_SCRIPT=$(jq -r '.main // empty' "$META_FILE")
TEST_SCRIPT=$(jq -r '.test // empty' "$META_FILE")
MODULE_NAME=$(jq -r '.name // "unknown"' "$META_FILE")

if [[ -z "$MAIN_SCRIPT" ]]; then
    echo -e "${RED}[ERREUR]${RESET} Champ 'main' manquant dans module.json"
    exit 1
fi

MAIN_SCRIPT_PATH="$MODULE_DIR/$MAIN_SCRIPT"

echo -e "\n==========================================="
echo -e "Running unit tests for module: ${MODULE_NAME}"
echo -e "==========================================="

# Vérifie que le script principal existe
if [[ ! -f "$MAIN_SCRIPT_PATH" ]]; then
    echo -e "${RED}FAIL${RESET} - Script principal introuvable : $MAIN_SCRIPT_PATH"
    exit 1
fi

# Exécute le module et capture la sortie JSON
echo -e "${YELLOW}Lancement du module :${RESET} $MAIN_SCRIPT_PATH"
OUTPUT=$(bash "$MAIN_SCRIPT_PATH")
EXIT_CODE=$?

echo -e "\n${YELLOW}Sortie du module :${RESET}"
echo "$OUTPUT"

if [[ $EXIT_CODE -ne 0 ]]; then
    echo -e "\n${RED}FAIL${RESET} - Le module s'est terminé avec un code d'erreur ($EXIT_CODE)"
    exit 1
fi

# Extraction du JSON (dernière ligne commençant par '{')
JSON_OUTPUT=$(echo "$OUTPUT" | grep -oP '^\{.*\}$' | tail -n1)

if [[ -z "$JSON_OUTPUT" ]]; then
    echo -e "\n${RED}FAIL${RESET} - Aucune sortie JSON trouvée."
    exit 1
fi

# Vérifie les champs attendus
FIELDS=("status" "error" "score" "recommendation")
PASSED=0
FAILED=0

echo -e "\n${YELLOW}Vérification des champs JSON...${RESET}"
for field in "${FIELDS[@]}"; do
    if echo "$JSON_OUTPUT" | grep -q "\"$field\""; then
        echo -e "${GREEN}PASS${RESET} - Field '$field' found"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${RESET} - Field '$field' missing"
        ((FAILED++))
    fi
done

# Résumé final
echo -e "-------------------------------------------"
echo -e "${CYAN}Total:${RESET} ${#FIELDS[@]} | ${GREEN}Passed:${RESET} $PASSED | ${RED}Failed:${RESET} $FAILED"
echo -e "-------------------------------------------"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}Tous les tests ont réussi.${RESET}"
else
    echo -e "${RED}Des tests ont échoué.${RESET}"
fi
