#!/bind/bash 

A=`dpkg --get-selections | grep nis | wc -l`
B=`dpkg --get-selections | grep rpcbind | wc -l`

##FUNCION PARA CONFIGURAR TARJETA CON DHCP
red(){ 
echo "Por favor asegurese de tener el adaptador de red en NAT en su VirtualBox 
Presione ENTER para continuar"
read NADA
sed --in-place "5 c\##NADA" /etc/apt/sources.list
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
ifdown eth0
ifup eth0 
echo "Configuracion de interface lista" 
}

##FUNCION PARA CONFIGURAR TARJETA EN DHCP INTERNA
red2(){
echo "Por favor cambie el adaptador de red a Red Interna en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
ifdown eth0
ifup eth0 
echo "Configuracion de interface lista" 
}

if [ $A != 4 ]
then 
echo "nis y nfs-kernel-server no estan instalados"
red ##CONFIGURACION DE RED EN NAT
apt-get -y install nis portmap
echo "Listo"
clear
red2 ##CONFIGURACION DE RED EN DHCP
clear

else
echo "nis y nfs-kernel-server ya estan instalados"
red2 ##CONFIGURACION DE RED EN DHCP
echo "Reconfigurando su dominio NIS \n"
dpkg-reconfigure nis
echo "Listo"
fi

#yp.conf
echo "Trabajando en yp.conf"
echo "Ingrese la direccion IP de su servidor NIS"
read IPN
echo "Ingrese el nombre de maquina de su servidor NIS"
read NOM
echo "Ingrese el nombre de su dominio NIS: example.local"
read YP
echo "Ingrese el nombre de su dominio DNS: example.com"
read DNS
echo "ypserver		$NOM.$DNS
domain	$YP	server	$NOM.$DNS" > /etc/yp.conf

#nsswitch.conf
echo "Trabajando en nsswitch.conf"
sed --in-place "7 c\passwd:		compat	nis" /etc/nsswitch.conf
sed --in-place "8 c\group:		compat	nis" /etc/nsswitch.conf
sed --in-place "9 c\shadow:		compat	nis" /etc/nsswitch.conf
sed --in-place "12 c\hosts:		files dns nis" /etc/nsswitch.conf

#common-session
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session

#hosts
sed --in-place "4 c\ $IPN		$NOM.$DNS	$NOM \n" /etc/hosts

echo "SERVICIO NIS CLIENTE COMPLETADO"
echo "REINICIE EL SISTEMA"
