#!/bin/bash
clear
cd

red(){
echo "Por favor asegurese de tener el adaptador de red en NAT. Enter para continuar"
read NADA
echo "auto lo
iface lo inet loopback \n
auto eth0 
iface eth0 inet dhcp
\#NADA
\#NADA " > /etc/network/interfaces
ifdown eth0
ifup eth0
}

red2(){
echo "Por favor cambie su adaptador de red a Red Interna. Enter para continuar"
read NADA
echo "Digite su direccion IP"
read IP
echo "Digite su mascara de red"
read MASK
sed --in-place "5 c\iface eth0 inet static" /etc/network/interfaces
sed --in-place "6 c\address $IP " /etc/network/interfaces 
sed --in-place "7 c\netmask $MASK " /etc/network/interfaces
ifdown eth0
ifup eth0
}
red
cd
clear
apt-get update
apt-get -y install build-essential
apt-get -y install build-essential
apt-get -y install ssh
wget  -U ossec http://www.ossec.net/files/ossec-hids-2.8.1.tar.gz

tar -zxvf ossec-hids-2.8.1.tar.gz
cd ossec-hids-2.8.1
./install.sh

##Iniciar el servicio Ossec
/var/ossec/bin/ossec-control start
echo "Enter para continuar"
read NADA

clear
red2
echo "Digite su direccion de red (example:192.168.1.0/24)"
read IPRED

iptables -I INPUT -p udp --dport 1514 -s $IPRED -j ACCEPT
iptables -I OUTPUT -p udp --sport 1514 -d $IPRED -j ACCEPT

sed --in-place "28 c\PermitRootLogin yes" /etc/ssh/sshd_config
sed --in-place "75 c\    <frequency>30</frequency>" /var/ossec/etc/ossec.conf
service ssh restart
echo "Finalizado"
echo "Ejecutar /var/ossec/bin/manage_agents desde xShell5"


