#!/bin/bash

# Get all users with UID >= 1000 (regular users)
function checksudoers() {

echo "######################################"
echo "Checking users with sudo privileges..."
echo

users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

echo "User           | Sudo Access"
echo "---------------|-------------"

for user in $users; do
    groups=$(id -nG "$user")
    if echo "$groups" | grep -qwE 'sudo|wheel'; then
        printf "%-15s| YES\n" "$user"
    else
        printf "%-15s| NO\n" "$user"
    fi
done

echo "#######################################"

}

function checkcronjobs 

checksudoers | tee output.txt