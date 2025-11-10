#!/bin/bash

# --- Mode verbeux global ---
VERBOSE=false
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "-v" ]]; then
        VERBOSE=true
    else
        ARGS+=("$arg")
    fi
done
set -- "${ARGS[@]}"
export VERBOSE

source "$(dirname "$0")/utils/logger.sh"

MODE="gui"
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
    local modules_json="[]"

    for d in "$MODULES_DIR"/*/; do
        local META="$d/module.json"
        if [[ -f "$META" ]]; then
            local NAME=$(jq -r '.name // empty' "$META")
            local TYPE=$(jq -r '.type // empty' "$META")
            local DESC=$(jq -r '.description // empty' "$META")

            if [[ -z "$FILTER" || "$TYPE" == "$FILTER" ]]; then
                modules_json=$(echo "$modules_json" | jq -c --arg name "$NAME" --arg type "$TYPE" --arg description "$DESC" \
                    '. += [{"name": $name, "type": $type, "description": $description}]')
            fi
        fi
    done

    # Tri selon le champ demandé
    case "$SORT_FIELD" in
        name) modules_json=$(echo "$modules_json" | jq -c 'sort_by(.name)') ;;
        type) modules_json=$(echo "$modules_json" | jq -c 'sort_by(.type)') ;;
        description) modules_json=$(echo "$modules_json" | jq -c 'sort_by(.description)') ;;
        *) modules_json=$(echo "$modules_json" | jq -c 'sort_by(.name)') ;;
    esac

    echo "$modules_json"
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
    if [[ ${#SCRIPT_ARGS[@]} -eq 0 ]]; then
        log_warn "No arguments passed for --script"
        return
    fi

    if [[ "${SCRIPT_ARGS[0]}" == "list" ]]; then
        log_info "Listing modules with filter='$LIST_FILTER', sort='$LIST_SORT'"
        list_modules "$LIST_FILTER" "$LIST_SORT"
        return
    fi

    local MODULE_NAME="${SCRIPT_ARGS[0]}"
    local MODULE_DIR="$MODULES_DIR/$MODULE_NAME"
    local TEST_MODE=false

    # Vérifie la présence du flag --test
    for arg in "${SCRIPT_ARGS[@]:1}"; do
        if [[ "$arg" == "--test" ]]; then
            TEST_MODE=true
        fi
    done

    if [[ "$TEST_MODE" == true ]]; then
        local TEST_SCRIPT="$MODULE_DIR/test.sh"
        if [[ -f "$TEST_SCRIPT" ]]; then
            log_info "Running tests for module '$MODULE_NAME'"
            bash "$TEST_SCRIPT"
        else
            log_error "No test.sh found for module '$MODULE_NAME'"
        fi
        return
    fi

    # Sinon, exécution normale
    for MODULE in "${SCRIPT_ARGS[@]}"; do
        run_module "$MODULE"
    done
}


# Argument parsing (after functions so variables exist)
echo "🔍 [DEBUG] Arguments bruts reçus : $@"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v)
            # déjà géré, on peut l'ignorer
            shift
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
            # Collecte tous les arguments jusqu'au prochain flag global connu
            while [[ $# -gt 0 && "$1" != "--cli" && "$1" != "--gui" && "$1" != "--interface" && "$1" != "--filter" && "$1" != "--sort" ]]; do
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
            log_info "Usage: $0 [-v] [--gui|--cli] [--script arg1 arg2 ...] [--interface module_name] [--filter type] [--sort field]"
            exit 1
            ;;
    esac
done

# Execute custom interface if specified
if [[ -n "$CUSTOM_INTERFACE" ]]; then
    run_interface_module "$CUSTOM_INTERFACE"
    exit $?
fi


# --- Debug: état des variables après parsing ---
echo "🔧 [DEBUG] Mode sélectionné : $MODE"
echo "🔧 [DEBUG] Arguments de script : ${SCRIPT_ARGS[*]}"
echo "🔧 [DEBUG] Interface personnalisée : $CUSTOM_INTERFACE"
echo "🔧 [DEBUG] Filtre de liste : $LIST_FILTER"
echo "🔧 [DEBUG] Tri de liste : $LIST_SORT"
echo "🔧 [DEBUG] Mode verbeux : $VERBOSE"

# Main execution based on mode
case "$MODE" in
    gui)    run_gui ;;
    cli)    run_cli ;;
    script) run_script ;;
    *)      log_error "Unknown mode: $MODE"; exit 1 ;;
esac
