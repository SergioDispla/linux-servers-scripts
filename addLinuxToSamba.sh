#!/bin/bash
clear
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
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp " > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

red ##RED DHCP NAT
apt-get -y install realmd sssd
apt-get -y install sssd-tools
apt-get -y install adcli
apt-get -y install samba-common-bin
clear
red2 ##RED DHCP INTERNA
clear
#configuracion de dns
clear
echo "Configuracion de DNS"
echo "Digite el nombre del dominio DNS al que pertenece este equipo"
read DNS
echo "Digite el nombre de equipo de su servidor SAMBA"
read NOMSMB
echo "Digite el nombre de equipo de su servidor DNS"
read NOMDNS
echo "Digite la direccion IP de su servidor SAMBA"
read IPS
echo "Digite la direccion IP de su servidor DNS"
read IPD
#resolv.conf
echo "Trabajando en resolv.conf"
echo "domain $DNS
search $DNS
nameserver $IPS
nameserver $IPD" > /etc/resolv.conf
chattr +i /etc/resolv.conf
echo "Listo"

sed --in-place "2 c\127.0.1.1	`hostname`.$DNS	`hostname`" /etc/hosts
sed --in-place "3 c\ $IPS	$NOMSMB.$DNS	$NOMSMB" /etc/hosts
sed --in-place "3 a\ $IPD	$NOMDNS.$DNS	$NOMDNS" /etc/hosts

echo "order bind,hosts
multi on" > /etc/host.conf

systemctl enable sssd
echo "Enter para continuar"
read NADA
realm discover $DNS
echo "Enter para continuar"
read NADA
realm join --user=administrator $DNS
echo "Enter para continuar"
read NADA
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0077" >> /etc/pam.d/common-session
clear
echo "Listo, se equipo fue agregado al controlador de dominio SAMBA"
echo "Debe cerrar sesion e ingresar con usuario del dominio"
echo "dominio\nombreUsuario"
echo "Enter para finalizar"
read NADA
