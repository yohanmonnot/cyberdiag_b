#!/bin/bash
source "$(dirname "$0")/../../utils/logger.sh"
log_info "memory_usage: starting memory usage check"

# Check if free command is available
if ! command -v free &> /dev/null; then
	log_error "memory_usage: free command is not available"
	echo '{"error": "free command is not available"}'
	exit 1
fi

# Check memory usage
memory_usage_raw=$(free -h | grep -v "=== Memory Usage ===" | grep -v "Échange:")
while IFS= read -r line; do
	if [[ $line == *"Mem:"* ]]; then
		total=$(echo "$line" | awk '{print $2}')
		used=$(echo "$line" | awk '{print $3}')
		free=$(echo "$line" | awk '{print $4}')
		shared=$(echo "$line" | awk '{print $5}')
		buff_cache=$(echo "$line" | awk '{print $6}')
		available=$(echo "$line" | awk '{print $7}')
	fi
done <<< "$memory_usage_raw"
memory_usage_json="{\"total\": \"$total\", \"used\": \"$used\", \"free\": \"$free\", \"shared\": \"$shared\", \"buff_cache\": \"$buff_cache\", \"available\": \"$available\"}"

swap_usage_raw=$(free -h | grep "Échange:")
while IFS= read -r line; do
	total=$(echo "$line" | awk '{print $2}')
	used=$(echo "$line" | awk '{print $3}')
	free=$(echo "$line" | awk '{print $4}')
done <<< "$swap_usage_raw"
swap_usage_json="{\"total\": \"$total\", \"used\": \"$used\", \"free\": \"$free\"}"

final_json="{\n  \"memory\": $memory_usage_json,\n  \"swap\": $swap_usage_json\n}"

echo "$final_json"

log_info "memory_usage: finished memory usage check"
