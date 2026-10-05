#!/bin/bash
# This script can be run by anyone to get a quick health report
# and that can be later scheduled automatically

# ----- Script Header ------
echo "################################################"
echo ""
echo " Operating System: $(hostnamectl | grep "Operating System" | awk -F':' '{print $2}')"
echo " Hostname: $(hostname)"
echo " Date and Time: $(date)"
echo " Uptime: $(uptime)"
echo ""
echo "################################################"
echo ""
#
# Prints the CPU load average of the server
echo "------- CPU Info -------"
echo " CPU load average: $(uptime | awk -F'load average: ' '{print $2}')"
echo ""
# Prints your memory usage in percentage
echo "------- Memory Usage -------"
echo " Memory Usage Percentage: $(free | awk '/Mem:/ {printf "%.2f%%\n", $3/$2 * 100}')"
echo ""
# Prints the disk usage for \
echo "------- / Disk Usage  -------"
echo " Disk usage Percentage: $(df -h / | awk 'NR==2 {print $5}') "
echo ""
# Prints the top 5 processes by memory usage
echo "------- Top 5 Processes -------"
echo "$(ps -eo pid,%mem,comm --sort=-%mem | head -n 6)"
echo ""
