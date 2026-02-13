#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"

source "$ROOT_DIR/utils/logger.sh"

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTION] [ARGUMENTS]"
    echo "Options:"
    printf "  -g, --get       \t\t Get quiz questions\n"
    printf "  -s, --score [responsesJSON] \t\t Get score with quiz responses. format: [{\"index\":0, \"type\": \"choice|number\" \"response\":\"A\"}, ...]\n"
    printf "  -h, --help      \t\t Show this help message\n"
}

case $1 in
    -g|--get)
        shift
        "$DIR/getQuiz.sh" "$@"
        ;;
    -s|--score)
        shift
        "$DIR/getScore.sh" "$@"
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