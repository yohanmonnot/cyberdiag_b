#!/bin/bash
source "$(dirname "$0")/../../utils/logger.sh"
log_info "cpu_usage: starting CPU usage check"

# Check if top command is available
if ! command -v top &> /dev/null; then
    log_error "cpu_usage: top command is not available"
    echo '{"error": "top command is not available"}'
    exit 1
fi

# Check CPU usage
cpu_usage_raw=$(top -bn1 | grep "Cpu(s)")
while IFS= read -r line; do
  user=$(echo "$line" | awk '{print $2}' | tr -d ',')
  system=$(echo "$line" | awk '{print $4}' | tr -d ',')
  nice=$(echo "$line" | awk '{print $6}' | tr -d ',')
  idle=$(echo "$line" | awk '{print $8}' | tr -d ',')
  wait=$(echo "$line" | awk '{print $10}' | tr -d ',')
  hardware_interrupts=$(echo "$line" | awk '{print $12}' | tr -d ',')
  software_interrupts=$(echo "$line" | awk '{print $14}' | tr -d ',')
  stolen=$(echo "$line" | awk '{print $16}' | tr -d ',')

  # Calculate used percentage
  used_percentage=$((100 - idle))
  # Calculate score based on usage percentage
  if [[ $used_percentage -lt 20 ]]; then
    SCORE=5
  elif [[ $used_percentage -lt 40 ]]; then
    SCORE=4
  elif [[ $used_percentage -lt 60 ]]; then
    SCORE=3
  elif [[ $used_percentage -lt 80 ]]; then
    SCORE=2
  else
    SCORE=1
  fi
done <<< "$cpu_usage_raw"
cpu_usage_json="{\"user\": \"$user\", \"system\": \"$system\", \"nice\": \"$nice\", \"idle\": \"$idle\", \"wait\": \"$wait\", \"hardware_interrupts\": \"$hardware_interrupts\", \"software_interrupts\": \"$software_interrupts\", \"stolen\": \"$stolen\", \"score\": $SCORE}"

echo "$cpu_usage_json"

log_info "cpu_usage: finished CPU usage check with score $SCORE/5"
