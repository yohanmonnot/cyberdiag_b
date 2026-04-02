#!/bin/bash

# --- Couleurs ANSI ---
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

# --- Chemins ---
MODULE_DIR="$(cd "$(dirname "$0")" && pwd)"
META_FILE="$MODULE_DIR/module.json"

# --- Lecture module.json ---
MODULE_NAME=$(jq -r '.name // "unknown"' "$META_FILE")
MAIN_SCRIPT=$(jq -r '.main // empty' "$META_FILE")

if [[ -z "$MAIN_SCRIPT" ]]; then
    echo -e "${RED}[ERREUR]${RESET} Champ 'main' manquant dans module.json"
    exit 1
fi

MAIN_SCRIPT_PATH="$MODULE_DIR/$MAIN_SCRIPT"

echo -e "\n==========================================="
echo -e "Tests unitaires du module : ${MODULE_NAME}"
echo -e "===========================================\n"

# --- Vérification du script principal ---
if [[ ! -f "$MAIN_SCRIPT_PATH" ]]; then
    echo -e "${RED}FAIL${RESET} - Script principal introuvable : $MAIN_SCRIPT_PATH"
    exit 1
fi

# --- Exécution du module ---
echo -e "${YELLOW}Lancement du module :${RESET} $MAIN_SCRIPT_PATH"
OUTPUT=$(bash "$MAIN_SCRIPT_PATH")
EXIT_CODE=$?

echo -e "\n${YELLOW}Sortie brute :${RESET}"
echo "$OUTPUT"

if [[ $EXIT_CODE -ne 0 ]]; then
    echo -e "\n${RED}FAIL${RESET} - Code de sortie non nul ($EXIT_CODE)"
    exit 1
fi

# --- Extraction JSON ---
JSON_OUTPUT=$(echo "$OUTPUT" | grep -oP '^\{.*\}$' | tail -n1)

if [[ -z "$JSON_OUTPUT" ]]; then
    echo -e "\n${RED}FAIL${RESET} - Aucune sortie JSON détectée"
    exit 1
fi

# --- Champs attendus pour majChecker ---
FIELDS=("status" "error" "score" "recommendation" "updates")
PASSED=0
FAILED=0

echo -e "\n${YELLOW}Vérification des champs JSON :${RESET}"
for field in "${FIELDS[@]}"; do
    if echo "$JSON_OUTPUT" | jq -e ".${field}" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${RESET} - Champ '$field' présent"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${RESET} - Champ '$field' manquant"
        ((FAILED++))
    fi
done

# --- Vérification du status ---
STATUS=$(echo "$JSON_OUTPUT" | jq -r '.status')
if [[ "$STATUS" == "OK" || "$STATUS" == "FAIL" ]]; then
    echo -e "${GREEN}PASS${RESET} - Status valide ($STATUS)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${RESET} - Status invalide"
    ((FAILED++))
fi

# --- Vérification du score ---
SCORE=$(echo "$JSON_OUTPUT" | jq -r '.score')
if [[ "$SCORE" =~ ^[1-5]$ ]]; then
    echo -e "${GREEN}PASS${RESET} - Score valide ($SCORE)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${RESET} - Score invalide"
    ((FAILED++))
fi

# --- Vérification updates ---
UPDATES=$(echo "$JSON_OUTPUT" | jq -r '.updates')
if [[ "$UPDATES" =~ ^[0-9]+$ ]]; then
    echo -e "${GREEN}PASS${RESET} - Updates est un entier ($UPDATES)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${RESET} - Updates invalide"
    ((FAILED++))
fi

# --- Résumé ---
TOTAL=$(( ${#FIELDS[@]} + 3 ))

echo -e "\n-------------------------------------------"
echo -e "${CYAN}Total:${RESET} $TOTAL | ${GREEN}Passed:${RESET} $PASSED | ${RED}Failed:${RESET} $FAILED"
echo -e "-------------------------------------------"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}Tous les tests ont réussi.${RESET}"
    exit 0
else
    echo -e "${RED}Des tests ont échoué.${RESET}"
    exit 1
fi
