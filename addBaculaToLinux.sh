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
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
allow-hotplug eth0
iface eth0 inet dhcp"  > /etc/network/interfaces
echo "Espere...."
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

red ###DHCP NAT
apt-get update 
apt-get -y install bacula-common bacula-fd
red2 ###RED INTERNA

clear
echo "Digite el nombre de su servidor bacula"
read NOM
echo "Digite la contraseña de su director del servidor bacula"
read PASS
echo "Digite la direccion IP de este cliente"
read IP
sed --in-place "14 c\  Name = $NOM-dir" /etc/bacula/bacula-fd.conf
sed --in-place "15 c\  Password = \"$PASS\" " /etc/bacula/bacula-fd.conf
sed --in-place "23 c\  Name = $NOM-mon" /etc/bacula/bacula-fd.conf
sed --in-place "24 c\  Password = \"$PASS\" " /etc/bacula/bacula-fd.conf 
sed --in-place "37 c\  FDAddress = $IP " /etc/bacula/bacula-fd.conf
sed --in-place "43 c\  director = $NOM-dir = all, !skipped, !restored" /etc/bacula/bacula-fd.conf
/etc/init.d/bacula-fd restart
echo "Listo"
