#!/bin/bash

# =============================================================================
# Nom : run_all_modules.sh
# Description : Lance tous les modules main.sh et agrège les scores
# =============================================================================

# Couleurs pour la console
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules2"

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   LANCEMENT DU DIAGNOSTIC RÉSEAU COMPLET         ${NC}"
echo -e "${BLUE}==================================================${NC}\n"

# Vérifier si le dossier modules existe
if [ ! -d "$MODULES_DIR" ]; then
    echo -e "${RED}Erreur : Le dossier $MODULES_DIR est introuvable.${NC}"
    exit 1
fi

# Initialisation du rapport final
TOTAL_SCORE=0
MODULE_COUNT=0

# Parcourir chaque sous-dossier dans modules/
for module_path in "$MODULES_DIR"/*/main.sh; do
    if [ -f "$module_path" ]; then
        module_name=$(basename "$(dirname "$module_path")")
        
        echo -e "${CYAN}[*] Exécution du module : ${YELLOW}$module_name${NC}"
        
        # Exécution du module et capture de la sortie JSON
        # On utilise 'sudo' si nécessaire pour certains modules (ex: rogueDhcp)
        RESULT=$(bash "$module_path" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$RESULT" ]; then
            # Extraction des données avec jq
            SCORE=$(echo "$RESULT" | jq -r '.score // 0')
            REC=$(echo "$RESULT" | jq -r '.recommendation // "N/A"')
            
            # Affichage formaté
            if [ "$SCORE" -eq 5 ]; then
                echo -e "    ${GREEN}Score : $SCORE/5 - OK${NC}"
            elif [ "$SCORE" -ge 3 ]; then
                echo -e "    ${YELLOW}Score : $SCORE/5 - Warning${NC}"
            else
                echo -e "    ${RED}Score : $SCORE/5 - Critique${NC}"
            fi
            echo -e "    Note : $REC\n"
            
            TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
            ((MODULE_COUNT++))
        else
            echo -e "    ${RED}Erreur : Échec de l'exécution ou sortie JSON invalide.${NC}\n"
        fi
    fi
done

# Résumé Final
if [ "$MODULE_COUNT" -gt 0 ]; then
    FINAL_AVG=$(echo "scale=2; $TOTAL_SCORE / $MODULE_COUNT" | bc)
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${CYAN}RÉSULTAT GLOBAL : ${YELLOW}$FINAL_AVG / 5${NC}"
    echo -e "${BLUE}==================================================${NC}"
else
    echo -e "${RED}Aucun module n'a été exécuté.${NC}"
fi