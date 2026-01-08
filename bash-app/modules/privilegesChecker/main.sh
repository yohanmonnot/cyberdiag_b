#!/bin/bash
# =============================================================================
# Script : main.sh
# Description : Vérifie les privilèges système sensibles et génère un JSON
# Auteur : Yohan
# =============================================================================

# --- Initialisation ---
status="OK"
error=""
recommendation=""
score=5

issues=0
checks=0

# --- Vérification 1 : exécution en root ---
checks=$((checks+1))
if [[ "$EUID" -ne 0 ]]; then
    issues=$((issues+1))
    status="WARNING"
    recommendation="Some privileged checks require root access."
fi

# --- Vérification 2 : sudo installé ---
checks=$((checks+1))
if ! command -v sudo >/dev/null 2>&1; then
    issues=$((issues+1))
    status="CRITICAL"
    error="sudo command not found."
    recommendation="Install sudo to manage privileged access securely."
fi

# --- Vérification 3 : utilisateurs avec UID 0 ---
checks=$((checks+1))
uid0_users=$(awk -F: '$3 == 0 { print $1 }' /etc/passwd)
uid0_count=$(echo "$uid0_users" | wc -w)

if [[ "$uid0_count" -gt 1 ]]; then
    issues=$((issues+1))
    status="WARNING"
    recommendation="Multiple UID 0 users detected. Review privileged accounts."
fi

# --- Vérification 4 : fichier sudoers ---
checks=$((checks+1))
if [[ ! -r /etc/sudoers ]]; then
    issues=$((issues+1))
    status="WARNING"
    recommendation="sudoers file is not readable. Check permissions."
fi

# --- Calcul du score (0 à 5) ---
if (( checks > 0 )); then
    score=$(( (checks - issues) * 5 / checks ))
fi

# Ajustement final du status
if (( issues == checks )); then
    status="CRITICAL"
elif (( issues > 0 )) && [[ "$status" != "CRITICAL" ]]; then
    status="WARNING"
fi

[[ -z "$recommendation" ]] && recommendation="Privilege configuration follows best practices."

# --- Sortie JSON ---
JSON_OUTPUT=$(cat <<EOF
{
  "status": "$status",
  "error": "$error",
  "score": $score,
  "recommendation": "$recommendation"
}
EOF
)

# Affichage standard (pour les tests)
echo "$JSON_OUTPUT"

# Écriture dans un fichier
JSON_FILE="result.json"
echo "$JSON_OUTPUT" > "$JSON_FILE"