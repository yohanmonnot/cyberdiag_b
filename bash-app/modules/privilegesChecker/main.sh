#!/bin/bash
# =============================================================================
# Module : privilgesChecker
# Description : Vérifie les privilèges système sensibles
# Auteur : Yohan
# =============================================================================

# --- Initialisation ---
STATUS="OK"
ERROR=""
SCORE=5
RECOMMENDATION="Espace disque largement disponible."

ISSUES=0
CHECKS=0

# --- Fonction : sortie JSON (UNE SEULE LIGNE) ---
output_json() {
    jq -c -n \
      --arg status "$STATUS" \
      --arg error "$ERROR" \
      --argjson score "$SCORE" \
      --arg recommendation "$RECOMMENDATION" \
      '{status: $status, error: $error, score: $score, recommendation: $recommendation}'
}

# --- Vérifications ---
run_checks() {

    # 1. Root
    CHECKS=$((CHECKS+1))
    if [[ "$EUID" -ne 0 ]]; then
        ISSUES=$((ISSUES+1))
        STATUS="WARNING"
        RECOMMENDATION="Certaines vérifications nécessitent l'accès root."
    fi

    # 2. sudo
    CHECKS=$((CHECKS+1))
    if ! command -v sudo >/dev/null 2>&1; then
        ISSUES=$((ISSUES+1))
        STATUS="CRITICAL"
        ERROR="Commande sudo introuvable."
        RECOMMENDATION="Installez sudo pour gérer correctement les accès privilégiés."
    fi

    # 3. UID 0 multiples
    CHECKS=$((CHECKS+1))
    UID0_COUNT=$(awk -F: '$3 == 0 {c++} END {print c+0}' /etc/passwd)
    if [[ "$UID0_COUNT" -gt 1 ]]; then
        ISSUES=$((ISSUES+1))
        [[ "$STATUS" != "CRITICAL" ]] && STATUS="WARNING"
    fi

    # 4. sudoers lisible
    CHECKS=$((CHECKS+1))
    if [[ ! -r /etc/sudoers ]]; then
        ISSUES=$((ISSUES+1))
        [[ "$STATUS" != "CRITICAL" ]] && STATUS="WARNING"
    fi
}

# --- Calcul du score ---
calculate_score() {
    (( CHECKS > 0 )) && SCORE=$(( (CHECKS - ISSUES) * 5 / CHECKS ))

    if (( ISSUES == CHECKS )); then
        STATUS="CRITICAL"
    elif (( ISSUES > 0 )) && [[ "$STATUS" != "CRITICAL" ]]; then
        STATUS="WARNING"
    fi
}

# --- Tests internes (mode --test) ---
run_self_tests() {
    echo "============================================="
    echo "Running internal tests (privilgesChecker)"
    echo "============================================="

    local passed=0
    local failed=0

    test_case() {
        local name="$1"
        shift
        if "$@"; then
            echo "PASS - $name"
            ((passed++))
        else
            echo "FAIL - $name"
            ((failed++))
        fi
    }

    # Test 1 : jq disponible
    test_case "jq is available" command -v jq >/dev/null 2>&1

    # Test 2 : output_json retourne du JSON valide
    test_case "output_json returns valid JSON" \
        bash -c 'STATUS="OK"; ERROR=""; SCORE=5; RECOMMENDATION="Test"; output_json | jq . >/dev/null 2>&1'

    # Test 3 : run_checks ne crash pas
    test_case "run_checks executes without crash" run_checks

    # Test 4 : logique du score
    logic_ok=true

    CHECKS=4; ISSUES=0; calculate_score; [[ "$SCORE" -eq 5 ]] || logic_ok=false
    CHECKS=4; ISSUES=1; calculate_score; [[ "$SCORE" -eq 3 ]] || logic_ok=false
    CHECKS=4; ISSUES=2; calculate_score; [[ "$SCORE" -eq 2 ]] || logic_ok=false
    CHECKS=4; ISSUES=4; calculate_score; [[ "$STATUS" == "CRITICAL" ]] || logic_ok=false

    test_case "calculate_score logic" $logic_ok

    echo "---------------------------------------------"
    echo "Total: $((passed+failed)) | Passed: $passed | Failed: $failed"
    echo "---------------------------------------------"

    [[ $failed -eq 0 ]] && echo "All internal tests passed." \
                         || echo "Some internal tests failed."
}

# --- Main ---
if [[ "$1" == "--test" ]]; then
    run_self_tests
    exit 0
fi

run_checks
calculate_score
output_json


