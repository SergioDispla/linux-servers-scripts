#!/bin/bash 

MENU=1
while [ $MENU != 6 ]
do
clear

#funcion de resolv.conf
fichresolv(){
RE=`cat /etc/resolv.conf | grep "nameserver" | tail -1`
echo $RE > /tmp/RE
echo "domain $DOM
search $DOM
nameserver $IPDNS
$RE" > /etc/resolv.conf
}

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener el adaptador 1 en Red NAT en su VirtualBox
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
echo "Por favor asegurese de tener el adaptador 2 en Red Interna en su VirtualBox
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

echo "BIENVENIDO"
echo "Que desea realizar"
echo "1) Instalacion Proxy Basica"
echo "2) Instalacion de Proxy+Autenticacion(Requiere Instalacion Basica)"
echo "3) Instalacion de Proxy+ACL(Requiere Instalacion Basica)"
echo "4) Instalacion de Proxy+Clamav(Requiere Instalacion Basica)"
echo "5) Instalacion Proxy Transparente(Requiere Maquina Limpia)"
echo "6) Salir"
read MENU
case $MENU in
1)
A=`dpkg --get-selections | grep "squid3" | wc -l`
clear
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
echo "Paquetes instalados"
echo "Se procedera a configurar la interface eth1, presione enter"
read NADA

red2 ##CONFIGURACION DE RED EN ESTATICA

IPRE=`echo $IP | cut -d. -f1,2,3`
IPRED=$IPRE.0
CA=255.0.0.0
CB=255.255.0.0
CC=255.255.255.0

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

echo $DOM > /tmp/DOM
echo $IPDNS > /tmp/IPDNS
RE=`cat /etc/resolv.conf | grep "nameserver" | tail -1`
echo $RE > /tmp/RE

#squid.conf
L='/etc/squid3/squid.conf'
sed --in-place "1613 c\http_port 3128" $L
sed --in-place "1056 c\acl clientes src $REDIP" $L
sed --in-place "1211 c\http_access allow clientes" $L
sed --in-place "4855 c\request_header_access Referer deny all" $L
sed --in-place "4856 c\request_header_access X-Forwarded-For deny all" $L
sed --in-place "4857 c\request_header_access Via deny all" $L
sed --in-place "4858 c\request_header_access Cache-Control deny all" $L
sed --in-place "5187 c\visible_hostname `hostname`.$DOM" $L
sed --in-place "7350 c\forwarded_for off" $L
echo "Configuracion basica de proxy finalizada, ENTER para continuar\n"
read NADA
;;

2)
###VARIABLES PARA QUE FUNCIONE LA FUNCION FICHRESOLV
DOM=`cat /tmp/DOM`
IPDNS=`cat /tmp/IPDNS`
RE=`cat /tmp/RE`
#####################################################
mkdir /tmp/fich
L='/etc/squid3/squid.conf'
clear
apt-get -y install apache2
sed --in-place "1057 c\auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid3/.htpasswd" $L
sed --in-place "1058 c\auth_param basic children 5" $L
sed --in-place "1059 c\auth_param basic realm Squid Basic Authentication" $L
sed --in-place "1060 c\auth_param basic credentialsttl 5 hours" $L
sed --in-place "1061 c\acl password proxy_auth REQUIRED" $L
sed --in-place "1062 c\http_access allow password" $L
clear
Y="s"
CONT=0
while [ $Y != n ]
do
	if [ $CONT = 0 ]
	then
	clear
	echo "Digite el nombre de un usuario nuevo para la autenticacion"
	read USP
	htpasswd -c /etc/squid3/.htpasswd $USP
	echo "Desea agregar otro usuario?(s/n)"
	read Y
	CONT=$(( $CONT + 1 ))
	else 
	clear
	echo "Digite el nombre de un usuario nuevo para la autenticacion"
	read USP
	htpasswd /etc/squid3/.htpasswd $USP
	echo "Desea agregar otro usuario?(s/n)"
	read Y
	fi
clear
done
echo "Usuarios agregados"
echo "Configuracion de Autenticacion Finalizada, ENTER para continuar"
read NADA
;;

3)
###VARIABLES PARA QUE FUNCIONE LA FUNCION FICHRESOLV
DOM=`cat /tmp/DOM`
IPDNS=`cat /tmp/IPDNS`
RE=`cat /tmp/RE`
#####################################################
test -d /tmp/fich
L='/etc/squid3/squid.conf'
clear
#Recordar agregar de nuevo la acl de password 
sed --in-place '1062 c\acl denegado url_regex "/etc/squid3/denegado"' $L
sed --in-place '1196 c\http_access deny denegado' $L
	if [ $? = 0 ]
	then
	sed --in-place '1197 c\http_access allow password' $L
	fi
sed --in-place '1198 c\http_access allow clientes' $L

echo "Digite el nombre de la pagina a denegar, y presione
enter en cada nuevo registro"
echo "Para finalizar digite punto final <.>"
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
echo "Configuracion ACL Finalizada, ENTER para continuar"
read NADA
;;

4) ###CLAMAV

###VARIABLES PARA QUE FUNCIONE LA FUNCION FICHRESOLV
DOM=`cat /tmp/DOM`
IPDNS=`cat /tmp/IPDNS`
RE=`cat /tmp/RE`
#####################################################

cd
apt-get -y update 
apt-get -y upgrade
apt-get -y install clamav 
apt-get -y install clamav-daemon
apt-get -y install gcc
apt-get -y install make
apt-get -y install curl
apt-get -y install libcurl4-gnutls-dev
apt-get -y install c-icap
apt-get -y install libicapapi-dev

/etc/init.d/clamav-freshclam stop
freshclam -v
/etc/init.d/clamav-freshclam start

wget http://downloads.sourceforge.net/project/squidclamav/squidclamav/6.12/squidclamav-6.12.tar.gz 
tar zxvf squidclamav-6.12.tar.gz
cd squidclamav-6.12
./configure --with-c-icap
make
make install
cd
ln -s /etc/c-icap/squidclamav.conf /etc/squidclamav.conf

#editar squiclamav
sed --in-place "18 c\redirect http://www.$DOM" /etc/squidclamav.conf
sed --in-place "6 c\START=yes" /etc/default/c-icap
sed --in-place "142 c\ServerAdmin `hostname`@$DOM" /etc/c-icap/c-icap.conf
sed --in-place "151 c\ServerName `hostname`.$DOM" /etc/c-icap/c-icap.conf
sed --in-place "502 c\Service squidclamav squidclamav.so" /etc/c-icap/c-icap.conf
clear
systemctl restart c-icap

#editar squid.conf
QW='/etc/squid3/squid.conf'
sed --in-place "6519 c\icap_enable on" $QW
sed --in-place "6640 c\adaptation_send_client_ip on" $QW
sed --in-place "6650 c\adaptation_send_username on" $QW
sed --in-place "6655 c\icap_client_username_header X-Authenticated-User" $QW 
sed --in-place "6748 c\icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav" $QW
sed --in-place "6749 c\adaptation_access service_req allow all" $QW
sed --in-place "6750 c\icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav" $QW
sed --in-place "6751 c\adaptation_access service_resp allow all" $QW

echo "Configuracion de CLAMAV finalizada, ENTER para continuar"
read NADA
;;

5)
##NOTA: PARA QUE EL TRANSPARENTE FUNCIONE, SE NECESITA TENER UN SERVER DHCP
##CONFIGURADO PARA QUE REPARTA LA GATEWAY O IP DEL SERVER PROXY

A=`dpkg --get-selections | grep "squid3" | wc -l`
clear
echo "Aviso: Antes de seguir la ejecucion, asegurese de que su maquina cuenta
con 2 adaptadores de red configurados de la siguiente forma:\n"
echo "Adaptador 1 (eth0) Red NAT"
echo "Adaptador 2 (eth1) Red Interna\n"
echo "Enter para continuar o Ctrl + Z para detener"
read NADA
if [ $A != 2 ]
then
echo "Los paquetes de squid3 no estan instalados"
red ##CONFIGURACION DE TARJETA EN DHCP	
apt-get -y install squid3	
fi

clear
echo "Paquetes ya instalados"
echo "Se procedera a configurar la interface eth1, presione enter"
read NADA

#Configuracion de interface
red2 ##CONFIGURACION DE TARJETA 2 EN ESTATICA

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
fichresolv2(){
RE=`cat /etc/resolv.conf | grep "nameserver" | tail -1`
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
echo "Servidor Proxy Completado"
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
fichresolv2
reboot
;;

6)
fichresolv
/etc/init.d/squid3 restart
exit
;;
esac
done
fichresolv
/etc/init.d/squid3 restart
