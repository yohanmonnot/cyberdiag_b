#!/bin/bash

# =============================================================================
# Nom : set_permissions.sh
# Description : Accorde les droits d'exécution à tous les fichiers main.sh
# =============================================================================

# Couleurs
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules2"

echo -e "${CYAN}Configuration des permissions pour les modules...${NC}"

if [ ! -d "$MODULES_DIR" ]; then
    echo -e "${RED}Erreur : Le dossier 'modules' est introuvable dans $SCRIPT_DIR${NC}"
    exit 1
fi

# Compteur pour le résumé
count=0

# Recherche et modification
# -name "main.sh" : cible uniquement les fichiers nommés main.sh
# -type f : uniquement les fichiers (pas les dossiers)
while IFS= read -r file; do
    chmod +x "$file"
    echo -e "  ${GREEN}[OK]${NC} Executable : ${YELLOW}$(basename $(dirname "$file"))/main.sh${NC}"
    ((count++))
done < <(find "$MODULES_DIR" -name "main.sh" -type f)

echo -e "\n${GREEN}Terminé ! $count modules sont maintenant prêts à être lancés.${NC}"