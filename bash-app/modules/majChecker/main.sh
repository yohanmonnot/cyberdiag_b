#!/bin/bash

# --- CyberDiag main.sh ---
# Script principal pour gérer les modules de CyberDiag

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# --- Affichage d'aide ---
show_help() {
    cat << EOF
CyberDiag - Guide d'utilisation
Syntaxe : ./main.sh [MODE] [OPTIONS]

Modes :
  --gui               Lance l'interface graphique JavaFX
  --cli               Lance l'interface textuelle interactive
  --test              Parcourt tous les modules et exécute les tests
  --script <module>   Exécute un module spécifique

Options pour --script :
  list                Affiche la liste des modules disponibles (JSON)
  --filter <type>     Filtre les modules par catégorie
  --sort <field>      Trie les modules par name, type ou description

Exemples :
  ./main.sh --test
  ./main.sh --script majChecker
  ./main.sh --script list --filter maintenance
EOF
}

# --- Variables par défaut ---
MODE="--gui"
MODULE=""
FILTER=""
SORT_FIELD=""

# --- Lecture des arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --gui|--cli|--test)
            MODE="$1"
            shift
            ;;
        --script)
            MODE="--script"
            MODULE="$2"
            shift 2
            ;;
        --filter)
            FILTER="$2"
            shift 2
            ;;
        --sort)
            SORT_FIELD="$2"
            shift 2
            ;;
        *)
            echo "Option inconnue : $1"
            show_help
            exit 1
            ;;
    esac
done

# --- Fonction : lister les modules ---
list_modules() {
    local modules_json="[]"
    for module_dir in "$MODULES_DIR"/*; do
        if [[ -f "$module_dir/module.json" ]]; then
            local module_json
            module_json=$(cat "$module_dir/module.json")
            modules_json=$(echo "$modules_json" | jq ". + [$module_json]")
        fi
    done

    # Filtrage si demandé
    if [[ -n "$FILTER" ]]; then
        modules_json=$(echo "$modules_json" | jq "[.[] | select(.type == \"$FILTER\")]")
    fi

    # Tri si demandé
    if [[ -n "$SORT_FIELD" ]]; then
        modules_json=$(echo "$modules_json" | jq "sort_by(.$SORT_FIELD)")
    fi

    echo "$modules_json"
}

# --- Fonction : menu CLI interactif ---
cli_menu() {
    echo "=== CyberDiag CLI ==="
    echo "Modules disponibles :"
    list_modules | jq -r '.[] | "\(.name) - \(.description)"'

    echo ""
    read -p "Entrez le nom du module à exécuter : " chosen
    MODULE_PATH="$MODULES_DIR/$chosen/run.sh"
    if [[ -f "$MODULE_PATH" ]]; then
        bash "$MODULE_PATH"
    else
        echo "Module inconnu : $chosen"
        exit 1
    fi
}

# --- Fonction : exécuter tous les modules (test / CI) ---
run_all_modules() {
    local error_flag=0
    for module_dir in "$MODULES_DIR"/*; do
        if [[ -f "$module_dir/run.sh" ]]; then
            echo "[main] Exécution du module $(basename $module_dir)"
            bash "$module_dir/run.sh" || error_flag=1
        fi
    done
    return $error_flag
}

# --- Execution selon le mode ---
case "$MODE" in
    --gui)
        echo "[main] Lancement de l'interface graphique JavaFX..."
        # java -jar interface.jar
        ;;
    --cli)
        cli_menu
        ;;
    --test)
        echo "[main] Mode test : exécution de tous les modules..."
        run_all_modules || exit 1
        ;;
    --script)
        if [[ "$MODULE" == "list" ]]; then
            list_modules
        else
            MODULE_PATH="$MODULES_DIR/$MODULE/run.sh"
            if [[ -f "$MODULE_PATH" ]]; then
                bash "$MODULE_PATH"
            else
                echo "Module inconnu : $MODULE"
                exit 1
            fi
        fi
        ;;
esac
