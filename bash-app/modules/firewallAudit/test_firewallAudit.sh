#!/bin/bash
# =============================================================================
# Script : test_firewallAudit.sh
# Description : Test automatique du module main.sh et validation JSON
# Auteur : Yohan
# =============================================================================

MODULE="./main.sh"

if [[ ! -x "$MODULE" ]]; then
    echo "Le module $MODULE n'existe pas ou n'est pas exécutable."
    exit 1
fi

echo "=== Test automatique du module firewallAudit ==="

# Exécution du module et capture JSON
output=$($MODULE)

# Vérification que le JSON est valide
echo "$output" | jq . >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Le JSON retourné n'est pas valide."
    exit 1
fi

# Vérification des champs principaux
for key in status error score recommendation rules; do
    if ! echo "$output" | jq -e "has(\"$key\")" >/dev/null; then
        echo "Le champ '$key' est manquant dans la sortie JSON."
        exit 1
    fi
done

echo "Le module firewallAudit retourne un JSON "
exit 0
