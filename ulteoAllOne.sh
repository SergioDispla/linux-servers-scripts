#!/bin/bash

clear
#comprobacion de paquetes
A=`dpkg --get-selections | grep "mysql" | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "
auto lo
iface lo inet loopback\n
auto eth0
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
echo "
auto lo
iface lo inet loopback\n
auto eth0
iface eth0 inet static
address $IP
netmask $MASK " > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

if [ $A != 3 ]
then 
echo "Los paquetes necesarios no se encuentran instalados"
red ##FUNCION DHCP
wget -O - http://archive.ulteo.com/ovd/4.0.3/ubuntu/dists/trusty/ulteo_lists > /etc/apt/sources.list.d/ulteo_ovd.list
wget -O - http://archive.ulteo.com/ovd/4.0.3/ubuntu/dists/trusty/keyring | apt-key add -
apt-get update
apt-get -y install mysql-server
clear
echo "Se creara la base de datos OVD, digite su contraseña de root para mysql"
mysql -u root -p -e 'create database ovd'
apt-get -y install ulteo-ovd-session-manager
apt-get -y install ulteo-ovd-administration-console
apt-get -y install ulteo-ovd-web-client
apt-get -y install ulteo-ovd-slaveserver-role-aps ulteo-ovd-slaveserver-role-fs
clear
else
clear
echo "Paquetes necesarios ya instalados"
fi

echo "Servicio Finalizado"
sleep 3
clear
echo "Configuracion App Server"
sleep 3
B="s"
while [ $B != "n" ]
do
	clear
	echo "Seleccione alguna de las siguientes aplicaciones para descargar\n"
	echo "1) Filezilla (Servicio FTP) $AA"
	echo "2) Mozilla Firefox (Navegador Web) $BB"
	echo "3) GPARTED (Particionador de Discos) $CC"
	echo "4) VLC (Reproductor Multimedia) $DD"
	echo "5) Pidgin (Mensajeria Instantanea) $EE"
	echo "6) LibreOffice (Editor Documentos) $FF" 
	echo "7) GEDIT (Bloc de Notas) $GG"
	echo "8) Okular (Visor de documentos) $HH"
	read MENU

		case $MENU in
		1) 
		apt-get -y install filezilla
		AA="Instalado"
		;;
		2)
		apt-get -y install firefox
		BB="Instalado"
		;;
		3)
		apt-get -y install gparted
		CC="Instalado"
		;;
		4)
		apt-get -y install vlc
		DD="Instalado"
		;;
		5)
		apt-get -y install pidgin
		EE="Instalado"
		;;
		6)
		apt-get -y install libreoffice
		FF="Instalado"
		;;
		7)
		apt-get -y install gedit
		GG="Instalado"
		;;
		8)
		apt-get -y install okular
		HH="Instalado"
		;;
		esac
	clear
	echo "Desea agregar otra aplicacion?(s/n)"
	read B
done
red2 ##ESTATICA
echo " "
echo "Servicio Finalizado \n"
echo "Su servidor se reiniciara, Enter para continuar"
read NADA
echo "REINICIO"
sleep 1; echo "5"
sleep 1; echo "4"
sleep 1; echo "3"
sleep 1; echo "2"
sleep 1; echo "1"
init 6
