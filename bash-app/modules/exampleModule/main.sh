#!/bin/bash
source "$(dirname "$0")/../../utils/logger.sh"

log_info "exampleModule: starting example module"
echo "=== Scan Ports ==="

declare -A results

for port in 22 80 443 8080; do
    if (echo >/dev/tcp/localhost/$port) &>/dev/null; then
        status="open"
    else
        status="closed"
    fi
    results["$port"]="$status"
    echo "Port $port is $status"
done

# Build JSON array
json="["
first=true
for port in "${!results[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        json+=","
    fi
    json+="{\"port\":$port,\"status\":\"${results[$port]}\"}"
done
json+="]"

echo "$json"

log_info "exampleModule: finished example module"
