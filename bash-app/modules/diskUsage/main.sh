#!/bin/bash
source "$(dirname "$0")/../../utils/logger.sh"
log_info "disk_usage: starting disk usage check"

# Check if df command is available
if ! command -v df &> /dev/null; then
	log_error "disk_usage: df command is not available"
	echo '{"error": "df command is not available"}'
	exit 1
fi

# Check disk usage
disk_usage_json="["
while IFS= read -r line; do
	if [[ $line == *"Sys. de fichiers"* ]]; then
		continue
	fi
	filesystem=$(echo "$line" | awk '{print $1}')
	size=$(echo "$line" | awk '{print $2}')
	used=$(echo "$line" | awk '{print $3}')
	available=$(echo "$line" | awk '{print $4}')
	use_percentage=$(echo "$line" | awk '{print $5}')
	mounted_on=$(echo "$line" | awk '{print $6}')
	disk_usage_json+="{\"filesystem\": \"$filesystem\", \"size\": \"$size\", \"used\": \"$used\", \"available\": \"$available\", \"use_percentage\": \"$use_percentage\", \"mounted_on\": \"$mounted_on\"},"
done <<< $(df -h | grep -v "Sys. de fichiers")
disk_usage_json=${disk_usage_json%,}  # Remove the trailing comma
disk_usage_json+="]"

echo "$disk_usage_json"

log_info "disk_usage: finished disk usage check"
