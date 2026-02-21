#!/bin/bash

read -p "Team Number: " team
read -p "Host Name: " name
read -p "Ip: " ip
read -p "How many times have you run this: " serial

cp -rp /var/named /root/bind_backup.d
cp -rp /etc/named.conf /root/named.conf.bak

if [ ! -d /var/named/zones ]; then
        mkdir /var/named/zones
fi

cp /var/named/named.empty /var/named/zones/forward.ncaecybergames.org
cp /var/named/named.empty /var/named/zones/reverse.ncaecybergames.org
cp /var/named/named.empty /var/named/zones/forward.team.net
cp /var/named/named.empty /var/named/zones/reverse.team.net

cat << done > /etc/named.conf
zone "team$team.ncaecybergames.org" IN {
        type master;
        file "/var/named/zones/forward.ncaecybergames.org";
};

zone "18.172.in-addr.arpa" IN {
        type master;
        file "/var/named/zones/reverse.ncaecybergames.org";
};

zone "team$team.net" IN {
        type master;
        file "/var/named/zones/forward.team.net";
};

zone "$team.168.192.in-addr.arpa" IN {
        type master;
        file "/var/named/zones/reverse.team.net";
};
done

cat << done > /var/named/zones/forward.ncaecybergames.org
\$TTL    86400
@       IN      SOA     team$team.ncaecybergames.org root (
                              $serial         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name
$name   IN      A       $ip
ns1     IN      A       172.18.13.$team
www     IN      A       172.18.13.$team
files   IN      A       172.18.14.$team
shell   IN      A       172.18.14.$team
done

cat << done > /var/named/zones/reverse.ncaecybergames.org
\$TTL    86400
@       IN      SOA     team$team.ncaecybergames.org. root.team$team.ncaecybergames.org. (
                              $serial         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name.
$team.13        IN      PTR     ns1.team$team.ncaecybergames.org.
$team.13        IN      PTR     www.team$team.ncaecybergames.org.
$team.14        IN      PTR     files.team$team.ncaecybergames.org.
$team.14        IN      PTR     shell.team$team.ncaecybergames.org.
done

cat << done > /var/named/zones/forward.team.net
\$TTL    86400
@       IN      SOA     team$team.net root (
                              $serial         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name
$name   IN      A       $ip
ns1     IN      A       192.168.$team.12
www     IN      A       192.168.$team.5
db1     IN      A       192.168.$team.7
done

cat << done > /var/named/zones/reverse.team.net
\$TTL    86400
@       IN      SOA     team$team.net. root.team$team.net. (
                              $serial         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name.
12      IN      PTR     ns1.team$team.net.
7       IN      PTR     db1.team$team.net.
5       IN      PTR     www.team$team.net.
done

chown -R named:named /var/named
systemctl restart named
systemctl status named
