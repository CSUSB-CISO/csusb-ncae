#!/bin/bash

# Check if approved users file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 approved_users.txt"
    exit 1
fi

APPROVED_USERS_FILE="$1"

# Check if file exists
if [ ! -f "$APPROVED_USERS_FILE" ]; then
    echo "Error: Approved users file '$APPROVED_USERS_FILE' not found"
    exit 1
fi

# Read approved users into an array
mapfile -t APPROVED_USERS < "$APPROVED_USERS_FILE"

echo "Users in /etc/passwd not in approved list:"

# Read /etc/passwd and check each user
while IFS=':' read -r username _ remainder; do
    # Skip system users with UID < 1000 (optional, remove if you want to check all users)
    uid=$(echo "$remainder" | cut -d':' -f1)
    if [ "$uid" -lt 1000 ]; then
        continue
    fi
    
    # Check if username is not in approved list
    if [[ ! " ${APPROVED_USERS[@]} " =~ " ${username} " ]]; then
        echo "$username"
    fi
done < /etc/passwd