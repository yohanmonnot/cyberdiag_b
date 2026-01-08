#!/bin/bash
# =============================================================================
# Script : test.sh
# Description : Teste le script privilegesChecker.sh et valide son JSON
# Auteur : Yohan
# =============================================================================

MODULE="./main.sh"

if [[ ! -x "$MODULE" ]]; then
    echo "Le module $MODULE n’existe pas ou n’est pas exécutable."
    exit 1
fi

echo "=== Test automatique du module privilegesChecker ==="

# Exécution du module et capture du JSON
output=$($MODULE)

# Vérification que la sortie est un JSON valide
echo "$output" | jq . >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Le JSON retourné n’est pas valide."
    exit 1
fi

# Vérification des champs attendus
for key in status error score recommendation; do
    if ! echo "$output" | jq -e "has(\"$key\")" >/dev/null; then
        echo "Le champ '$key' est manquant dans la sortie JSON."
        exit 1
    fi
done

echo "Le module privilegesChecker retourne un JSON "
exit 0