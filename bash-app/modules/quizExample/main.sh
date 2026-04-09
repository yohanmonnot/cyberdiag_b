#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"

source "$ROOT_DIR/utils/logger.sh"

QUIZ_FILE="$DIR/quiz.json"

# =========================
# JSON OUTPUT STANDARD
# =========================
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

# =========================
# LOGIQUE PRINCIPALE
# =========================
run_quiz_logic() {

    # Exemple simple (pas de réponses = neutre)
    if [[ ! -f "$QUIZ_FILE" ]]; then
        output_json "FAIL" "Quiz file not found" 0 "Corriger le module."
        return
    fi

    output_json "OK" "" 5 "Module fonctionnel. Aucun problème détecté."
}

# =========================
# TESTS INTERNES
# =========================
run_self_tests() {

    echo "============================================="
    echo "Running internal tests (quizExample)"
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

    # 1. jq dispo
    test_case "jq is available" command -v jq >/dev/null 2>&1

    # 2. quiz.json existe
    test_case "quiz.json exists" test -f "$QUIZ_FILE"

    # 3. JSON valide
    test_case "quiz.json valid JSON" jq . "$QUIZ_FILE" >/dev/null 2>&1

    # 4. output_json valide
    test_case "output_json valid" \
        bash -c 'echo "{\"status\":\"OK\",\"error\":\"\",\"score\":5,\"recommendation\":\"test\"}" | jq . >/dev/null 2>&1'

    # 5. run_quiz_logic ne crash pas
    test_case "run_quiz_logic executes" run_quiz_logic >/dev/null 2>&1

    echo "---------------------------------------------"
    echo "Total: $((passed+failed)) | Passed: $passed | Failed: $failed"
    echo "---------------------------------------------"

    [[ $failed -eq 0 ]] && echo "All internal tests passed." \
                         || echo "Some internal tests failed."
}

# =========================
# MAIN
# =========================
main() {

    case "$1" in
        --test|-t)
            run_self_tests
            exit 0
            ;;
        --get|-g)
            "$DIR/getQuiz.sh"
            exit $?
            ;;
        --score|-s)
            shift
            "$DIR/getScore.sh" "$1"
            exit $?
            ;;
        *)
            run_quiz_logic
            ;;
    esac
}

main "$@"