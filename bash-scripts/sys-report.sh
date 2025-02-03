#!/bin/bash

# Delete reports older than 60 days
find /opt/reports -type f -name "system_report_*.txt" -mtime +60 -exec rm -f {} \;

# Get the current Date-Time Group (DTG)
DTG=$(date +"%Y-%m-%d %H:%M:%S")

# Define the output file
OUTPUT_FILE="/opt/reports/system_report_$(date +%Y%m%d_%H%M%S).txt"

{
  # Header with creation time
  echo "Created on: $DTG"
  echo

  # Host Information
  echo "=== Host Information ==="
  echo "Hostname: $(hostname)"
  echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo "CPU: $(top -bn1 | grep '%Cpu(s)' | awk '{print 100 - $8"% used"}')"
  echo "RAM: $(free -h | awk '/Mem:/ {print $3"/"$2}')"
  echo "Storage: $(df -h --total | grep total | awk '{print $3"/"$2}')"
  echo "Serial Number: $(sudo dmidecode -s system-serial-number 2>/dev/null || echo "N/A")"
  echo
  echo

  # Network Interfaces
  echo "=== Network Interfaces ==="
  ip a
  echo
  echo

  # Routing Table
  echo "=== Routing Table ==="
  route -n
  echo
  echo

  # WireGuard Configurations
  echo "=== WG configs ==="
  if ls /etc/wireguard/*.conf 1> /dev/null 2>&1; then
    for file in /etc/wireguard/*.conf; do
      echo "File: $file"
      cat "$file"
      echo
      echo
    done
  else
    echo "No WireGuard configuration files found."
  fi
  echo
  echo

  # WireGuard Status
  echo "=== WG status ==="

  # ANSI color codes
  BLACK_ON_RED='\033[41;30m'  # Black text on red background
  RESET='\033[0m'             # Reset to default

  # Get the system time zone
  timezone=$(timedatectl | grep "Time zone:" | awk '{print $3}')

  # Print the table header
  printf "%-15s | %-20s | %-15s\n" "Interface" "Latest Handshake $timezone" "Status"
  printf "%-15s | %-20s | %-15s\n" "--------------" "-------------------" "---------------"

  # Set variables
  for iface in $(wg show interfaces); do
      latest_handshake=$(wg show $iface latest-handshakes | awk '{ if ($2 != "0") print strftime("%Y-%m-%d %H:%M:%S", $2); }')
      status=$(systemctl is-active wg-quick@$iface)

      if [ -n "$latest_handshake" ]; then
          # Calculate the time since the last handshake
          last_handshake_time=$(date -d "$latest_handshake" +%s)
          current_time=$(date +%s)
          time_diff=$((current_time - last_handshake_time))

          # Check if the difference is more than 5 minutes (300 seconds)
          if [ $time_diff -gt 300 ]; then
              printf "${BLACK_ON_RED}%-15s | %-20s | %-15s${RESET}\n" "$iface" "$latest_handshake" "$status"
          else
              printf "%-15s | %-20s | %-15s\n" "$iface" "$latest_handshake" "$status"
          fi
      else
          printf "%-15s | %-20s | %-15s\n" "$iface" "No Handshake" "$status"
      fi
  done

  echo
  echo

} > "$OUTPUT_FILE"

# Set permissions for the report
chmod 777 "$OUTPUT_FILE"

# Notify the user
echo "Report saved to $OUTPUT_FILE"