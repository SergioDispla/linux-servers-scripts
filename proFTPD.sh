#!/bin/bash
clear

A=`dpkg --get-selections | grep "proftpd" | wc -l`

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
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

if [ $A != 1 ]
then
echo "Paquetes no instalados"
red #CONFIGURACION DE TARJETA EN DHCP
apt-get -y install proftpd
clear
red2 #CONFIGURACION DE TARJETA EN ESTATICA
else 
echo "Paquetes instalados"
red2 #CONFIGURACION DE TARJETA EN ESTATICA
fi

clear
##proftpd.conf
echo "Digite la ruta absoluta del directorio a compartir"
echo "Example: /home/shared/"
read RUT
clear
sed --in-place "11 c\UseIPv6 off" /etc/proftpd/proftpd.conf
sed --in-place "15 c\ServerName			\"`hostname`\" " /etc/proftpd/proftpd.conf 
sed --in-place "34 c\DefaultRoot			$RUT " /etc/proftpd/proftpd.conf

##ftpusers
echo "Desea restringir el acceso a algun usuario?(s/n)"
read S
if [ $S != n ] 
then 
W="s"
	while [ $W != n ]
	do
	echo "Digite el nombre de usuario a restingir"
	read US
	echo $US >> /etc/ftpusers
	echo "Usuario agregado\n"
	echo "Desea agregar a otro usuario?(s/n)"
	read W
	done
fi

echo "Desea agregar usuarios al sistema?(s/n)"
read PR
if [ $PR != "n" ]
then
FR="s"
while [ $FR != "n" ]
do
echo "Digite el nombre de usuario"
read NMR
adduser $NMR
echo "Desea agregar otro usuario?(s/n)"
read FR
done 
fi
/etc/init.d/proftpd restart
echo "Servicio ProFTPD Finalizado"

