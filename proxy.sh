#!/bin/bash 
clear
A=`dpkg --get-selections | grep "squid3" | wc -l`

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

echo "Aviso: Antes de seguir la ejecucion, asegurese de que su maquina cuente
con 2 adaptadores de red configurados de la siguiente forma:\n"
echo "Adaptador 1 (eth0) Red NAT"
echo "Adaptador 2 (eth1) Red Interna\n"
echo "Enter para continuar o Ctrl + Z para detener \n"
read NADA

if [ $A != 2 ]
then
echo "Los paquetes de squid3 no estan instalados"
red ##CONFIGURACION DE RED EN DHCP	
apt-get -y install squid3	
fi

clear
echo "Se procedera a configurar la interface eth1.\n"
red2 #CONFIGURACION DE RED EN ESTATICA

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
(example:midominio.com)\n"
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
sed --in-place "1613 c\http_port 3128" $L
sed --in-place "1056 c\acl clientes src $REDIP" $L
sed --in-place "1211 c\http_access allow clientes" $L
sed --in-place "4855 c\request_header_access Referer deny all" $L
sed --in-place "4856 c\request_header_access X-Forwarded-For deny all" $L
sed --in-place "4857 c\request_header_access Via deny all" $L
sed --in-place "4858 c\request_header_access Cache-Control deny all" $L
sed --in-place "5187 c\visible_hostname `hostname`.$DOM" $L
sed --in-place "7350 c\forwarded_for off" $L
echo "Configuracion basica de proxy finalizada\n"

echo "Desea agregar autenticacion?(s/n)"
read S
if [ $S != n ]
then
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
	echo "Digite el nombre de un usuario nuevo para la autenticacion"
	read USP
	htpasswd -c /etc/squid3/.htpasswd $USP
	echo "Desea agregar otro usuario?(s/n)"
	read Y
	CONT=$(( $CONT + 1 ))
	else 
	echo "Digite el nombre de un usuario nuevo para la autenticacion"
	read USP
	htpasswd /etc/squid3/.htpasswd $USP
	echo "Desea agregar otro usuario?(s/n)"
	read Y
	fi
done
echo "Usuarios agregados"
fi
clear
echo "Desea agregar ACLs?(s/n)"
read H

if [ $H != n ]
then
#Recordar agregar de nuevo la acl de password 
sed --in-place '1062 c\acl denegado url_regex "/etc/squid3/denegado"' $L
sed --in-place '1196 c\http_access deny denegado' $L
	if [ $S = "s" ]
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
echo "Configuracion Finalizada"
fi
clear
echo "Configuracion ACL Finalizada"

#clamav
echo "Desea agregar el servicio de clamav?(s/n)"
read CLV

if [ $CLV != n ]
then
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

/etc/init.d/squid3 restart
echo "Configuracion de CLAMAV finalizada"
fi
fichresolv
echo "Servidor Proxy completado"
