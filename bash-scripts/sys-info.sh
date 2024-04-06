#!/bin/bash

# Gather system information
system_info() {
    echo "### System Information ###"
    echo "Hostname: $(hostname)"
    echo "Operating System: $(uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p)"
    echo "Total Memory: $(free -m | awk '/Mem:/ {print $2 " MB"}')"
    echo "Total Disk Space: $(df -h --total | awk '/total/ {print $2}')"
}

# Gather package upgrade information
package_info() {
    echo "### Package Upgrade Information ###"
    echo "Number of Upgradable Packages: $(apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l)"
}

# Main function
main() {
    system_info
    package_info
}

# Run the main function
main
