#!/bin/bash


# Hi Laughing Man, if you're reading this it's too late. :)

# lol it's way too late to finish this now fuuuuuck

# Check if rbash exists

USER_FILE=$1

if [[ -f /bin/rbash ]]; then
    while read -r line; do
    chsh -s $line
    done < $USER_FILE
else
    echo "Rbash does not exist" 
    echo "Install it" 
    exit 1
fi 

#while read -p line in $USER_FILE; do

    

