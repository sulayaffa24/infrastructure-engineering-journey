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
THRESHOLD=10
EXIT_CODE=0
WARNING=0
# -------------------------------------------------------------------------------

# ------- Script Header -------
echo "################################################"
echo ""
echo " Operating System: $OPERATING_SYSTEM"
echo " Hostname: $HOST_NAME"
echo " Date and Time: $DATE_AND_TIME"
echo " Uptime: $UPTIME_PRETTY"
echo ""
echo "################################################"
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
	# Check if the service is currently running
	if systemctl is-active --quiet "$SERVICE"; then
		echo "$SERVICE is RUNNING"
	else
		echo "$SERVICE has STOPPED"
	fi
done
# Threshold Warning
echo "------- Disk or Memory Usage -------"
if [ $MEMORY_USAGE -gt $THRESHOLD ] || [ $DISK_USAGE -gt $THRESHOLD ]
then
	echo -e  "\033[31mWARNING: Your disk or memory usage is above the threshold $THRESHOLD%!\033[m"
	echo $?
else
	echo -e "\033[32mYour disk or memory usage is below the threshold $THRESHOLD%\033[m"
	echo $?
fi

