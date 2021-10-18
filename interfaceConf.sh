#!/bin/bash

echo "Seleccionar tipo de configuracion para su interface"
echo "1) Configuracion DHCP"
echo "2) Configuracion Estatica"
read OP

case $OP in
1)  
echo "Cambie el adaptador de red por NAT, y presione enter"
read NADA
cp /etc/network/interfaces /tmp/
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp " > /etc/network/interfaces
ifdown eth0
ifup eth0
echo "Listo"
;;

2)
echo "Cambie el adaptador de red por RED INTERNA, y presione enter"
read NADA 
echo "Digite su direccion IP"
read IP
echo "Digite su mascara de RED"
read MASK
echo "Digite su direccion de GATEWAY"
read GAT
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet static 
address $IP
netmask $MASK  
gateway $GAT " > /etc/network/interfaces

ifdown eth0
ifup eth0

echo "Digite el nombre del servidor DNS al que pertenece este equipo"
read DNS
echo "Digite la direccion IP de su servidor DNS"
read IPDNS
echo "domain $DNS
search $DNS
nameserver $IPDNS" > /etc/resolv.conf
echo "Listo"
;;

*) echo "Seleccione una opcion valida"
read OP
;;
esac
