#!/bin/bash

APPROOT="$(cd "$(dirname "$0")/../../" && pwd)"
source "$APPROOT/utils/logger.sh"
ROOT="$(cd "$(dirname "$0")" && pwd)"

# == Empecher l'arrêt forcé de l'interface ===
trap 'on_ctrl_c' INT

on_ctrl_c() {
  echo ""
  echo "Q pour quitter."
  sleep 1
}
# ===============

log_info "cliInterface: depuis : $ROOT"
log_info "cliInterface: affichage menu principal"

tput clear
cat "$ROOT/ASCII_Cyberdiag.txt"

JSON=$("$APPROOT/main.sh" --script list --filter tool | grep -E '^\[\{' )
if [ -z "$JSON" ]; then
log_error "cliInterface: Erreur lors de l'exécution du script list.sh"
exit 1
fi

echo "---------------------" 
echo "Modules disponibles :"
echo "---------------------"

echo ""

# Affichage menu dynamique
echo "$JSON" | jq -r 'to_entries[] | "\(.key+1)) \(.value.name) — \(.value.type)"'

echo ""
echo "R)Retour"

read -rp "Choix : " CHOIX

MODULE=$(echo "$JSON" | jq -r ".[$CHOIX-1].name")

if [ "$MODULE" = "null" ] || [ -z "$MODULE" ]; then
    echo "Choix invalide"
    sleep 1
    continue
elif [ "$MODULE" = "R" ] || [ "$MODULE" = "r" ]; then
    $ROOT/main.sh
    exit 0
fi

log_info "Lancement du module : $MODULE"

"$APPROOT/main.sh" --script "$MODULE"
