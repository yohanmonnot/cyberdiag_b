#!/bin/bash

MODULE_DIR="$(dirname "$0")"
MODULE_NAME="wifiChecker"

echo "==========================================="
echo "  Running unit tests for module: $MODULE_NAME"
echo "==========================================="

# Exécute le module et capture la sortie
OUTPUT=$(bash "$MODULE_DIR/main.sh" --script "$MODULE_NAME")

echo "🔹 Module output:"
echo "$OUTPUT"

# Extraire uniquement la dernière ligne JSON (celle qui commence par '{' et finit par '}')
JSON_OUTPUT=$(echo "$OUTPUT" | grep -oP '^\{.*\}$' | tail -n1)

if [[ -z "$JSON_OUTPUT" ]]; then
    echo "✗ FAIL - No JSON output found"
    exit 1
fi

FIELDS=("status" "error" "score" "recommendation")
PASSED=0
FAILED=0

for field in "${FIELDS[@]}"; do
    if echo "$JSON_OUTPUT" | grep -q "\"$field\""; then
        echo "✔ PASS - Field '$field' found"
        ((PASSED++))
    else
        echo "✗ FAIL - Field '$field' missing"
        ((FAILED++))
    fi
done

echo "-------------------------------------------"
echo "Total: ${#FIELDS[@]} | Passed: $PASSED | Failed: $FAILED"
echo "-------------------------------------------"

if [[ $FAILED -eq 0 ]]; then
    echo "✅ All tests passed."
else
    echo "❌ Some tests failed."
fi
