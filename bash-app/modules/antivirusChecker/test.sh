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

# Vérifie les champs attendus selon le module.json de malwareChecker
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

# Vérifie que le score est un nombre entre 1 et 5
SCORE=$(echo "$JSON_OUTPUT" | jq -r '.score')
if [[ "$SCORE" =~ ^[1-5]$ ]]; then
    echo -e "${GREEN}PASS${RESET} - Score est un nombre valide (1-5)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${RESET} - Score n'est pas un nombre valide (1-5)"
    ((FAILED++))
fi

# Vérifie que le status est soit "OK" soit "FAIL"
STATUS=$(echo "$JSON_OUTPUT" | jq -r '.status')
if [[ "$STATUS" == "OK" || "$STATUS" == "FAIL" ]]; then
    echo -e "${GREEN}PASS${RESET} - Status est valide (OK/FAIL)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${RESET} - Status n'est pas valide (doit être OK ou FAIL)"
    ((FAILED++))
fi

# Résumé final
echo -e "-------------------------------------------"
echo -e "${CYAN}Total:${RESET} $(( ${#FIELDS[@]} + 2 )) | ${GREEN}Passed:${RESET} $PASSED | ${RED}Failed:${RESET} $FAILED"
echo -e "-------------------------------------------"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}Tous les tests ont réussi.${RESET}"
else
    echo -e "${RED}Des tests ont échoué.${RESET}"
fi
