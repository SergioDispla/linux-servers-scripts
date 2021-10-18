#!/bind/bash 

clear
A=`dpkg --get-selections | grep nis | wc -l`
B=`dpkg --get-selections | grep rpcbind | wc -l`
C=`dpkg --get-selections | grep nfs-kernel-server | wc -l`

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

##FUNCION PARA CONFIGURAR TARJETA EN ESTATICA
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
clear
echo "Configuracion de interface lista"
}

if [ $A != 4 ]
then 
red #CONFIGURACION TARJETA DE RED EN NAT
	if [ $C != 1 ]
	then
	echo "nis y nfs-kernel-server no estan instalados"
	apt-get -y install nis portmap nfs-kernel-server
	echo "Listo"
	else
	apt-get -y install nis portmap
	echo "Listo"
	fi
clear
red2 #CONFIGURACION DE RED EN ESTATICA
else
	if [ $C != 1 ]
	then
	echo "nfs-kernel-server no esta instalado"
	red #CONFIGURACION DE RED EN NAT
	apt-get -y install nfs-kernel-server
	echo "Listo"
	fi
clear
echo "nis y nfs-kernel-server ya estan instalados"
red2 #CONFIGURACION DE RED EN ESTATICA

echo "Reconfigurando su dominio NIS \n"
echo "Ingrese el nombre de su dominio nis, siguiendo la sintaxis: example.local"
read NISD
echo $NISD > /etc/defaultdomain
fi
clear
#/etc/default/nis
echo "Trabajando en el fichero nis"
sed --in-place "6 c\NISSERVER=master" /etc/default/nis

#/etc/ypserv
echo "Trabajando en el fichero ypserv.securenets"
RANGE=`echo $IP | cut -d. -f1,2,3`
echo "255.0.0.0 127.0.0.0\n
$MASK		$RANGE.0 " > /etc/ypserv.securenets

#/vary/yp/Makefile
echo "Trabajando en el fichero Makefile"
sed --in-place "119 c\ALL = passwd shadow group hosts rpc services netid protocols netgrp" /var/yp/Makefile

#hosts
NISD=`cat /etc/defaultdomain`
DOM=`echo $NISD | cut -d. -f1`

echo "Trabajando en el fichero hosts \n" 
echo "Ingrese la direccion IP de su servidor DNS 
Nota: En caso de que su servidor NIS sea el mismo que el DNS
indicarla igualmente\n" 
read IPDNS
echo " "
echo "Ingrese el nombre de equipo de su servidor DNS 
Nota: En caso de que su servidor NIS sea el mismo que el DNS
indicarlo igualmente \n"
read NOMDNS
sed --in-place "2 c\127.0.1.1	`hostname`.$DOM.com	`hostname`" /etc/hosts
sed --in-place "3 c\ $IPDNS	$NOMDNS.$DOM.com	$NOMDNS" /etc/hosts
sed --in-place "4 c\ $IP	`hostname`.$NISD	`hostname` \n" /etc/hosts

#resolv.conf
echo "Trabajando en el fichero resolv.conf"
echo "domain $DOM.com
search $DOM.com
nameserver $IPDNS" > /etc/resolv.conf
cd ; clear


#ypinit
echo "Se actualizara la base de datos de NIS, RECUERDE PRESIONAR Ctrl + D
Luego presione Y. \n" 

/usr/lib/yp/ypinit -m 2> /dev/null
/etc/init.d/nis restart

#agregar usuarios
echo "Desea agregar usuarios nuevos? (s/n)"
read OP
if [ $OP != "n" ]
then 
OPC="s"
while [ $OPC = "s" ]
do
echo "Ingrese el nombre del usuario"
read USER
adduser $USER
echo "Desea agregar otro usuario. (s/n)"
read OPC
done 
echo " Actualizando lista de usuarios"
cd /var/yp ; make
cd
else
cd /var/yp ; make
fi

echo "SERVICIO DE NIS COMPLETADO"
