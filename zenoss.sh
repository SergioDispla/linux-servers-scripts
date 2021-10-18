#!/bin/bash
clear
cd
#comprobacion de paquetes
A=`dpkg --get-selections | grep "mysql-server" | wc -l`

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
echo "Inserte su direccion IP"
read IP
echo "Inserte su mascara de RED"
read MASK
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet static
address $IP
netmask $MASK " > /etc/network/interfaces
ifdown eth0
ifup eth0
}

clear

if [ $A != 3 ]
then
red
apt-get update 
apt-get -y install mysql-server mysql-client
cd
wget https://phoenixnap.dl.sourceforge.net/project/zenoss/zenoss-2.5/zenoss-2.5.2/zenoss-stack-2.5.2-linux-x64.bin
chmod +x zenoss-stack-2.5.2-linux-x64.bin
red2 
fi
cd
./zenoss-stack-2.5.2-linux-x64.bin
