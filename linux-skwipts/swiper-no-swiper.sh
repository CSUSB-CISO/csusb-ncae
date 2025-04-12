#!/bin/bash

#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
#⠀⠀⠀⠀⠀⠀⠀⣆⠀⠀⠀⠀⠀⠀⠸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠀⠀
#⠀⢠⣦⠀⠀⠀⠀⣿⡆⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠀⠀
#⠀⣿⣿⠀⠀⠀⢸⣿⣿⠀⠀⣷⡀⠀⠀⣼⣿⠀⠀⠀⢀⡴⠀⠀⠀⢰⣿⣿⡀⠀
#⠀⣿⣿⡇⠀⠀⣿⣿⣿⡇⣰⣿⡇⠀⢰⣿⣿⡆⠀⢀⣾⣧⠀⠀⠀⢸⣿⣿⣷⠀
#⠀⣿⣿⣷⡀⢸⣿⣿⣿⣷⣿⣿⣷⠀⣾⣿⣿⣿⡄⣸⣿⣿⣧⣀⠀⢸⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⢠⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣷⣦⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
#⠀⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠀


# Think in your brain to save --> remember
# iptables-save > /etc/iptables/rules.v4 # DEB
# iptables-save > /etc/sysconfig/iptables # RHEL

# Necessary functions

function checkfirewalld() {
    if systemctl is-active --quiet firewalld; then

    echo "####################### WARNING #######################"
    echo            "THE SERVICE FIREWALLD IS ACTIVE"
    echo      "STOP THE SERVICE AND TRY RUNNING THIS AGAIN"
    echo                "systemctl stop firewalld"
    echo "####################### WARNING #######################" 
    exit 1
    fi
}

function checkufw() {
       if systemctl is-active --quiet ufw; then

    echo "####################### WARNING #######################"
    echo            "THE SERVICE UFW IS ACTIVE"
    echo      "STOP THE SERVICE AND TRY RUNNING THIS AGAIN"
    echo                "systemctl stop ufw"
    echo "####################### WARNING #######################" 
    exit 1
    fi
}

function netstats() {

    echo "===== Sucessfully applied firewall rules ====="
    echo
    echo "######## CHECK ESTABLISHED CONNECTIONS ########"

    if netstat --version &>/dev/null; then 
    netstat -n | grep -i established

    else
    ss -ntu | grep -i estab  

    fi 
}

function apply_base_rules() {

    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i "$PRIMARY_INTERFACE" -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -i "$PRIMARY_INTERFACE" -p tcp --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT

}

function resetiptables() {

        # Flush all chains
        iptables -F

        # Delete all chains
        iptables -X

        # Set default policies to ACCEPT
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT

        exit 0
}

#### Service Functions ####
function shellftprules() {

    echo "[!] Checking if firewalld is active..."
    echo 
    checkfirewalld
        
        # Apply rules
        echo "[+] Applying rules..."
        echo
        apply_base_rules
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 445 -j ACCEPT
        iptables -A OUTPUT -j DROP
        iptables -A INPUT -j DROP



            netstats 
            exit 0
}

function dnsrules() {
    echo "[!] Checking if firewalld is active..."
    echo 
    checkfirewalld

        echo "[+] Applying rules..."
        echo
        apply_base_rules
        iptables -A INPUT -i $PRIMARY_INTERFACE -p udp --dport 53 -j ACCEPT
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 53 -j ACCEPT
        iptables -A OUTPUT -j DROP
        iptables -A INPUT -j DROP

            netstats
            exit 0

}

# Wolly Winston Warfare
function wwwrules() { 
    echo "[!] Checking if UFW is active..."
    echo 
    checkufw

    read -p "Enter your Certificate Authority IP: " CERTIFICATE_IP


        echo "[+] Applying rules..."
        echo
        apply_base_rules
        iptables -A OUTPUT -d $CERTIFICATE_IP -p tcp --dport 443 -j ACCEPT
        iptables -A OUTPUT -d $CERTIFICATE_IP -j ACCEPT
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 80 -j ACCEPT
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 443 -j ACCEPT
        iptables -A OUTPUT -j DROP
        iptables -A INPUT -j DROP

            netstats
            exit 0
}
# Darn Barn
function dbrules() {

echo "Are you using POSTGRESQL or MYSQL? Select 1 or 2"
echo "1. PostgreSQL"
echo "2. MySQL"

read -p "Enter your number: " databaseinput

    if [[ $databaseinput == '1' ]]; then 

    echo "[!] Checking if UFW is active..."
    echo 
    checkufw

        echo "[+] Applying rules..."
        echo
        apply_base_rules
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 5432 -j ACCEPT
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 22 -j ACCEPT
        iptables -A OUTPUT -j DROP
        iptables -A INPUT -j DROP

            netstats
            exit 0

    else 

    echo "[!] Checking if UFW is active..."
    echo 
    checkufw

        echo "[+] Applying rules..."
        echo
        apply_base_rules
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 3306 -j ACCEPT
        iptables -A INPUT -i $PRIMARY_INTERFACE -p tcp --dport 22 -j ACCEPT
        iptables -A OUTPUT -j DROP
        iptables -A INPUT -j DROP

            netstats
            exit 0

    fi 
}
####  End  ####


# Prompt for distro or reset 
function distro {
echo -e "\e[1mWhat distro/system are you on?\e[0m"
distrochoice=("Ubuntu/Debian" "RHEL/Rocky/CentOS" "Reset" "Quit")
select opt in "${distrochoice[@]}"
do 
    case $opt in
        "Ubuntu/Debian")
		        service
            ;;
        "RHEL/Rocky/CentOS")
            	service
            ;;
        "Reset")
                echo "[!] Resetting to default iptables configuration..."
                resetiptables
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

# Prompt for the type of service 
function service() {
echo -e "\e[1mWhat service are you on?\e[0m"
servicechoice=("FTP-SHELL" "DNS" "Webserver" "Database" "Quit")
select opt in "${servicechoice[@]}"
do 
    case $opt in
        "FTP-SHELL")
            shellftprules
            ;; 
        "DNS")
            dnsrules
            ;;
        "Webserver")
	        wwwrules
            ;;
        "Database")
	        dbrules
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

}

function main_menu() {
    
    PRIMARY_INTERFACE=$(ip -br a | awk '{print $1}' | grep -v lo)
        if [[ -z "$PRIMARY_INTERFACE" ]]; then 
            echo "Error: COULD NOT FIND PRIMARY INTERFACE" 
            echo "CONFIGURE INTERFACE MANUALLY" 
            exit 1
        fi
    echo -e "[!] Using network interface: \033[0;32m$PRIMARY_INTERFACE\033[0m"

	distro

}

main_menu

