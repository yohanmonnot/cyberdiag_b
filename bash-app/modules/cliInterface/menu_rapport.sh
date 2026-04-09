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