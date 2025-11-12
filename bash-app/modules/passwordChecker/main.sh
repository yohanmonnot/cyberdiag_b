#!/bin/bash
# =============================================================================
# Script : check_password.sh
# Description : Vérifie la politique de mot de passe PAM et génère un JSON
# Auteur : Yohan
# =============================================================================

source "$(dirname "$0")./../utils/logger.sh"

log_info "check_password: starting password policy check"

# --- Configuration recommandée ---
RECOMMENDED_MINLEN=12
RECOMMENDED_DCREDIT=-1   # chiffres requis
RECOMMENDED_UCREDIT=-1   # majuscules requises
RECOMMENDED_LCREDIT=-1   # minuscules requises
RECOMMENDED_OCREDIT=-1   # caractères spéciaux requis
RECOMMENDED_DIFOK=4      # caractères différents vs ancien mot de passe
# ---------------------------------

point_positif=0
point_negatif=0

# Fichiers PAM à analyser
PAM_FILES=(
    "/etc/pam.d/common-password"   # Debian/Ubuntu
    "/etc/pam.d/system-auth"       # RHEL/CentOS
    "/etc/pam.d/password-auth"     # RHEL/CentOS
)

# Détecter fichiers existants
found_files=()
for f in "${PAM_FILES[@]}"; do
    [[ -r "$f" ]] && found_files+=("$f")
done

if [[ ${#found_files[@]} -eq 0 ]]; then
    log_error "Aucun fichier PAM connu trouvé."
    error="No PAM configuration files found."
    status="CRITICAL"
    score=0
    recommendation="Critical password policy issues detected. Immediate review required."
    # Sortie JSON immédiate
    cat <<EOF
{
  "status": "$status",
  "error": "$error",
  "score": $score,
  "recommendation": "$recommendation"
}
EOF
    exit 1
fi

log_info "Fichiers PAM détectés : ${found_files[*]}"

# Fonction pour extraire options d'une ligne PAM
parse_options() {
    local line="$1"
    local opts
    opts=$(echo "$line" | awk -F'.so' '{ if (NF>1) print $2; else print "" }' | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')
    for token in $opts; do
        echo "$token"
    done
}

# Récupération des modules et options
declare -A findings options
for file in "${found_files[@]}"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line//[[:space:]]/}" ]] && continue
        if echo "$line" | grep -Eq "pam_pwquality\.so|pam_cracklib\.so|pam_unix\.so"; then
            mod=$(echo "$line" | grep -Eo "pam_[a-z0-9_]+\.so" | head -n1 | sed 's/\.so$//')
            key="${mod}@${file}"
            findings["$key"]="present"
            for opt in $(parse_options "$line"); do
                if [[ "$opt" == *=* ]]; then
                    k=$(echo "$opt" | cut -d= -f1)
                    v=$(echo "$opt" | cut -d= -f2-)
                    options["${key}@${k}"]="$v"
                else
                    options["${key}@${opt}"]="true"
                fi
            done
        fi
    done < "$file"
done

# Lecture de /etc/security/pwquality.conf si présent
PWQ_CONF="/etc/security/pwquality.conf"
declare -A pwq_conf
if [[ -r "$PWQ_CONF" ]]; then
    while IFS= read -r l || [[ -n "$l" ]]; do
        ltrim=$(echo "$l" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//')
        [[ -z "$ltrim" || "${ltrim:0:1}" == "#" ]] && continue
        [[ "$ltrim" =~ = ]] && pwq_conf["$(echo $ltrim | cut -d= -f1 | sed 's/[[:space:]]*$//')"]="$(echo $ltrim | cut -d= -f2- | sed 's/^[[:space:]]*//')"
    done < "$PWQ_CONF"
    log_info "$PWQ_CONF trouvé et lu."
fi

# Fonction pour récupérer une option (pwquality.conf > pam_pwquality > pam_cracklib > pam_unix)
get_option_value() {
    local opt="$1"
    [[ -n "${pwq_conf[$opt]:-}" ]] && echo "${pwq_conf[$opt]}" && return
    for modfile in "${!findings[@]}"; do
        [[ "$modfile" =~ pam_pwquality@|pam_cracklib@ ]] && [[ -n "${options[$modfile@$opt]:-}" ]] && echo "${options[$modfile@$opt]}" && return
    done
    for modfile in "${!findings[@]}"; do
        [[ "$modfile" =~ pam_unix@ ]] && [[ -n "${options[$modfile@$opt]:-}" ]] && echo "${options[$modfile@$opt]}" && return
    done
    echo ""
}

# Vérification numérique
ok_count=0
warn_count=0
check_numeric() {
    local name="$1" actual="$2" rec="$3" cmp="$4"
    if [[ -z "$actual" ]]; then
        log_warn "$name non défini (recommandé $rec)"
        warn_count=$((warn_count+1))
        return
    fi
    [[ ! "$actual" =~ ^-?[0-9]+$ ]] && { log_warn "$name valeur non numérique ('$actual')"; warn_count=$((warn_count+1)); return; }
    if [[ "$cmp" == "ge" ]]; then
        if (( actual >= rec )); then log_info "$name : $actual (>= $rec)"; ok_count=$((ok_count+1))
        else log_warn "$name : $actual (< $rec)"; warn_count=$((warn_count+1)); fi
    else
        if (( actual <= rec )); then log_info "$name : $actual (<= $rec)"; ok_count=$((ok_count+1))
        else log_warn "$name : $actual (> $rec)"; warn_count=$((warn_count+1)); fi
    fi
}

# Analyse des options
minlen_val=$(get_option_value "minlen")
check_numeric "minlen" "$minlen_val" "$RECOMMENDED_MINLEN" ge
check_numeric "dcredit" "$(get_option_value "dcredit")" "$RECOMMENDED_DCREDIT" ge
check_numeric "ucredit" "$(get_option_value "ucredit")" "$RECOMMENDED_UCREDIT" ge
check_numeric "lcredit" "$(get_option_value "lcredit")" "$RECOMMENDED_LCREDIT" ge
check_numeric "ocredit" "$(get_option_value "ocredit")" "$RECOMMENDED_OCREDIT" ge
check_numeric "difok" "$(get_option_value "difok")" "$RECOMMENDED_DIFOK" ge

# Détermination du statut
point_positif=$((ok_count))
point_negatif=$((warn_count))
if (( warn_count > 0 )); then
    status="WARNING"
elif (( ok_count > 0 )); then
    status="OK"
else
    status="CRITICAL"
fi

# Recommandation
if [[ "$status" == "OK" ]]; then
    recommendation="Password policy fully compliant with best practices."
elif [[ "$status" == "WARNING" ]]; then
    recommendation="Some password policy improvements are recommended."
else
    recommendation="Critical password policy issues detected. Immediate review required."
fi

# Score normalisé de 0 à 5
total_checks=$((ok_count + warn_count))
score=0
if (( total_checks > 0 )); then
    score=$(( ok_count * 5 / total_checks ))
fi

error=""

# JSON final
json=$(cat <<EOF
{
  "status": "$status",
  "error": "$error",
  "score": $score,
  "recommendation": "$recommendation"
}
EOF
)

echo "$json"

log_info "check_password: finished password policy check"
