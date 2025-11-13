#!/bin/bash

YELLOW="\033[1;33m"
RESET="\033[0m"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${YELLOW}Chemin du projet :${RESET} $PROJECT_ROOT\n"