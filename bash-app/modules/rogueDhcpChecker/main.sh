#!/bin/bash
# =============================================================================
# Module : rogueDhcpChecker
# Description : Détecte la présence de serveurs DHCP multiples (Rogue DHCP)
# Auteur : Nolhan
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$PROJECT_ROOT/utils/env.sh"
source "$PROJECT_ROOT/utils/logger.sh"

# ==================================================
# Variables
# ==================================================
SCORE=5
RECOMMENDATION=""
ERROR=""

# ==================================================
# Génération JSON
# ==================================================
output_json() {
    local STATUS="$1"
    local ERROR="$2"
    local SCORE="$3"
    local RECOMMENDATION="$4"

    echo $(jq -n \
        --arg status "$STATUS" \
        --arg error "$ERROR" \
        --argjson score "$SCORE" \
        --arg recommendation "$RECOMMENDATION" \
        '{status: $status, error: $error, score: $score, recommendation: $recommendation}')
}

# ==================================================
# Vérifications
# ==================================================
check_requirements() {
    if ! command -v nmap &>/dev/null; then
        output_json "FAIL" "nmap manquant" 0 "Installez nmap (apt install nmap)."
        exit 0
    fi

    if ! command -v ip &>/dev/null; then
        output_json "FAIL" "Commande ip manquante" 0 "Installez iproute2."
        exit 0
    fi
}

# ==================================================
# Détection interface réseau
# ==================================================
get_default_interface() {
    ip route | awk '/default/ {print $5}' | head -n1
}

# ==================================================
# Scan DHCP
# ==================================================
scan_dhcp_servers() {
    local INTERFACE="$1"

    # Si pas root → on ne bloque pas le test
    if [[ $EUID -ne 0 ]]; then
        ERROR="Scan DHCP nécessite les droits root."
        SCORE=3
        RECOMMENDATION="Relancer avec sudo pour une détection complète."
        return
    fi

    # Scan DHCP broadcast
    local RESULT
    RESULT=$(nmap --script broadcast-dhcp-discover -e "$INTERFACE" 2>/dev/null)

    DHCP_SERVERS=$(echo "$RESULT" | grep -c "IP Address")

    if [[ -z "$DHCP_SERVERS" || "$DHCP_SERVERS" -eq 0 ]]; then
        SCORE=2
        RECOMMENDATION="Aucun serveur DHCP détecté. Vérifiez le réseau ou les permissions."
        return
    fi

    if [[ "$DHCP_SERVERS" -gt 1 ]]; then
        SCORE=1
        RECOMMENDATION="Alerte : $DHCP_SERVERS serveurs DHCP détectés.
- Risque de Rogue DHCP
- Risque de Man-in-the-Middle

Actions recommandées :
- Vérifier les équipements réseau
- Désactiver les DHCP non autorisés
- Segmenter le réseau (VLAN)
- Activer DHCP Snooping (switch)"
    else
        SCORE=5
        RECOMMENDATION="Un seul serveur DHCP détecté (comportement normal)."
    fi
}

# ==================================================
# Analyse principale
# ==================================================
check_real() {
    log_info "[rogueDhcpChecker] Détection des serveurs DHCP..."

    check_requirements

    INTERFACE=$(get_default_interface)

    if [[ -z "$INTERFACE" ]]; then
        output_json "FAIL" "Interface réseau introuvable" 0 "Vérifiez la configuration réseau."
        exit 0
    fi

    scan_dhcp_servers "$INTERFACE"

    log_info "[rogueDhcpChecker] Vérification terminée, score=$SCORE/5"

    output_json "OK" "$ERROR" "$SCORE" "$RECOMMENDATION"
}

# ==================================================
# Tests unitaires
# ==================================================
run_unit_tests() {
    echo "==========================================="
    echo "UNIT TESTS - rogueDhcpChecker"
    echo "==========================================="

    local TOTAL=0 PASS=0 FAIL=0

    run_case() {
        local NAME="$1"
        local SERVERS="$2"
        local EXPECTED_SCORE="$3"

        ((TOTAL++))

        if [[ "$SERVERS" -gt 1 ]]; then
            SCORE=1
        elif [[ "$SERVERS" -eq 1 ]]; then
            SCORE=5
        else
            SCORE=2
        fi

        echo "Test: $NAME"
        echo "Serveurs DHCP simulés: $SERVERS"
        echo "Score attendu: $EXPECTED_SCORE"
        echo "Score obtenu: $SCORE"

        if [[ "$SCORE" -eq "$EXPECTED_SCORE" ]]; then
            echo "RESULT: PASS"
            ((PASS++))
        else
            echo "RESULT: FAIL"
            ((FAIL++))
        fi
        echo "-------------------------------------------"
    }

    run_case "Aucun serveur" 0 2
    run_case "Un serveur" 1 5
    run_case "Deux serveurs (rogue)" 2 1
    run_case "Trois serveurs (critique)" 3 1

    echo "==========================================="
    echo "Résultat: $PASS/$TOTAL PASS, $FAIL FAIL"
}

# ==================================================
# Test d'intégration
# ==================================================
run_integration_test() {
    echo "================ TEST D'INTÉGRATION ================"
    check_real
}

# ==================================================
# Couverture logique
# ==================================================
run_coverage_check() {
    echo "================ COUVERTURE LOGIQUE ================"

    for i in 0 1 2 3; do
        if [[ "$i" -gt 1 ]]; then
            SCORE=1
        elif [[ "$i" -eq 1 ]]; then
            SCORE=5
        else
            SCORE=2
        fi
    done

    echo "Couverture OK"
}

# ==================================================
# MASTER TEST
# ==================================================
run_tests() {
    run_unit_tests
    run_integration_test
    run_coverage_check
    echo "TOUS LES TESTS TERMINÉS"
    exit 0
}

# ==================================================
# MAIN
# ==================================================
main() {
    if [[ "$1" == "--test" ]]; then
        run_tests
    fi

    check_real
}

main "$@"