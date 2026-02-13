#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"
DB_FILE="$DIR/reports.json"

source "$ROOT_DIR/utils/logger.sh"

if [ -z "$1" ]; then
    log_error "No JSON data provided."
    exit 1
fi

INPUT_JSON="$1"

# Validation JSON
if ! echo "$INPUT_JSON" | jq empty > /dev/null 2>&1; then
    log_error "Invalid JSON format."
    exit 1
fi

# Gestion de la Date (Mappée sur 'reportDate')
PROVIDED_DATE=$(echo "$INPUT_JSON" | jq -r '.reportDate // empty')

if [ -z "$PROVIDED_DATE" ]; then
    FINAL_DATE=$(date "+%Y-%m-%d %H:%M:%S")
else
    # Regex strict correspondant à la classe Java (YYYY-MM-DD HH:MM:SS)
    if [[ ! "$PROVIDED_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        log_error "Date format must be 'YYYY-MM-DD HH:MM:SS'. Provided: $PROVIDED_DATE"
        exit 1
    fi
    FINAL_DATE="$PROVIDED_DATE"
fi

# Initialisation DB
if [ ! -f "$DB_FILE" ] || [ ! -s "$DB_FILE" ]; then
    echo "[]" > "$DB_FILE"
fi

# Calcul Auto-increment (Basé sur 'reportDate')
NEXT_NUM=$(jq --arg d "$FINAL_DATE" '
  map(select(.reportDate == $d))
  | map(.number)
  | max // -1
  | . + 1
' "$DB_FILE")

# Écriture (On injecte 'reportDate' et 'number')
jq --argjson input "$INPUT_JSON" --arg d "$FINAL_DATE" --argjson n "$NEXT_NUM" '
  . += [$input + {reportDate: $d, number: $n}]
' "$DB_FILE" > "$DB_FILE.tmp" && mv "$DB_FILE.tmp" "$DB_FILE"

log_info "Report added successfully: $FINAL_DATE (ID: $NEXT_NUM)"