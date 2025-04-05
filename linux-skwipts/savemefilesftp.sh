#!/bin/bash
#~~~~~~~~~~#
# Finally Understand: Crucial Keys, Continuous Protection Patch
#~~~~~~~~~~#

if [ "$EUID" -ne 0 ]; then
    echo 'script requires root privileges'
    exit 1
fi

echo "Will you be using the local machine to save these files or a dedicated backup server?"
echo "1 = Local machine"
echo "2 = Dedicated backup server"

read -p "Enter: " userinput
echo "Enter where you want these files backed up (e.g /opt/backup)"
read -p "Directory: " backupdir

if [ $userinput == '1' ]; then
  mkdir $backupdir 

  cp -p /etc/vsftpd.conf $backupdir

  cp -p /etc/fstab $backupdir

  cp -rp /mnt/files $backupdir

  cp -rp /etc/ssh $backupdir

  cp -rp /home $backupdir
  
  tar -czf ~/home/backup.tar.gz $backupdir

else 
  echo "What is the IP of your backup server?"
  read -p "Enter IP: " backupip
  mkdir $backupdir

  cp -p /etc/fstab $backupdir
    
  cp /etc/vsftpd.conf $backupdir

  cp -rp /mnt/files $backupdir

  cp -rp /etc/ssh $backupdir

  cp -rp /home $backupdir

  tar -czf ~/home/backup.tar.gz $backupdir
fi
  scp $backupdir/backup.tar.gz root@$backupip:/root

