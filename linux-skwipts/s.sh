#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2    
    exit 1
fi
echo -n "Enter the output file path for collected keys (required): "
read -r ahhhh < /dev/tty

if [ -z "$ahhhh" ]; then
  echo "No path provided. Exiting without making changes."
  exit 1
fi

mkdir -p "$(dirname "$ahhhh")"
: > "$ahhhh"

# Append all actual keys (no file names)
find / -type f -name authorized_keys 2>/dev/null | while IFS= read -r file; do
  echo "|--> Found authorized_keys at: $file"
  grep -v '^[[:space:]]*#' "$file" | grep -v '^[[:space:]]*$' >> "$ahhhh"
  echo >> "$ahhhh"
done


# === Ask loser if they want to add a key ===
echo -n "Would you like to add your public key now? [y/N]: "
read answer < /dev/tty

case "$answer" in
  [yY]|[yY][eE][sS])
    echo ""
    echo "Paste your public key below and press [Enter]:"
    read loser_key < /dev/tty
    echo "$loser_key" >> "$ahhhh"
    echo "Your key has been added to $ahhhh"
    ;;
  *)
    echo "No additional key added."
    ;;
esac

echo ""
echo "|==============================================================================|"
echo "|================ Keys found and saved to $ahhhh ================|"
echo "|==============================================================================|"
echo ""
nl "$ahhhh"
sshd_config="/etc/ssh/sshd_config"
backup="/etc/ssh/sshd_config.bak.whoopsielmao"
cp "$sshd_config" "$backup"
echo "Backup of sshd_config saved to $backup"

if grep -q '^#\?AuthorizedKeysFile' "$sshd_config"; then
    sed -i 's|^#\?AuthorizedKeysFile.*|AuthorizedKeysFile /etc/lemntrie/citrus|' "$sshd_config"
else
    echo "AuthorizedKeysFile /etc/lemntrie/citrus" >> "$sshd_config"
fi
echo "SSHD configured to use /etc/lemntrie/citrus as the authorized_keys file."


if grep -q '^#\?PubkeyAuthentication' "$sshd_config"; then
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$sshd_config"
else
    echo "PubkeyAuthentication yes" >> "$sshd_config"
fi

echo ""
echo -n "Would you like to disable password authentication now? [y/N]: "
read disable_pw < /dev/tty

case "$disable_pw" in
  [yY]|[yY][eE][sS])
    if grep -q '^#\?PasswordAuthentication' "$sshd_config"; then
        sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
    else
        echo "PasswordAuthentication no" >> "$sshd_config"
    fi
    echo "Password authentication disabled."
    ;;
  *)
    echo "Password authentication left enabled."
    ;;
esac

chmod 644 $ahhhh
chown root:root $ahhhh
chmod 755 $ahhhh
echo ""
echo "PLEASE READ ALL OF THIS MESSAGE BEFORE CONTINUING:"
echo ""
sleep 3
echo "Make sure to check the keys file one more time BEFORE restarting ssh"
echo "I even added a quick way for you to do so now!"
echo "⌄"
echo "vim $ahhhh"
echo "^"
echo "once youre done, copy/paste the following command to restart ssh:"
echo ""
echo "systemctl restart sshd"
echo "or"
echo "service sshd restart"
echo "or"
echo "systemctl restart ssh"
echo "or"
echo "service ssh restart"
echo ""
echo "mb if none of these work lmao"
echo ""
echo "Now try to ssh into the server from another terminal"
echo "If you can log in, then you did it right"
echo "If youre nervous, reboot the server to reset all connections"
echo "If you can't log in, something is wrong, fix it immediately from this terminal before rebooting"
echo ""
echo "Press [Enter] when you're ready to continue..."
read -r < /dev/tty

if [ -f "$0" ] && [ -w "$0" ]; then
  echo "PLEASE clear your bash history with:"
  echo ""
  echo "history -c"
  echo ""
  sleep 4
  echo "anyways"
  sleep 3
  echo "bring it home"
  sleep 2
  echo "my final message"
  sleep 2
  echo "goodbye"
  sleep 1
  echo "initializing self-destruct sequence  (deleting script from disk)"
  sleep 2
  echo ""
  echo "|==============================================================================|"
  echo "|===========I love you guys <3, good luck. We're all cheering you on===========|"
  echo "|==============================================================================|"
  echo ""
  sleep 1
  rm -- "$0"
else
  echo "PLEASE clear your bash history with:"
  echo ""
  echo "history -c"
  echo ""
  echo "running from pipe or shell — skipping self-destruct. good job lol"
  sleep 3  
  echo ""
  echo "|==============================================================================|"
  echo "|===========I love you guys <3, good luck. We're all cheering you on===========|"
  echo "|==============================================================================|"
  echo ""
fi