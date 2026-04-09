#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

source "$ROOT/core/reports.sh"
source "$ROOT/core/filter.sh"
source "$ROOT/core/stats.sh"

case "$1" in

  list)
    list_reports
    ;;

  summary)
    require_file "$2"
    report_summary "$2"
    ;;

  vulns)
    require_file "$2"
    list_vulns "$2"
    ;;

  critical)
    require_file "$2"
    filter_severity "$2" "CRITICAL"
    ;;

  cve)
    require_file "$2"
    show_cve "$2" "$3"
    ;;

  stats)
    require_file "$2"
    report_stats "$2"
    ;;

  *)
    echo "VulnApp CLI"
    echo
    echo "Commandes:"
    echo " list                     → liste rapports"
    echo " summary <file>           → résumé"
    echo " vulns <file>             → liste vulnérabilités"
    echo " critical <file>          → seulement critiques"
    echo " cve <file> <ID>          → détail CVE"
    echo " stats <file>             → statistiques"
    exit 1
    ;;
esac
