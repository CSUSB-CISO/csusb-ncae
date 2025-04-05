#!/bin/bash
#~~~~~~~
# A second approach to this?
#         ___
#    .-"`   `"-.
#  .'           '.
# /               \
#/  #              \
#| #               |
#|                 |
#;     .-~~~-.     ;
# ;     )   (     ;
#  \   (     )   /
#   \   \   /   /
#    \   ) (   /
#     |  | |  |
#     |__|_|__|
#     {=======}
#     }======={
#     {=======}
#     }======={
#  jgs{=======}
#      `""u""`
#~~~~~~~

if [ "$EUID" -ne 0 ]; then
    echo 'script requires root privileges'
    exit 1
fi

while  true; do 
echo "Enter a source directory: (e.g /etc/ssh)"
read -p "Source directory: " sourcedir
echo "Enter a destination directory: (e.g /opt/backups"
read -p "Destination directory: " destdir

rsync -av $sourcedir $destdir

echo "Should we add this as a cronjob to constantly replace the files with the backup directory?"
echo "1 = Yes" 
echo "2 = No"
read -p "Enter: " cronselect

if [ $cronselect = '1' ]; then
    echo "*/2 * * * * root rsync -a $destdir $sourcedir" >> /etc/crontab

else
    echo "Restarting..."
fi

done
