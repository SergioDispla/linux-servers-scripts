#!/bind/bash

clear
A=`dpkg --get-selections | grep "bind9[^-*]" | wc -l`
B=`dpkg --get-selections | grep "isc-dhcp-server" | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
sed --in-place "5 c\#NADA" /etc/apt/sources.list
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
ifdown eth0
ifup eth0 
echo "Configuracion de interface lista" 
}

##FUNCION PARA CONFIGURACION EN ESTATICA
red2(){
echo "Por favor cambie el adaptador de red a Red Interna en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "Inserte su direccion IP"
read IP
echo "Inserte su mascara de RED"
read MASK
echo "Digite su direccion de GATEWAY"
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
echo "Configuracion de interface lista"
}

if [ $A != 2 ]
then
echo "Los paquetes bind9 y isc-dhcp-server no estan instalados"
red ##CONFIGURA LA TARJETA PARA DHCP CON NAT
clear
	if [ $B != 1 ]
	then 
	apt-get -y install bind9 bind9utils isc-dhcp-server
	echo "Listo"
	else
	apt-get -y install bind9 bind9utils
	echo "Listo"
	fi
clear
red2 #CONFIGURA LA TARJETA DE RED EN ESTATICA

else
	if [ $B != 1 ]
	then
	echo "Paquete isc-dhcp-server no instalado"
	red #CONFIGURA LA TARJETA PARA DHCP CON NAT
	apt-get -y install isc-dhcp-server
	fi 
clear
echo "Paquetes Bind9 y isc-dhcp-server instalados"
red2 #CONFIGURA LA TARJETA DE RED EN ESTATICA 
fi

clear
echo "Ingrese el nombre de su dominio DNS (Example: midominio.com)"
read DOM
##FICHERO HOSTS
echo "Trabajando en el fichero hosts"
sed --in-place "2 c\127.0.1.1	`hostname`.$DOM 	`hostname`" /etc/hosts
sed --in-place "3 c\ $IP	`hostname`.$DOM 	`hostname`" /etc/hosts
sed --in-place "3 a\ " /etc/hosts

##FICHERO HOST.CONF
echo "Trabajando en el fichero host.conf"
echo "order bind,hosts 
multi on" > /etc/host.conf

##FICHERO RESOLV.CONF
echo "Trabajando en el fichero resolv.conf"
echo "domain $DOM
search $DOM
nameserver $IP" > /etc/resolv.conf

#FICHEROS BIND
echo "Trabajando en bind"
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
echo "named.conf listo"

#named.conf.options
sed --in-place "2 c\		directory \"/etc/bind\"; " /etc/bind/named.conf.options
echo "named.conf.options listo"

#named.conf.local
X=`echo $IP | cut -d. -f1`
Y=`echo $IP | cut -d. -f2`
Z=`echo $IP | cut -d. -f3`
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
echo "named.conf.local listo"

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
echo "Zona primaria lista"

#db.zonainversa
IPV2=`echo $IP | cut -d. -f4`
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
echo "Zona inversa lista"

clear
#comprobacion
echo "Comprobando los ficheros"
named-checkconf
echo "named.conf listo"
named-checkconf named.conf.local
echo "named.conf.local listo"
named-checkconf named.conf.options
echo "named.conf.options listo"
named-checkzone $DOM db.$DOM
echo "checkzone $DOM"
named-checkzone $INV.in-addr.arpa. db.$IP
/etc/init.d/bind9 restart
echo "SERVICIO DNS COMPLETADO"

#DHCP
echo "Trabajando en DHCP"
echo > /etc/default/isc-dhcp-server 
echo "INTERFACES=\"eth0\" " > /etc/default/isc-dhcp-server
RANGE=$X.$Y.$Z
cd ; cd /etc/dhcp/
clear
echo "Ingrese el rango de su servidor DHCP"
echo "IP Inicial"
read RANG2
echo "Rango $RANG2 - "
echo "IP Final"
read RANG3
echo "Rango $RANG2 - $RANG3"
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
echo "dhcpd.conf listo"
/etc/init.d/bind9 restart
/etc/init.d/isc-dhcp-server restart
echo "SERVICIO DHCP COMPLETADO"

