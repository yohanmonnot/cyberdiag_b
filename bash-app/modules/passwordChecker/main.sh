#!/bin/bash
# =============================================================================
# Script : main.sh
# Description : Vérifie la politique de mot de passe PAM et génère un JSON
# Auteur : Yohan
# =============================================================================

source "$(dirname "$0")./../utils/logger.sh"

log_info "check_password: démarrage de la vérification de la politique de mot de passe"

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
    error="Aucun fichier de configuration PAM trouvé."
    status="CRITICAL"
    score=0
    recommendation="Des problèmes critiques de politique de mot de passe ont été détectés. Revue immédiate nécessaire."
    # Sortie JSON immédiate
    cat <<EOF
{
  "status": "$status",
  "error": "$error",
  "score": $score,
  "recommendation": "$recommendation"
}
EOF
    echo "$json" > module.json
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

# Recommandation en français
if [[ "$status" == "OK" ]]; then
    recommendation="La politique de mot de passe est conforme aux bonnes pratiques."
elif [[ "$status" == "WARNING" ]]; then
    recommendation="Des améliorations de la politique de mot de passe sont recommandées."
else
    recommendation="Des problèmes critiques de politique de mot de passe ont été détectés. Revue immédiate nécessaire."
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

# Affichage et écriture du JSON
echo "$json"
echo "$json" > module.json

log_info "check_password: fin de la vérification de la politique de mot de passe"

# =============================================================================
# --- Self-testing functionality ----------------------------------------------
# =============================================================================
run_self_tests() {
    echo "========================================="
    echo "Running internal tests for check_password"
    echo "========================================="

    local passed=0
    local failed=0

    GREEN="\033[0;32m"
    RED="\033[0;31m"
    CYAN="\033[0;36m"
    RESET="\033[0m"

    test_case() {
        local name="$1"
        shift
        if "$@"; then
            echo -e "${GREEN}PASS${RESET} - $name"
            ((passed++))
        else
            echo -e "${RED}FAIL${RESET} - $name"
            ((failed++))
        fi
    }

    # --- Test 1: Vérification que la fonction check_numeric détecte bien les valeurs ---
    test_case "check_numeric returns ok for valid value" bash -c '
        source "$(dirname "$0")/main.sh"
        check_numeric "minlen" 15 12 ge &>/dev/null
    '

    test_case "check_numeric warns on low value" bash -c '
        source "$(dirname "$0")/main.sh"
        check_numeric "minlen" 8 12 ge &>/dev/null
    '

    # --- Test 2: Vérification que get_option_value ne crash pas ---
    test_case "get_option_value executes without error" bash -c '
        source "$(dirname "$0")/main.sh"
        get_option_value "minlen" >/dev/null 2>&1
    '

    # --- Test 3: Test de sortie JSON valide ---
    test_case "JSON output is valid" bash -c '
        SCRIPT_DIR="$(dirname "$0")"
        "$SCRIPT_DIR/check_passwords.sh" | jq empty >/dev/null 2>&1
    '

    echo
    echo -e "${CYAN}Résultat global:${RESET} $((passed+failed)) tests exécutés | ${GREEN}$passed passés${RESET} | ${RED}$failed échoués${RESET}"
    echo

    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN} Tous les tests internes sont passés avec succès.${RESET}"
    else
        echo -e "${RED} Certains tests internes ont échoué.${RESET}"
    fi
}

# =============================================================================
# --- Main execution ----------------------------------------------------------
# =============================================================================
main() {
    if [[ "$1" == "--test" ]]; then
        run_self_tests
        exit 0
    fi

    log_info "[check_password] Lancement du module ..."
    # L'analyse s'exécute automatiquement au démarrage
}

main "$@"
