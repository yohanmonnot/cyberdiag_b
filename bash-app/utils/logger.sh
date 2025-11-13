#!/bin/bash

LOG_FILE="./logs/app.log"
VERBOSE="${VERBOSE:-false}"

mkdir -p "$(dirname "$LOG_FILE")"

_log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" >> "$LOG_FILE"

    if [[ "$VERBOSE" == "true" ]]; then
        echo "[$TIMESTAMP] [$LEVEL] $MESSAGE"
    fi
}

log_info() {
    _log "INFO" "$@"
}

log_warn() {
    _log "WARN" "$@"
}

log_error() {
    _log "ERROR" "$@"
}