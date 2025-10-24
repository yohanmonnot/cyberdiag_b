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
total_used_percentage=0
count=0
while IFS= read -r line; do
  if [[ $line == *"Sys. de fichiers"* ]]; then
    continue
  fi
  filesystem=$(echo "$line" | awk '{print $1}')
  size=$(echo "$line" | awk '{print $2}')
  used=$(echo "$line" | awk '{print $3}')
  available=$(echo "$line" | awk '{print $4}')
  use_percentage=$(echo "$line" | awk '{print $5}' | tr -d '%')
  mounted_on=$(echo "$line" | awk '{print $6}')

  disk_usage_json+="{\"filesystem\": \"$filesystem\", \"size\": \"$size\", \"used\": \"$used\", \"available\": \"$available\", \"use_percentage\": \"$use_percentage%\", \"mounted_on\": \"$mounted_on\"},"
  total_used_percentage=$((total_used_percentage + use_percentage))
  count=$((count + 1))
done <<< $(df -h | grep -v "Sys. de fichiers")
disk_usage_json=${disk_usage_json%,}  # Remove the trailing comma
disk_usage_json+="]"

# Calculate average used percentage
if [[ $count -gt 0 ]]; then
  average_used_percentage=$((total_used_percentage / count))
else
  average_used_percentage=0
fi

# Calculate global score based on average usage percentage
if [[ $average_used_percentage -lt 20 ]]; then
  SCORE=5
elif [[ $average_used_percentage -lt 40 ]]; then
  SCORE=4
elif [[ $average_used_percentage -lt 60 ]]; then
  SCORE=3
elif [[ $average_used_percentage -lt 80 ]]; then
  SCORE=2
else
  SCORE=1
fi

final_json="{\n  \"disk_usage\": $disk_usage_json,\n  \"score\": $SCORE\n}"

echo "$final_json"

log_info "disk_usage: finished disk usage check with score $SCORE/5"
