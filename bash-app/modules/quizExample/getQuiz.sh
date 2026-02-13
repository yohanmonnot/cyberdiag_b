#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/../.." && pwd)"
QUIZ_FILE="$DIR/quiz.json"

source "$ROOT_DIR/utils/logger.sh"

if [ ! -f "$QUIZ_FILE" ]; then
    log_error "Quiz file not found."
    echo "[]"
fi

RESULT=$(jq '.[] | {index: .index, question: .question, type: .type, options: [.options[].label | select(. != null)]}' "$QUIZ_FILE")

if [ $? -eq 0 ] && [ "$RESULT" != "null" ]; then
    echo "$RESULT"
else
    log_error "Une erreur s'est produite."
    exit 1
fi