#!/bin/bash
source "$(dirname "$0")/../../utils/logger.sh"
log_info "diskUsage: starting disk usage check"

# Check disk usage
echo "=== Disk Usage ==="
df -h

# Check memory usage
echo "=== Memory Usage ==="
free -h

# Check CPU usage
echo "=== CPU Usage ==="
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* us.*/\1/"

log_info "diskUsage: finished disk usage check"
