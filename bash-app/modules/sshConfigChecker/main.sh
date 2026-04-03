#!/bin/bash
# =============================================================================
# Module : sshConfigChecker
# Description : Vérifie la configuration SSH (PermitRootLogin, PasswordAuth)
# Auteur : Nolhan
# =============================================================================

SCORE=5; RECOMMENDATION=""

output_json() { echo $(jq -n --arg status "$1" --arg error "$2" --argjson score "$3" --arg recommendation "$4" '{status: $status, error: $error, score: $score, recommendation: $recommendation}'); }

collect_ssh_config() {
    SSH_CONF="/etc/ssh/sshd_config"
    [[ ! -r $SSH_CONF ]] && { output_json "FAIL" "Fichier $SSH_CONF inaccessible" 0 ""; exit 0; }
    PERMIT_ROOT=$(grep -Ei '^PermitRootLogin' $SSH_CONF | awk '{print $2}' || echo "undefined")
    PASSWORD_AUTH=$(grep -Ei '^PasswordAuthentication' $SSH_CONF | awk '{print $2}' || echo "undefined")
}

calculate_score() {
    [[ "$PERMIT_ROOT" == "yes" || "$PASSWORD_AUTH" == "yes" ]] && SCORE=2 || SCORE=5
    RECOMMENDATION="PermitRootLogin: $PERMIT_ROOT
PasswordAuthentication: $PASSWORD_AUTH"
}

main() {
    collect_ssh_config
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"