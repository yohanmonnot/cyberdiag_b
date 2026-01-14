#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source "$SCRIPT_DIR/utils/logger.sh"

MODE="gui"
SCRIPT_NAME=""
SCRIPT_ARGS=()
CUSTOM_INTERFACE=""
LIST_FILTER=""
LIST_SORT="name"
MODULES_DIR="./modules"

# Require jq
if ! command -v jq >/dev/null 2>&1; then
    log_error "jq is required but not installed. Install jq and retry."
    exit 1
fi

# Function to list modules (filter by type, sort by name/type/description)
list_modules() {
    local FILTER="$1"
    local SORT_FIELD="$2"
    local MODULES_JSON="[]"

    for d in "$MODULES_DIR"/*/; do
        META="$d/module.json"
        if [[ -f "$META" ]]; then
            NAME=$(jq -r '.name // empty' "$META")
            VERSION=$(jq -r '.version // empty' "$META")
            TYPE=$(jq -r '.type // empty' "$META")
            DESC=$(jq -r '.description // empty' "$META")
            AUTHOR=$(jq -r '.author // empty' "$META")

            if [[ -z "$FILTER" || "$TYPE" == "$FILTER" ]]; then
                MODULE_JSON=$(jq -n \
                    --arg name "$NAME" \
                    --arg version "$VERSION" \
                    --arg type "$TYPE" \
                    --arg description "$DESC" \
                    --arg author "$AUTHOR" \
                    '{name: $name, version: $version, type: $type, description: $description, author: $author}')
                
                MODULES_JSON=$(echo "$MODULES_JSON" | jq ". + [$MODULE_JSON]")
            fi
        fi
    done

    case "$SORT_FIELD" in
        name) SORT_KEY="name" ;;
        type) SORT_KEY="type" ;;
        description) SORT_KEY="description" ;;
        *) SORT_KEY="name" ;;
    esac

    # Trier et afficher en JSON compact (inline)
    echo "$MODULES_JSON" | jq -c "sort_by(.${SORT_KEY})"
}

# Function to run a module by its "name" field in module.json
run_module() {
    local MODULE_NAME="$1"
    shift
    for d in "$MODULES_DIR"/*/; do
        META="$d/module.json"
        if [[ -f "$META" && "$(jq -r '.name' "$META")" == "$MODULE_NAME" ]]; then
            SCRIPT="$d/$(jq -r '.main' "$META")"
            if [[ ! -f "$SCRIPT" ]]; then
                log_error "Script $SCRIPT not found for module $MODULE_NAME"
                return 1
            fi
            log_info "Starting module '$MODULE_NAME'"
            bash "$SCRIPT" "$@"
            log_info "Finished module '$MODULE_NAME'"
            return 0
        fi
    done
    log_error "Module $MODULE_NAME not found."
    return 1
}

# Function to run an interface module by name
run_interface_module() {
    local MODULE_NAME="$1"
    for d in "$MODULES_DIR"/*/; do
        META="$d/module.json"
        if [[ -f "$META" && "$(jq -r '.name' "$META")" == "$MODULE_NAME" ]]; then
            SCRIPT="$d/$(jq -r '.main' "$META")"
            if [[ -f "$SCRIPT" ]]; then
                log_info "Launching interface module '$MODULE_NAME'"
                bash "$SCRIPT" "$@"
                log_info "Finished interface module '$MODULE_NAME'"
                return 0
            else
                log_warn "Interface module script not found: $SCRIPT"
                return 1
            fi
        fi
    done
    log_error "Interface module '$MODULE_NAME' not found."
    return 1
}

# GUI mode (fixed module graphicInterface)
run_gui() {
    run_interface_module "graphicInterface"
}

# CLI mode (fixed module cliInterface)
run_cli() {
    run_interface_module "cliInterface"
}

# SCRIPT mode
run_script() {
    # Cas spécial : list
    if [[ "${SCRIPT_ARGS[0]}" == "list" ]]; then
        log_info "Listing modules with filter='$LIST_FILTER', sort='$LIST_SORT'"
        list_modules "$LIST_FILTER" "$LIST_SORT"
        return 0
    fi

    # Déterminer si le mode test est activé globalement
    local TEST_MODE=false
    local CLEAN_ARGS=()
    for arg in "${SCRIPT_ARGS[@]}"; do
        if [[ "$arg" == "--test" ]]; then
            TEST_MODE=true
        else
            CLEAN_ARGS+=("$arg")
        fi
    done

    # On boucle sur chaque module demandé
    for MODULE_NAME in "${CLEAN_ARGS[@]}"; do
        local MODULE_DIR="$MODULES_DIR/$MODULE_NAME"
        local META_FILE="$MODULE_DIR/module.json"

        if [[ -d "$MODULE_DIR" && -f "$META_FILE" ]]; then
            # 1. Exécution du module
            run_module "$MODULE_NAME"

            # 2. Exécution des tests si le flag était présent
            if [[ "$TEST_MODE" == true ]]; then
                local TEST_SCRIPT
                TEST_SCRIPT=$(jq -r '.test // empty' "$META_FILE" 2>/dev/null)

                if [[ -z "$TEST_SCRIPT" ]]; then
                    TEST_SCRIPT="$MODULE_DIR/test.sh"
                else
                    TEST_SCRIPT="$MODULE_DIR/$TEST_SCRIPT"
                fi

                if [[ -f "$TEST_SCRIPT" ]]; then
                    log_info "Running tests for module '$MODULE_NAME'"
                    bash "$TEST_SCRIPT"
                else
                    log_warn "Test script not found for '$MODULE_NAME': $TEST_SCRIPT"
                fi
            fi
        else
            log_error "Module '$MODULE_NAME' not found (directory or module.json missing)."
        fi
    done
}

# Argument parsing (after functions so variables exist)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cli)
            MODE="cli"
            shift
            ;;
        --gui)
            MODE="gui"
            shift
            ;;
        --script)
            MODE="script"
            shift
            while [[ $# -gt 0 && "$1" != --* ]]; do
                SCRIPT_ARGS+=("$1")
                shift
            done
            ;;
        --interface)
            shift
            CUSTOM_INTERFACE="$1"
            shift
            ;;
        --filter)
            shift
            LIST_FILTER="$1"
            shift
            ;;
        --sort)
            shift
            LIST_SORT="$1"
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            log_info "Usage: $0 [--gui|--cli] [--script arg1 arg2 ...] [--interface module_name] [--filter type] [--sort field]"
            exit 1
            ;;
    esac
done

# Execute custom interface if specified
if [[ -n "$CUSTOM_INTERFACE" ]]; then
    run_interface_module "$CUSTOM_INTERFACE"
    exit $?
fi

# Main execution based on mode
case "$MODE" in
    gui)    run_gui ;;
    cli)    run_cli ;;
    script) run_script ;;
    *)      log_error "Unknown mode: $MODE"; exit 1 ;;
esac
