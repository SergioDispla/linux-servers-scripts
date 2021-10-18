#!/bin/bash

cd
clear

red(){
clear
echo "Por favor asegurese de tener su adaptador de red en NAT"
echo "Enter para continuar"
read NADA
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
allow-hotplug eth0
iface eth0 inet dhcp"  > /etc/network/interfaces
echo "Espere..."
ifdown eth0
ifup eth0
}

red2(){
echo "Por favor cambie su adaptador de red a Red Interna"
echo "Enter para continuar"
read NADA
echo "Como desea configurar su tarjeta de red:"
echo "1) DHCP (Debe de tener un servidor DHCP funcionando)"
echo "2) IP Estatica"
read OP
case $OP in
1) 
echo "Configuracion por DHCP"
ifdown eth0
ifup eth0
;;
2)
clear
echo "Configuracion IP Estatica"
echo "Digite su direccion IP"
read IP
echo "Digite su mascara de red"
read MASK
echo "Digite IP de gateway"
read GAT
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
allow-hotplug eth0
iface eth0 inet static
address $IP
netmask $MASK  
gateway $GAT " > /etc/network/interfaces
echo "Espere..."
ifdown eth0 
ifup eth0
;;
esac
} 

red
apt-get update 
apt-get -y install snmp snmpd
red2
echo "Digite su IP de red (example: 192.168.1.0/24) "
read IPRED
sed --in-place "15 c\##NADA" /etc/snmp/snmpd.conf
sed --in-place "17 c\agentAddress udp:161,udp6:[::1]:161" /etc/snmp/snmpd.conf
sed --in-place "45 c\view   all        included   .1.3.6.1.2.1.1" /etc/snmp/snmpd.conf
sed --in-place "46 c\view   all        included   .1.3.6.1.2.1.25.1" /etc/snmp/snmpd.conf
sed --in-place "51 c\rocommunity public $IPRED " /etc/snmp/snmpd.conf
sed --in-place "53 c\rocommunity public 127.0.0.1" /etc/snmp/snmpd.conf
sed --in-place "79 c\sysLocation	telematic " /etc/snmp/snmpd.conf
sed --in-place "80 c\sysContact	admin <admin@domain> " /etc/snmp/snmpd.conf
sed --in-place "11 c\SNMPDOPTS=\'-Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid\' " /etc/default/snmpd

/etc/init.d/snmpd restart
echo "Listo, servicio SNMP configurado"

