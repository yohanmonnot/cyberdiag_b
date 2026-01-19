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

if [ -z "$NAME" ] && [ -z "$DATE" ] && [ -z "$NUMBER" ]; then
    log_error "You must provide at least one filter (--name, --date, or --number) to remove a report."
    exit 1
fi

jq --arg n "$NAME" --arg d "$DATE" --arg num "$NUMBER" '
  map(select(
    (if $n == "" then true else .name == $n end) and
    (if $d == "" then true else .date == $d end) and
    (if $num == "" then true else .number == ($num | tonumber) end)
  | not))
' "$DB_FILE" > "$DB_FILE.tmp" && mv "$DB_FILE.tmp" "$DB_FILE"

log_info "Report(s) removed successfully."