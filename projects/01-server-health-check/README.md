## Server Health Check Script
This is a bash health check script for an Ubuntu server. It reports hostname, OS, uptime, CPU load, memory and disk usage, the top 5 processes by memory, and the state of `ssh` and `cron`. It warns when memory or disk is above a threshold (default 80%) or a service is down, exits `0` (healthy), `1` (warning) or `2` (bad input), appends a color-free entry to `~/healthcheck.log`, and runs every 15 minutes from cron.

### How to Run It
1. Make the script executable:
``` chmod +x healthcheck.sh ```
2. Run with default threshold (80%)
``` ./healthcheck.sh ```
3. Run with a custom threshold (e.g., 75%)
``` ./healthcheck.sh 75 ```

### Sample Output
```text
===========================================================================
 [LOG ENTRY] Timestamp: Fri Oct  9 11:51:10 AM UTC 2026 | Hostname: ubuntuvm
===========================================================================
#####################################################
 Operating System:  Ubuntu 24.04.5 LTS
 Hostname: ubuntuvm
 Uptime: up 3 hours, 16 minutes

#####################################################

------- CPU Info -------
 Your CPU load average is 0.00, 0.00, 0.00 on a 4 core processor

------- Memory Usage -------
 Memory Usage Percentage: 3

------- / Disk Usage  -------
 Disk usage Percentage: 33

------- Top 5 Processes -------
    PID %MEM COMMAND
   1350  0.2 /usr/libexec/fwupd/fwupd
    399  0.1 /sbin/multipathd -d -s
    820  0.1 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
    348  0.1 /usr/lib/systemd/systemd-journald
    785  0.0 /usr/libexec/udisks2/udisksd

------- State of Services ------- 
ssh is RUNNING [state: active]
cron is RUNNING [state: active]
------- Disk or Memory Usage -------
Your memory usage is below the threshold 80%
Your disk usage is below the threshold 80%

============================================================================
 [END OF LOG ENTRY]
============================================================================
```

### Scheduling and Automation
This script is configured to run automatically every 15 minutes via user `crontab`. To set up the schedule, open the crontab editor:
```bash
crontab -e
```

### 🧠 Reflections and Lessons Learned
Building this script from scratch provided valuable hands-on experience with Bash nuances, error handling, and log hygiene:
1. **Subshell Variable Scoping:** 
    - **The Mistake:** Initially, piping a code block directly into `tee` (`{...} | tee log.txt`) forced execution into a subshell. Any updates to `WARNING=1` inside the loop were trapped in the child process and lost upon exit.
    - **The Fix:** Redirecting the block output to a temporary file (`> "$REPORT_FILE"`) kept execution in the main shell scope, ensuring exit codes were accurately preserved.
2. **Log Hygiene & ANSI Escape Codes:**
    - **The Mistake:** Colorizing terminal output directly caused raw ANSI escape codes (`\033[...]`) to bleed into `~/healthcheck.log` during manual runs.
    - **The Fix:** Adopting a dual approach—printing colorized output to the terminal for human readability but passing the report through `sed` to strip escape characters before appending to the persistent log file.
3. **Precise Input Validation and Exit Code Separation:**
    - **The Mistake:** Early versions used weak fallback defaults (`${1:-80}`) which silently swallowed empty strings `""` and failed silently on non-numeric inputs.
    - **The Fix:** Implementing strict argument validation (`[[ ... ]]`) that distinguishes between Bad Usage (exit code `2` for invalid inputs) and Server Health Failures (exit code `1` for threshold breaches or downed services), keeping automation scripts predictable.
4. **Resource Management with `trap`:**
    - **The Fix:** Utilizing `mktemp` paired with `trap 'rm -f "$REPORT_FILE"' EXIT` ensures temporary files are safely cleaned up even if the script is interrupted mid-execution via `Ctrl+C`.
5. **Defending Against Integer Overflow with Regex Bounds:**
    - **The Challenge:** Extremely large numeric inputs (such as 20+ digit numbers) bypassed basic checks and caused Bash's integer comparison operators (`lt`, `gt`) to throw internal shell expression errors.
    - **The Solution:** Restricting the input validation regex explicitly to 1–3 digits (`^[0-9]{1,3}$`) ensures that oversized numbers fail immediately on the regex gatekeeper, returning a clean exit code `2` rather than crashing on shell arithmetic limits.
6. **Targeted Cron Redirection and Failure Auditability:**
    - **The Challenge:** Broad redirection (`>/dev/null 2>&1`) completely silences output, meaning script crashes or unexpected stderr errors vanish without a trace.
    - **The Solution:** Separating stream destinations (`>/dev/null 2>/path/to/healthcheck-cron.err`) cleanly discards routine automation noise (stdout) while preserving critical error logs (stderr) for post-mortem debugging.