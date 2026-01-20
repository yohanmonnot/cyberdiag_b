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
    echo "[]"
    exit 0
fi

# Mapping des filtres vers les champs Java : .reportName et .reportDate
jq -c --arg n "$NAME" --arg d "$DATE" --arg num "$NUMBER" '
  map(select(
    ($n == "" or .reportName == $n) and
    ($d == "" or .reportDate == $d) and
    ($num == "" or .number == ($num | tonumber))
  ))
' "$DB_FILE"