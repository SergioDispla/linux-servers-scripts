#!/bin/bash
clear
cd
##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
auto enp0s3
iface enp0s3 inet dhcp" > /etc/network/interfaces
ifdown enp0s3
ifup enp0s3
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
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
auto enp0s3
iface enp0s3 inet static
address $IP
netmask $MASK " > /etc/network/interfaces

echo "Configuraracion de Interface lista"
echo "Se reiniciara el equipo. Enter para continuar"
read NADA
init 6
}

red
apt-get update
apt-get -y install make 
apt-get -y install apache2
apt-get -y install mysql-server
apt-get -y install php
apt-get -y install perl 
apt-get -y install libapache2-mod-perl2
apt-get -y install libapache2-mod-php
apt-get -y install libio-compress-perl 
apt-get -y install libxml-simple-perl 
apt-get -y install libdbi-perl
apt-get -y install libdbd-mysql-perl
apt-get -y install libapache-dbi-perl libsoap-lite-perl libnet-ip-perl
apt-get -y install php-mysql php-gd php7.0-dev php-mbstring php-soap php-curl
cd
sed --in-place "656 c\post_max_size = 128M" /etc/php/7.0/apache2/php.ini
sed --in-place "809 c\upload_max_filesize = 128M" /etc/php/7.0/apache2/php.ini
sed --in-place "106 c\ServerName localhost" /etc/apache2/apache2.conf
cd
wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.2.1/OCSNG_UNIX_SERVER-2.2.1.tar.gz
tar -zxvf OCSNG_UNIX_SERVER-2.2.1.tar.gz
cd OCSNG_UNIX_SERVER-2.2.1
sleep 3; clear
echo "Se iniciara el asistente de instalacion del OCS. Por favor utilizar manual para guiarse"
sleep 5; sh setup.sh

red2

