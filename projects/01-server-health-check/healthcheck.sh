#!/bin/bash
# This script can be run by anyone to get a quick health report
# and that can be later scheduled automatically

# ----- Script Header ------
echo "################################################"
echo ""
echo " Hostname: $(hostname)"
echo " Date and Time: $(date)"
echo " Uptime: $(uptime)"
echo ""
echo "################################################"
echo ""
#
# Prints the CPU load average of the server
echo " CPU load average: $(uptime | awk -F'load average: ' '{print $2}')"
echo ""
# Prints your memory usage in percentage
echo " Memory Usage Percentage: $(free | awk '/Mem:/ {printf "%.2f%%\n", $3/$2 * 100}')"

