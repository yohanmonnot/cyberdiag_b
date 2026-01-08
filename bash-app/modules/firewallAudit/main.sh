#!/bin/bash
# =============================================================================
# Script : main.sh
# Description : Audit simplifié du firewall et génération d'un JSON
# Auteur : Yohan
# =============================================================================

set -e

# --- Initialisation ---
statut="OK"
erreur=""
recommendation=""
score=5

issues=0
checks=0

JSON_FILE="module.json"

# --- Détection du firewall ---
if command -v iptables >/dev/null 2>&1; then
    FIREWALL="iptables"
elif command -v nft >/dev/null 2>&1; then
    FIREWALL="nft"
else
    statut="CRITICAL"
    erreur="Aucun firewall détecté"
    recommendation="Installer et configurer iptables ou nftables"
fi

# --- Analyse simple du firewall ---
if [[ "$FIREWALL" == "iptables" ]]; then
    mapfile -t rules < <(sudo iptables -L -n --line-numbers)
elif [[ "$FIREWALL" == "nft" ]]; then
    mapfile -t rules < <(sudo nft list ruleset)
fi

# --- Vérifications rapides ---
# Ex: on considère qu'une ligne ACCEPT = risque moyen pour simplification
for r in "${rules[@]}"; do
    [[ -z "$r" || "$r" =~ Chain ]] && continue
    if echo "$r" | grep -Eq 'ACCEPT.*tcp'; then
        issues=$((issues+1))
    fi
done

checks=${#rules[@]}

# --- Calcul du score ---
if (( checks > 0 )); then
    score=$(( (checks - issues) * 5 / checks ))
else
    score=5
fi

# Ajustement du statut final
if (( issues == 0 )); then
    statut="OK"
elif (( issues > 0 )) && [[ "$statut" != "CRITICAL" ]]; then
    statut="WARNING"
fi

[[ -z "$recommendation" ]] && recommendation="Audit firewall effectué. Vérifier les règles ouvertes."

# --- Génération JSON simplifié ---
JSON_OUTPUT=$(cat <<EOF
{
  "status": "$statut",
  "error": "$erreur",
  "score": $score,
  "recommendation": "$recommendation"
}
EOF
)

# Affichage à l'écran
echo "$JSON_OUTPUT"

# Écriture dans result.json
echo "$JSON_OUTPUT" > "$JSON_FILE"

