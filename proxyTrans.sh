#!/bin/bash 
clear
A=`dpkg --get-selections | grep "squid3" | wc -l`

##NOTA: PARA QUE EL TRANSPARENTE FUNCIONE SE NECESITA TENER UN SERVER DHCP
##Y QUE TENGA CONFIGURADO COMO IP DE GATEWAY LA DEL SERVER PROXY PARA QUE LA REPARTA

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador 1 en red NAT en su VirtualBox
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
echo "Por favor asegurese de tener su adaptador 2 en Red Interna en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "Inserte su direccion IP"
read IP
echo "Inserte su mascara de RED"
read MASK
echo "
allow-hotplug eth1
iface eth1 inet static
address $IP
netmask $MASK " >> /etc/network/interfaces
ifdown eth1
ifup eth1 2> /dev/null
echo "Configuracion de interface lista"
}

echo "Aviso: Antes de seguir la ejecucion, asegurese de que su maquina cuenta
con 2 adaptadores de red configurados de la siguiente forma:\n"
echo "Adaptador 1 (eth0) Red NAT"
echo "Adaptador 2 (eth1) Red Interna\n"
echo "Enter para continuar o Ctrl + Z para detener"
read NADA
if [ $A != 2 ]
then
echo "Los paquetes de squid3 no estan instalados"
red ##CONFIGURACION DE RED EN DHCP
apt-get -y install squid3	
fi

clear
echo "Paquetes ya instalados"
echo "Se procedera a configurar la interface eth1, presione enter"
read NADA

#Configuracion de interface
red2 ##CONFIGURACION DE RED EN ESTATICA

IPRE=`echo $IP | cut -d. -f1,2,3`
IPRED=$IPRE.0
CA=255.0.0.0
CB=255.255.0.0
CC=255.255.255.0
echo "network $IPRED" >> /etc/network/interfaces
if [ $MASK = $CA ]
then
REDIP=$IPRED/8
elif [ $MASK = $CB ]
then
REDIP=$IPRED/16
elif [ $MASK = $CC ]
then
REDIP=$IPRED/24
fi
clear
echo "Ingrese el nombre de su dominio al que pertenece este equipo:
(example:midominio.com)"
read DOM
echo "Ingrese el nombre de maquina de su servidor DNS"
read NOMDNS
echo "Ingrese la IP de su servidor DNS"
read IPDNS
echo "Trabajando en el fichero hosts"
echo "127.0.0.1		localhost
127.0.1.1		`hostname`.$DOM 	`hostname`
$IPDNS		$NOMDNS.$DOM 		$NOMDNS
$IP		`hostname`.$DOM		`hostname`

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" > /etc/hosts

echo "order bind,hosts
multi on " > /etc/host.conf

#funcion de resolv.conf
fichresolv(){
RE=`grep "nameserver" /etc/resolv.conf`
echo "domain $DOM
search $DOM
nameserver $IPDNS
$RE" > /etc/resolv.conf
chattr +i /etc/resolv.conf
}

#squid.conf

L='/etc/squid3/squid.conf'

sed --in-place "1613 c\http_port 3128 transparent" $L
sed --in-place "1056 c\acl clientes src $REDIP" $L
sed --in-place "1211 c\http_access allow clientes" $L
sed --in-place "4855 c\request_header_access Referer deny all" $L
sed --in-place "4856 c\request_header_access X-Forwarded-For deny all" $L
sed --in-place "4857 c\request_header_access Via deny all" $L
sed --in-place "4858 c\request_header_access Cache-Control deny all" $L
sed --in-place "5187 c\visible_hostname `hostname`.$DOM" $L
sed --in-place "7350 c\forwarded_for off" $L
echo "Configuracion basica de proxy finalizada\n"

clear
echo "Desea agregar ACLs?(s/n)"
read H

if [ $H != n ]
then
#Recordar agregar de nuevo la acl de password 
sed --in-place '1062 c\acl denegado url_regex "/etc/squid3/denegado"' $L
sed --in-place '1196 c\http_access deny denegado' $L
sed --in-place '1198 c\http_access allow clientes' $L

echo "Digite el nombre de la pagina a denegar, y presione
enter en cada nuevo registro"
echo "Para finalizar digite punto ."
PAG="s"
MICONT=0
while [ $PAG != "." ]
do
read PAG
echo $PAG >> /etc/squid3/denegado
MICONT=$(( $MICONT + 1 ))
done
sed --in-place "$MICONT c\#prueba" /etc/squid3/denegado
sed --in-place "1211 c\#NADA" $L
echo "Configuracion Finalizada"
/etc/init.d/squid3 restart
fi
clear
echo "Configuracion ACL Finalizada"
fichresolv

echo "Servidor Proxy completado"

#Script de ejecucion inicial
echo '#!/bin/bash
echo "BIENVENIDO" > /etc/motd
IPS=`cat /etc/network/interfaces | grep address | cut -d" " -f2`
# squid server IP
SQUID_SERVER="$IPS"
# Interface connected to Internet
INTERNET="eth0"
# Interface connected to LAN
LAN_IN="eth1"
# Squid port
SQUID_PORT="3128"
# DO NOT MODIFY BELOW
# Clean old firewall
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
# Load IPTABLES modules for NAT and IP conntrack support
modprobe ip_conntrack
modprobe ip_conntrack_ftp
# For win xp ftp client
#modprobe ip_nat_ftp
echo 1 > /proc/sys/net/ipv4/ip_forward
# Setting default filter policy
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
# Unlimited access to loop back
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Allow UDP, DNS and Passive FTP
iptables -A INPUT -i $INTERNET -m state --state ESTABLISHED,RELATED -j ACCEPT
# set this system as a router for Rest of LAN
iptables --table nat --append POSTROUTING --out-interface $INTERNET -j MASQUERADE
iptables --append FORWARD --in-interface $LAN_IN -j ACCEPT
# unlimited access to LAN
iptables -A INPUT -i $LAN_IN -j ACCEPT
iptables -A OUTPUT -o $LAN_IN -j ACCEPT
# DNAT port 80 request comming from LAN systems to squid 3128 ($SQUID_PORT) aka transparent proxy
iptables -t nat -A PREROUTING -i $LAN_IN -p tcp --dport 80 -j DNAT --to $SQUID_SERVER:$SQUID_PORT
# if it is same system
iptables -t nat -A PREROUTING -i $INTERNET -p tcp --dport 80 -j REDIRECT --to-port $SQUID_PORT
# DROP everything and Log it
iptables -A INPUT -j LOG
iptables -A INPUT -j DROP
' > /etc/init.d/transparent.sh

chmod 777 /etc/init.d/transparent.sh
update-rc.d transparent.sh defaults
clear
echo "Squid Transparente listo"
echo "Se reiniciara el equipo, presione enter para continuar"
read NADA
reboot
