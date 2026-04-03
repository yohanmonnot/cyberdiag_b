#!/bin/bash
# =============================================================================
# Module : osInfo
# Description : Récupère la version de l'OS, le noyau et si le support est actif
# Auteur : Nolhan
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; NC='\033[0m'

OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release 2>/dev/null | tr -d '"')
OS_VERSION=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release 2>/dev/null | tr -d '"')
KERNEL_VERSION=$(uname -r)
SUPPORT_STATUS="Unknown"
SCORE=5
RECOMMENDATION=""

output_json() {
    local STATUS="$1" local ERROR="$2" local SCORE="$3" local RECOMMENDATION="$4"
    echo $(jq -n \
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

check_requirements() {
    [[ ! -r /etc/os-release ]] && { output_json "FAIL" "/etc/os-release inaccessible." 0 ""; exit 0; }
}

calculate_score() {
    # Si support officiel (simplifié : version >= 20 pour Ubuntu/Debian)
    if [[ "$OS_VERSION" =~ ^([0-9]+) ]] && (( BASH_REMATCH[1] >= 20 )); then
        SCORE=5
        SUPPORT_STATUS="Supported"
    else
        SCORE=3
        SUPPORT_STATUS="Possibly outdated"
    fi
    RECOMMENDATION="OS: $OS_NAME $OS_VERSION
Kernel: $KERNEL_VERSION
Support: $SUPPORT_STATUS"
}

main() {
    check_requirements
    calculate_score
    output_json "OK" "" "$SCORE" "$RECOMMENDATION"
}

main "$@"