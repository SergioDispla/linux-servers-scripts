#!/bin/bash 
clear

#Comprobacion de paquetes
A=`dpkg --get-selections | grep "apache" | wc -l`

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
netmask $MASK" > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

if [ $A != 5 ]
then
red ##CONFIGURACION DE TARJETA EN DHCP
apt-get update
apt-get -y install apache2 mysql-server-5.5 mysql-client-5.5 php5
apt-get -y install bacula bacula-common-mysql bacula-director-mysql bacula-sd-mysql bacula-server 
apt-get -y install libauthen-pam-perl libio-pty-perl apt-show-versions

cd
#Descarga de webmin
wget https://svwh.dl.sourceforge.net/project/webadmin/webmin/1.840/webmin_1.840_all.deb
#Instalacion de webmin
dpkg -i webmin_1.840_all.deb
clear
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
echo "Listo"
else
echo "Paquetes ya instalados"
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
echo "Configuracion de interface lista"
fi

clear

#Fichero /etc/bacula/bacula-dir.conf
echo "Digite la contraseña para el servicio de Bacula"
echo "NOTA: Debe ser la misma qeu digito durante la instalacion de MySQL"
read PASS
sed --in-place "22 c\  Password = \"$PASS\" " /etc/bacula/bacula-dir.conf
sed --in-place "24 c\  DirAddress = $IP " /etc/bacula/bacula-dir.conf
sed --in-place "158 c\  Address = $IP " /etc/bacula/bacula-dir.conf
sed --in-place "161 c\  Password = \"$PASS\" " /etc/bacula/bacula-dir.conf
sed --in-place "187 c\  Address = $IP " /etc/bacula/bacula-dir.conf
sed --in-place "189 c\  Password = \"$PASS\" " /etc/bacula/bacula-dir.conf
sed --in-place "312 c\  Password = \"$PASS\" " /etc/bacula/bacula-dir.conf

#Fichero /etc/bacula/bacula-sd.conf
sed --in-place "19 c\  SDAddress = $IP " /etc/bacula/bacula-sd.conf
sed --in-place "27 c\  Password = \"$PASS\" " /etc/bacula/bacula-sd.conf
sed --in-place "36 c\  Password = \"$PASS\" " /etc/bacula/bacula-sd.conf
sed --in-place "56 c\  Archive Device = /copias " /etc/bacula/bacula-sd.conf

mkdir /copias
chmod 777 /copias

#Fichero /etc/bacula/bacula-fd.conf
sed --in-place "15 c\  Password = \"$PASS\" " /etc/bacula/bacula-fd.conf
sed --in-place "24 c\  Password = \"$PASS\" " /etc/bacula/bacula-fd.conf
sed --in-place "37 c\  FDAddress = $IP " /etc/bacula/bacula-fd.conf

#Fichero /etc/bacula/bconsole.conf
sed --in-place "8 c\  address = $IP " /etc/bacula/bconsole.conf
sed --in-place "9 c\  Password = \"$PASS\" " /etc/bacula/bconsole.conf

#Reiniciar servicios
/etc/init.d/bacula-sd restart
/etc/init.d/bacula-director restart
/etc/init.d/bacula-fd restart

echo "Configuracion Finalizada"

