#!/bin/bash

source "$(dirname "$0")/../../utils/logger.sh"

JAR_PATH="$(dirname "$0")/java-ui-1.0.jar"

if [ ! -f "$JAR_PATH" ]; then
    log_error "JavaFX jar not found. Please build the JavaFX project first."
    exit 1
fi

log_info "Launching JavaFX GUI from $JAR_PATH"
java -jar "$JAR_PATH" "$@"
log_info "JavaFX GUI finished"