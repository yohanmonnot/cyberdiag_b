#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"

source "$ROOT_DIR/utils/logger.sh"

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

# Dispatcher
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
        log_error "Invalid argument or no argument provided."
        show_help
        exit 1
        ;;
esac