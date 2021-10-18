#!/bin/bash
cd
clear

###FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
sed --in-place "12 c\iface enp0s3 inet dhcp" /etc/network/interfaces
sed --in-place "12 a\##NADA" /etc/network/interfaces
sed --in-place "12 a\##NADA" /etc/network/interfaces
ifdown enp0s3
ifup enp0s3
echo "Configuracion de interface lista" 
}

##FUNCION PARA CONFIGURACION EN ESTATICA
red2(){
clear
echo "Configuracion de la interface"
echo "Por favor cambie su adaptador de red a Red Interna en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "Inserte su direccion IP"
read IP
echo "Inserte su mascara de RED"
read MASK
sed --in-place "12 c\iface enp0s3 inet static" /etc/network/interfaces
sed --in-place "13 c\address $IP " /etc/network/interfaces
sed --in-place "14 c\netmask $MASK " /etc/network/interfaces
echo "Configuracion de interface lista"
echo "Se reiniciara el equipo. ENTER para continuar"
read NADA
sleep 1; echo "5"
sleep 1; echo "4"
sleep 1; echo "3"
sleep 1; echo "2"
sleep 1; echo "1"
init 6
}

red
##Descarga de paquetes necesarios###
apt-get update
apt-get -y install build-essential 
apt-get -y install gcc
apt-get -y install make 
apt-get -y install apache2 apache2-utils
apt-get -y install libapache2-mod-php7.0
apt-get -y install php7.0
apt-get -y install php7.0.cli
apt-get -y install php7.0-common 
apt-get -y install unzip 
apt-get -y install wget 
apt-get -y install sendmail 
apt-get -y install inotify-tools 
apt-get -y install ssh
#Descomprimir fichero OSSEC-HIDS
clear
echo "Descargando OSSEC-HIDS"
wget https://github.com/ossec/ossec-hids/archive/2.9.0.tar.gz
tar -xvzf 2.9.0.tar.gz
clear
sh install.sh

/var/ossec/bin/ossec-control start
sed --in-place "28 c\PermitRootLogin yes" /etc/ssh/sshd_config
sed --in-place "78 c\    <frequency>60</frequency>" /var/ossec/etc/ossec.conf
sed --in-place "79 c\    <alert_new_files>yes</alert_new_files>" /var/ossec/etc/ossec.conf
sed --in-place "81 c\    <directories report_changes=\"yes\" realtime=\"yes\" check_all=\"yes\">/etc,/usr/bin,/usr/sbin</directories>" /var/ossec/etc/ossec.conf
sed --in-place "82 c\    <directories report_changes=\"yes\" realtime=\"yes\" check_all=\"yes\">/var/www,/bin,/sbin</directories>" /var/ossec/etc/ossec.conf
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "31 a\#NADA " /var/ossec/rules/local_rules.xml
sed --in-place "33  <rule id=\"554\" level=\"7\" overwrite=\"yes\">" /var/ossec/rules/local_rules.xml
sed --in-place "34   <category>ossec</category>" /var/ossec/rules/local_rules.xml 
sed --in-place "35   <decoded_as>syscheck_new_entry</decoded_as>" /var/ossec/rules/local_rules.xml
sed --in-place "36   <description>File added to the system.</description>" /var/ossec/rules/local_rules.xml
sed --in-place "37   <group>syscheck,</group>" /var/ossec/rules/local_rules.xml
sed --in-place "38  </rule>" /var/ossec/rules/local_rules.xml
service ssh restart
##Reiniciar ossec
clear
/var/ossec/bin/ossec-control restart
sleep 5

##Descargando OSSEC-WUI
clear
echo "Descargando OSSEC-WUI"
cd
wget https://github.com/ossec/ossec-wui/archive/master.zip
unzip *.zip
mv ossec-wui-master /var/www/html/ossec
cd /var/www/html/ossec
./setup.sh

clear
echo "Instalacion Completada"
sleep 5
red2
