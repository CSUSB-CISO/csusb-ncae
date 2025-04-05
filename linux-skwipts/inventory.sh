#!/bin/bash

# Function to print section headers with consistent formatting
print_header() {
    echo ""
    echo "===== $1 ====="
}

# Function to print subsection headers
print_subheader() {
    echo "== $1 =="
}

# Function to print a separator line
print_separator() {
    echo "----------------------------------------"
}

# Main script starts here
print_header "System Inventory"

print_subheader "Hostname and Time"
echo "Hostname: $(hostname)"
echo "Date and Time: $(date)"
echo "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel Version: $(uname -r)"
print_separator

print_subheader "Network Information"
echo "IP Addresses:"
ip addr | grep "inet " | awk '{print $2}' | cut -d/ -f1
echo ""
echo "Network Connections:"
ss -tuln
print_separator

print_subheader "User Information"
who
echo ""
echo "Human users (UID >= 1000):"
awk -F: '($3 >= 1000 && $3 != 65534) {print "Username: " $1 ", UID: " $3 ", Home: " $6}' /etc/passwd
print_separator

print_subheader "Service Information"
if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service --state=running | grep ".service"
else
    service --status-all | grep "+"
fi
print_separator

print_subheader "Process Information"
ps aux
print_separator

echo ""
echo "System inventory completed at $(date)"
