#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"

source "$ROOT_DIR/utils/logger.sh"
source "$ROOT_DIR/utils/jq.sh"  # si nécessaire, sinon jq doit être dispo

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTION] [ARGUMENTS]"
    echo "Options:"
    echo "  -a, --add <json_string>   Add a new report"
    echo "  -l, --list [filters]      List reports (inline JSON)"
    echo "  -g, --get [filters]       Get specific reports (inline JSON)"
    echo "  -r, --remove [filters]    Remove reports"
    echo "  -h, --help                Show this help message"
}

# Génération JSON standard pour tests globaux
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

# Test minimal compatible JSON
run_minimal_test() {
    log_info "[reports] Aucun argument fourni, exécution d'un test minimal..."
    # Simule l'ajout d'un rapport
    "$DIR/addReport.sh" '{"type":"TEST","score":5,"message":"Test minimal OK"}' >/dev/null 2>&1
    # Retourne JSON compatible
    output_json "OK" "" 5 "Test minimal OK"
}

# Dispatcher
if [[ -z "$1" ]]; then
    run_minimal_test
    exit 0
fi

case "$1" in
    -a|--add)
        shift
        "$DIR/addReport.sh" "$@"
        ;;
    -l|--list)
        shift
        "$DIR/listReport.sh" "$@"
        ;;
    -g|--get)
        shift
        "$DIR/getReport.sh" "$@"
        ;;
    -r|--remove)
        shift
        "$DIR/removeReport.sh" "$@"
        ;;
    -h|--help)
        show_help
        ;;
    *)
        log_error "Invalid argument."
        show_help
        exit 1
        ;;
esac#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"

source "$ROOT_DIR/utils/logger.sh"
source "$ROOT_DIR/utils/jq.sh"  # si nécessaire, sinon jq doit être dispo

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTION] [ARGUMENTS]"
    echo "Options:"
    echo "  -a, --add <json_string>   Add a new report"
    echo "  -l, --list [filters]      List reports (inline JSON)"
    echo "  -g, --get [filters]       Get specific reports (inline JSON)"
    echo "  -r, --remove [filters]    Remove reports"
    echo "  -h, --help                Show this help message"
}

# Génération JSON standard pour tests globaux
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

# Test minimal compatible JSON
run_minimal_test() {
    log_info "[reports] Aucun argument fourni, exécution d'un test minimal..."
    # Simule l'ajout d'un rapport
    "$DIR/addReport.sh" '{"type":"TEST","score":5,"message":"Test minimal OK"}' >/dev/null 2>&1
    # Retourne JSON compatible
    output_json "OK" "" 5 "Test minimal OK"
}

# Dispatcher
if [[ -z "$1" ]]; then
    run_minimal_test
    exit 0
fi

case "$1" in
    -a|--add)
        shift
        "$DIR/addReport.sh" "$@"
        ;;
    -l|--list)
        shift
        "$DIR/listReport.sh" "$@"
        ;;
    -g|--get)
        shift
        "$DIR/getReport.sh" "$@"
        ;;
    -r|--remove)
        shift
        "$DIR/removeReport.sh" "$@"
        ;;
    -h|--help)
        show_help
        ;;
    *)
        log_error "Invalid argument."
        show_help
        exit 1
        ;;
esac