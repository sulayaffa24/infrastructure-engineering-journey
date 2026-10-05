#!/bin/bash
# This script can be run by anyone to get a quick health report
# and that can be later scheduled automatically
#
# ------- VARIABLES -------
#

OPERATING_SYSTEM=$(hostnamectl | grep "Operating System" | awk -F':' '{print $2}')
HOSTNAME=$(hostname)
DATE_AND_TIME=$date
UPTIME_PRETTY=$(uptime -p)
CPU_LOAD_AVERAGE=$(uptime | awk -F'load average: ' '{print $2}')
MEMORY_USAGE_PERCENTAGE=$(free | awk '/Mem:/ {printf "%.2f%%\n", $3/$2 * 100}')
DISK_USAGE_PERCENTAGE=$(DF -H / | awk 'NR==2 {print $5}')
TOP_5_PROCESSES=$(ps -eo pid,%mem,comm --sort=-%mem | head -n 6)

# ------- Script Header -------
echo "################################################"
echo ""
echo " Operating System: $OPERATING_SYSTEM"
echo " Hostname: $HOSTNAME"
echo " Date and Time: $DATE_AND_TIME"
echo " Uptime: $UPTIME_PRETTY"
echo ""
echo "################################################"
echo ""
#
# Prints the CPU load average of the server
echo "------- CPU Info -------"
echo " CPU load average: $CPU_LOAD_AVERAGE"
echo ""
# Prints your memory usage in percentage
echo "------- Memory Usage -------"
echo " Memory Usage Percentage: $MEMORY_USAGE_PERCENTAGE"
echo ""
# Prints the disk usage for \
echo "------- / Disk Usage  -------"
echo " Disk usage Percentage: $DISK_USAGE_PERCENTAGE"
echo ""
# Prints the top 5 processes by memory usage
echo "------- Top 5 Processes -------"
echo "$TOP_5_PROCESSES"
echo ""
