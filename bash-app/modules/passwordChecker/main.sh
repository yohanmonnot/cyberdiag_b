#!/bin/bash
# =============================================================================
# Module : check_password
# Description : Vérifie la politique de mot de passe PAM
# Auteur : Yohan
# =============================================================================

# --- Configuration recommandée ---
RECOMMENDED_MINLEN=12
RECOMMENDED_DCREDIT=-1
RECOMMENDED_UCREDIT=-1
RECOMMENDED_LCREDIT=-1
RECOMMENDED_OCREDIT=-1
RECOMMENDED_DIFOK=4

# --- Initialisation ---
STATUS="OK"
ERROR=""
SCORE=5
RECOMMENDATION="La politique de mot de passe est conforme aux bonnes pratiques."

OK_COUNT=0
WARN_COUNT=0

# --- Fonction JSON (UNE SEULE LIGNE) ---
output_json() {
    jq -c -n \
      --arg status "$STATUS" \
      --arg error "$ERROR" \
      --argjson score "$SCORE" \
      --arg recommendation "$RECOMMENDATION" \
      '{status:$status,error:$error,score:$score,recommendation:$recommendation}'
}

# --- Récupération des fichiers PAM ---
get_pam_files() {
    local files=(
        "/etc/pam.d/common-password"
        "/etc/pam.d/system-auth"
        "/etc/pam.d/password-auth"
    )

    for f in "${files[@]}"; do
        [[ -r "$f" ]] && echo "$f"
    done
}

# --- Lecture option ---
get_option_value() {
    local opt="$1"

    [[ -r /etc/security/pwquality.conf ]] &&
        awk -F= -v k="$opt" '$1==k {gsub(/ /,"",$2);print $2}' /etc/security/pwquality.conf | head -n1 && return

    grep -R "pam_pwquality\.so\|pam_cracklib\.so" /etc/pam.d 2>/dev/null |
        grep "$opt=" | head -n1 | sed "s/.*$opt=//" | cut -d' ' -f1
}

# --- Vérification numérique ---
check_numeric() {
    local actual="$1" rec="$2" cmp="$3"

    [[ -z "$actual" ]] && { WARN_COUNT=$((WARN_COUNT+1)); return; }
    [[ ! "$actual" =~ ^-?[0-9]+$ ]] && { WARN_COUNT=$((WARN_COUNT+1)); return; }

    if [[ "$cmp" == "ge" ]]; then
        (( actual >= rec )) && OK_COUNT=$((OK_COUNT+1)) || WARN_COUNT=$((WARN_COUNT+1))
    else
        (( actual <= rec )) && OK_COUNT=$((OK_COUNT+1)) || WARN_COUNT=$((WARN_COUNT+1))
    fi
}

# --- Analyse ---
run_checks() {
    PAM_FILES=$(get_pam_files)

    if [[ -z "$PAM_FILES" ]]; then
        STATUS="CRITICAL"
        ERROR="Aucun fichier PAM trouvé"
        SCORE=0
        RECOMMENDATION="Des problèmes critiques de politique de mot de passe ont été détectés. Revue immédiate nécessaire."
        return
    fi

    check_numeric "$(get_option_value minlen)"  "$RECOMMENDED_MINLEN" ge
    check_numeric "$(get_option_value dcredit)" "$RECOMMENDED_DCREDIT" ge
    check_numeric "$(get_option_value ucredit)" "$RECOMMENDED_UCREDIT" ge
    check_numeric "$(get_option_value lcredit)" "$RECOMMENDED_LCREDIT" ge
    check_numeric "$(get_option_value ocredit)" "$RECOMMENDED_OCREDIT" ge
    check_numeric "$(get_option_value difok)"   "$RECOMMENDED_DIFOK" ge

    if (( WARN_COUNT > 0 )); then
        STATUS="WARNING"
        RECOMMENDATION="Des améliorations de la politique de mot de passe sont recommandées."
    fi

    TOTAL=$((OK_COUNT + WARN_COUNT))
    (( TOTAL > 0 )) && SCORE=$(( OK_COUNT * 5 / TOTAL ))
}

# --- Tests internes ---
run_self_tests() {
    echo "============================================="
    echo "Running internal tests (check_password)"
    echo "============================================="

    local passed=0 failed=0

    test_case() {
        if "$@"; then
            echo "PASS - $*"
            ((passed++))
        else
            echo "FAIL - $*"
            ((failed++))
        fi
    }

    test_case jq command -v jq
    test_case get_pam_files get_pam_files >/dev/null
    test_case output_json bash -c 'STATUS=OK; output_json | jq . >/dev/null'

    echo "---------------------------------------------"
    echo "Total: $((passed+failed)) | Passed: $passed | Failed: $failed"
    echo "---------------------------------------------"
}

# --- Main ---
if [[ "$1" == "--test" ]]; then
    run_self_tests
    exit 0
fi

run_checks
output_json
