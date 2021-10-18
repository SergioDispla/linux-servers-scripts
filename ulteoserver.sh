#!/bin/bash

clear
#comprobacion de paquetes
A=`dpkg --get-selections | grep "mysql" | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "
auto lo
iface lo inet loopback\n
auto eth0
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
echo "
auto lo
iface lo inet loopback\n
auto eth0
iface eth0 inet static
address $IP
netmask $MASK " > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

if [ $A != 3 ]
then 
echo "Los paquetes necesarios no se encuentran instalados"
red ##FUNCION DHCP
wget -O - http://archive.ulteo.com/ovd/4.0.3/ubuntu/dists/trusty/ulteo_lists > /etc/apt/sources.list.d/ulteo_ovd.list
wget -O - http://archive.ulteo.com/ovd/4.0.3/ubuntu/dists/trusty/keyring | apt-key add -
apt-get update
apt-get -y install mysql-server
clear
echo "Se creara la base de datos OVD, digite su contraseña de root para mysql"
mysql -u root -p -e 'create database ovd'
apt-get -y install ulteo-ovd-session-manager
apt-get -y install ulteo-ovd-administration-console
apt-get -y install ulteo-ovd-web-client
clear
red2 ##RED ESTATICA
else
clear
echo "Paquetes necesarios ya instalados"
fi

echo "Servicio Finalizado"

