#!/bin/bash

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
