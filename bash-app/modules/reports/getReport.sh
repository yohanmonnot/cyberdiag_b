#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"
DB_FILE="$DIR/reports.json"

source "$ROOT_DIR/utils/logger.sh"

NAME=""
DATE=""
NUMBER=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) NAME="$2"; shift ;;
        --date) DATE="$2"; shift ;;
        --number) NUMBER="$2"; shift ;;
        *) log_error "Unknown filter: $1"; exit 1 ;;
    esac
    shift
done

if [ ! -f "$DB_FILE" ]; then
    log_error "Database not found."
    exit 1
fi

RESULT=$(jq -c -e --arg n "$NAME" --arg d "$DATE" --arg num "$NUMBER" '
  map(select(
    ($n == "" or .name == $n) and
    ($d == "" or .date == $d) and
    ($num == "" or .number == ($num | tonumber))
  )) | first
' "$DB_FILE")

if [ $? -eq 0 ] && [ "$RESULT" != "null" ]; then
    echo "$RESULT"
else
    log_error "No report found matching criteria."
    exit 1
fi