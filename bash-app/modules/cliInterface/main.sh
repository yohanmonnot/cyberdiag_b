#!/bin/bash

APPROOT="$(cd "$(dirname "$0")/../../" && pwd)"
source "$APPROOT/utils/logger.sh"
ROOT="$(cd "$(dirname "$0")" && pwd)"

# == Empecher l'arrêt forcé de l'interface ===
trap 'on_ctrl_c' INT

on_ctrl_c() {
  echo ""
  echo "Q pour quitter.     :)"
  sleep 1
}
# ===============

log_info "cliInterface: depuis : $ROOT"
log_info "cliInterface: affichage menu principal"
#echo "Le script est dans : $(dirname "$0")" #Debug


tput clear
cat "$ROOT/ASCII_Cyberdiag.txt"

echo "-------------------------" 
echo "Bienvenue sur Cyberdiag :"
echo "-------------------------"

echo ""
echo "M) Modules"
echo "D) diagnostics"
echo "R) Raports"
echo "Q) Quitter"

read -rp "Choix : " CHOIX

if [ "$CHOIX" = "Q" ] || [ "$CHOIX" = "q" ]; then
  exit 0
elif [ "$CHOIX" = "M" ] || [ "$CHOIX" = "m" ]; then
  $ROOT/menu_module.sh
elif [ "$CHOIX" = "D" ] || [ "$CHOIX" = "d" ]; then
  ./"$ROOT"/menu_diagnostics.sh
elif [ "$CHOIX" = "R" ] || [ "$CHOIX" = "r" ]; then
  ./"$ROOT"/menu_rapport.sh
else
  echo "Choix invalide"
  sleep 1
fi

log_info "cliInterface - STOP"
