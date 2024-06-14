#!/bin/bash

clear
A=$(dpkg --get-selections | grep "bind9[^-*]" | wc -l)
B=$(dpkg --get-selections | grep "isc-dhcp-server" | wc -l)

##FUNCTION FOR DHCP CONFIGURATION
red(){ 
echo "Please ensure your network adapter is set to NAT in your VirtualBox.
Press ENTER to continue"
read NADA
sed --in-place "5 c\#NADA" /etc/apt/sources.list
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
ifdown eth0
ifup eth0 
echo "Interface configuration complete" 
}

##FUNCTION FOR STATIC CONFIGURATION
red2(){
echo "Please change the network adapter to Internal Network in your VirtualBox.
Press ENTER to continue"
read NADA
echo "Enter your IP address"
read IP
echo "Enter your subnet mask"
read MASK
echo "Enter your gateway address"
read GAT
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet static
address $IP
netmask $MASK
gateway $GAT " > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Interface configuration complete"
}

if [ $A != 2 ]
then
echo "The bind9 and isc-dhcp-server packages are not installed."
red ##CONFIGURE THE CARD FOR DHCP WITH NAT
clear
	if [ $B != 1 ]
	then 
	apt-get -y install bind9 bind9utils isc-dhcp-server
	echo "Ready"
	else
	apt-get -y install bind9 bind9utils
	echo "Ready"
	fi
clear
red2 #CONFIGURE THE NETWORK CARD FOR STATIC

else
	if [ $B != 1 ]
	then
	echo "Package isc-dhcp-server not installed."
	red #CONFIGURE THE CARD FOR DHCP WITH NAT
	apt-get -y install isc-dhcp-server
	fi 
clear
echo "Bind9 and isc-dhcp-server packages installed."
red2 #CONFIGURE THE NETWORK CARD FOR STATIC 
fi

clear
echo "Enter your DNS domain name (Example: mydomain.com)"
read DOM
##HOSTS FILE
echo "Working on the hosts file"
sed --in-place "2 c\127.0.1.1	`hostname`.$DOM 	`hostname`" /etc/hosts
sed --in-place "3 c\ $IP	`hostname`.$DOM 	`hostname`" /etc/hosts
sed --in-place "3 a\ " /etc/hosts

##HOST.CONF FILE
echo "Working on the host.conf file"
echo "order bind,hosts 
multi on" > /etc/host.conf

##RESOLV.CONF FILE
echo "Working on the resolv.conf file"
echo "domain $DOM
search $DOM
nameserver $IP" > /etc/resolv.conf

#BIND FILES
echo "Working on bind"
cd /etc/ ; chown bind:bind bind ; cd bind
cp db.local db.$DOM
cp db.127 db.$IP
chown bind:bind db.$DOM
chown bind:bind db.$IP

#named.conf
echo " " >> /etc/bind/named.conf
echo " " >> /etc/bind/named.conf
sed --in-place "12 c\include \"/etc/bind/rndc.key\"; " /etc/bind/named.conf
sed --in-place "13 c\############################### " /etc/bind/named.conf
echo "controls { 
	inet 127.0.0.1 port 953 
	allow { 127.0.0.1; } keys { \"rndc-key\"; };
}; " >> named.conf
echo "named.conf ready"

#named.conf.options
sed --in-place "2 c\		directory \"/etc/bind\"; " /etc/bind/named.conf.options
echo "named.conf.options ready"

#named.conf.local
X=$(echo $IP | cut -d. -f1)
Y=$(echo $IP | cut -d. -f2)
Z=$(echo $IP | cut -d. -f3)
INV=$Z.$Y.$X
echo "zone \"$DOM\" {
	type master;
	file \"db.$DOM\";
	allow-update { key \"rndc-key\"; };
	notify yes;
}; \n

zone \"$INV.in-addr.arpa\" {
	type master;
	file \"db.$IP\";
	allow-update { key \"rndc-key\"; };
	notify yes;
};" > /etc/bind/named.conf.local
echo "named.conf.local ready"

#db.zonaprimaria
echo > /etc/bind/db.$DOM
echo "\$ORIGIN	.
\$TTL	86400
$DOM	IN	SOA	`hostname`.$DOM. root.$DOM. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL


		NS	`hostname`.$DOM.
\$ORIGIN		$DOM.
`hostname`	A	$IP" > /etc/bind/db.$DOM
echo "Primary zone ready"

#db.zonainversa
IPV2=$(echo $IP | cut -d. -f4)
echo > /etc/bind/db.$IP
echo "\$ORIGIN	.
\$TTL	86400
$INV.in-addr.arpa	IN	SOA	`hostname`.$DOM. root.$DOM. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL

		NS	`hostname`.$DOM.
\$ORIGIN		$INV.in-addr.arpa.
$IPV2		PTR	`hostname`.$DOM." > /etc/bind/db.$IP
echo "Reverse zone ready"

clear
#verification
echo "Checking files"
named-checkconf
echo "named.conf ready"
named-checkconf named.conf.local
echo "named.conf.local ready"
named-checkconf named.conf.options
echo "named.conf.options ready"
named-checkzone $DOM db.$DOM
echo "checkzone $DOM"
named-checkzone $INV.in-addr.arpa. db.$IP
/etc/init.d/bind9 restart
echo "DNS SERVICE COMPLETED"

#DHCP
echo "Working on DHCP"
echo > /etc/default/isc-dhcp-server 
echo "INTERFACES=\"eth0\" " > /etc/default/isc-dhcp-server
RANGE=$X.$Y.$Z
cd ; cd /etc/dhcp/
clear
echo "Enter the range for your DHCP server"
echo "Initial IP"
read RANG2
echo "Range $RANG2 - "
echo "Final IP"
read RANG3
echo "Range $RANG2 - $RANG3"
echo > dhcpd.conf

echo "server-identifier	$IP;
ddns-updates		on;
ddns-update-style	interim;
ddns-domainname		\"$DOM\";
ddns-rev-domainname	\"in-addr.arpa.\";
deny 			client-updates;

include \"/etc/bind/rndc.key\";

zone $DOM. {
	primary 127.0.0.1;
	key rndc-key;
}

zone $INV.in-addr.arpa. {
	primary 127.0.0.1;
	key rndc-key;
}

default-lease-time 3600;
max-lease-time 	86400;
authoritative;
log-facility local7;

subnet $RANGE.0 netmask $MASK {
	range $RANG2 $RANG3;
	option routers $GAT;
	option domain-name \"$DOM.\";
	option domain-name-servers $IP;
	option broadcast-address $RANGE.255;
}" > dhcpd.conf
cd
echo "dhcpd.conf ready"
/etc/init.d/bind9 restart
/etc/init.d/isc-dhcp-server restart
echo "DHCP SERVICE COMPLETED"
