#!/bin/bash
clear
cd
###FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
sed --in-place "10 c\iface eth0 inet dhcp" /etc/network/interfaces
sed --in-place "10 a\##NADA" /etc/network/interfaces
sed --in-place "10 a\##NADA" /etc/network/interfaces
ifdown eth0
ifup eth0
echo "Configuracion de interface lista" 
}

##FUNCION PARA CONFIGURACION EN ESTATICA
red2(){
clear
echo "Configuracion de la interface"
echo "Inserte su direccion IP"
read IPR
echo "Inserte su mascara de RED"
read MASK
sed --in-place "10 c\iface eth0 inet static" /etc/network/interfaces
sed --in-place "11 c\address $IPR " /etc/network/interfaces
sed --in-place "12 c\netmask $MASK " /etc/network/interfaces
echo "Configuracion de interface lista"
sleep 3
clear
echo "Recuerde ingresar al navegador para continuar la configuracion: http://$IPR/cacti"
echo "Enter para continuar"
read NADA

ifdown eth0
ifup eth0
}

red 
apt-get update
apt-get -y install apache2
apt-get -y install php5
apt-get -y install mysql-server
apt-get -y install phpmyadmin
apt-get -y install cacti cacti-spine

red2
