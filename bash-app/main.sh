#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être lancé en tant que root (sudo)"
   exit 1
fi

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
        local META="$d/module.json"
        if [[ -f "$META" && "$(jq -r '.name' "$META")" == "$MODULE_NAME" ]]; then

            # --- VÉRIFICATION DES DÉPENDANCES ---
            local DEPS
            DEPS=$(jq -r '.dependencies[] // empty' "$META")
            for dep in $DEPS; do
                if ! command -v "$dep" >/dev/null 2>&1; then
                    log_error "Dépendance manquante pour le module '$MODULE_NAME' : '$dep'"
                    log_info "Veuillez installer '$dep' pour utiliser ce module."
                    return 1
                fi
            done
            # ------------------------------------

            local SCRIPT="$d/$(jq -r '.main' "$META")"
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
    if [[ "$SCRIPT_NAME" == "list" ]]; then
        log_info "Listing modules with filter='$LIST_FILTER', sort='$LIST_SORT'"
        list_modules "$LIST_FILTER" "$LIST_SORT"
        return 0
    fi

    if [[ -n "$SCRIPT_NAME" ]]; then
        # On vérifie si le module existe avant de lancer
        local MODULE_DIR="$MODULES_DIR/$SCRIPT_NAME"
        local META_FILE="$MODULE_DIR/module.json"

        if [[ -d "$MODULE_DIR" && -f "$META_FILE" ]]; then
            # On passe SCRIPT_ARGS (@) au module
            run_module "$SCRIPT_NAME" "${SCRIPT_ARGS[@]}"
        else
            log_error "Module '$SCRIPT_NAME' not found."
            exit 1
        fi
    else
        log_error "No module specified."
        exit 1
    fi
}

run_all_tests() {
    log_info "Démarrage des tests globaux des modules..."

    if [[ ! -f "$SCRIPT_DIR/utils/test_modules.sh" ]]; then
        log_error "Script utils/test_modules.sh introuvable."
        exit 1
    fi

    bash "$SCRIPT_DIR/utils/test_modules.sh"
    EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        log_error "Certains modules sont invalides."
        exit 1
    fi

    log_info "Tous les modules sont valides."
}

# Argument parsing (after functions so variables exist)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --test)
            run_all_tests
            exit 0
            ;;
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

            if [[ $# -gt 0 ]]; then
                SCRIPT_NAME="$1"
                shift
            fi

            while [[ $# -gt 0 ]]; do
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
            log_info "Usage: $0 [--gui|--cli|--test] [--script arg1 arg2 ...] [--interface module_name] [--filter type] [--sort field]"
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
