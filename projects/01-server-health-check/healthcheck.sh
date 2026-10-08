#!/bin/bash
# This script can be run by anyone to get a quick health report
# and that can be later scheduled automatically
#
# ------- VARIABLES -------
#

OPERATING_SYSTEM=$(hostnamectl | grep "Operating System" | awk -F':' '{print $2}')
HOST_NAME=$(hostname)
DATE_AND_TIME=$(date)
UPTIME_PRETTY=$(uptime -p)
CPU_LOAD_AVERAGE=$(uptime | awk -F'load average: ' '{print $2}')
MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f\n", $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2 { sub("%", "", $5); print $5 }')
TOP_5_PROCESSES=$(ps -eo pid,%mem,args --sort=-%mem | head -n 6)
SERVICES=("ssh" "cron") # bash array
THRESHOLD=${1:-80}
WARNING=0
LOG_FILES="$HOME/healthcheck.log"

# --- Color ---

if [-t 1]; then
	RED="\033[31m"
	GREEN="\033[32m"
	RESET="\033[0m"
else
	RED=""
	GREEN=""
	RESET=""
fi

# -------------------------------------------------------------------------------

# ------- Script Header -------
{
echo ""
echo "==========================================================================="
echo " [LOG ENTRY] Timestamp: $(date) | Hostname: $HOST_NAME"
echo "==========================================================================="
echo "#####################################################"
echo " Operating System: $OPERATING_SYSTEM"
echo " Hostname: $HOST_NAME"
echo " Date and Time: $DATE_AND_TIME"
echo " Uptime: $UPTIME_PRETTY"
echo ""
echo "#####################################################"
echo ""
#
# Prints the CPU load average of the server
echo "------- CPU Info -------"
echo " Your CPU load average is $CPU_LOAD_AVERAGE on a $(nproc) core processor"
echo ""
# Prints your memory usage in percentage
echo "------- Memory Usage -------"
echo " Memory Usage Percentage: $MEMORY_USAGE"
echo ""
# Prints the disk usage for /
echo "------- / Disk Usage  -------"
echo " Disk usage Percentage: $DISK_USAGE"
echo ""
# Prints the top 5 processes by memory usage
echo "------- Top 5 Processes -------"
echo "$TOP_5_PROCESSES"
echo ""
echo "------- State of Services ------- "
# Looping through each service in an array
for SERVICE in "${SERVICES[@]}"; do
	# Get the service state (e.g., active, inactive, failed, unknown)
	SERVICE_STATE=$(systemctl is-active "$SERVICE")
	# Check if the service is currently running
	if [ "$SERVICE_STATE" = "active" ]; then
		echo -e "${GRREN}$SERVICE is RUNNING [state: $SERVICE_STATE]${RESET}"
	else
		echo -e "${RED}$SERVICE is not running [state: $SERVICE_STATE]${RESET}"
		WARNING=1
	fi
done
# Threshold Warning
echo "------- Disk or Memory Usage -------"
if [ "$MEMORY_USAGE" -gt "$THRESHOLD" ];
then
	echo -e  "${RED}WARNING: Memory usage at $MEMORY_USAGE% (threshold $THRESHOLD%)${RESET}"
	WARNING=1
else
	echo -e "${GREEN}Your memory usage is below the threshold $THRESHOLD%${RESET}"
fi
if [ "$DISK_USAGE" -gt "$THRESHOLD" ];
then
	echo -e "${RED}WARNING: Disk usage at $DISK_USAGE% (threshold $THRESHOLD%)${RESET}"
	WARNING=1
else
	echo -e "${GREEN}Your disk usage is below the threshold $THRESHOLD%${RESET}"

fi
echo ""
echo "============================================================================"
echo " [END OF LOG ENTRY]"
echo "============================================================================"
echo ""

} | tee -a "$LOG_FILE"

# Exit with 1 if any warning fired
exit "$WARNING"
