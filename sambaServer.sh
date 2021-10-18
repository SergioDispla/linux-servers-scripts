#!/bin/bash
clear
A=`dpkg --get-selections | grep samba | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener el adaptador de red en NAT en su VirtualBox
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
red ##CONFIGURACION DE TARJETA EN DHCP 
apt-get -y install samba
clear
echo "Ficheros descargados"
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
else
echo "Ficheros de SAMBA ya estan instalados"
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
fi

#smb.conf
echo "Trabajando en smb.conf"
sed --in-place "25 c\unix charset=UTF-8"
echo "Ingrese el nombre de WORKGROUP (example: MIDOMINIO )"
read GR
sed --in-place "30 c\ workgroup= $GR
echo "Ingrese su direccion IP de red y la mascara: example=127.0.0.0/8"
read IP
sed --in-place "48 c\ interfaces = 127.0.0.1/8 $IP eth0
clear

X="s"
while [ $X = "s" ]
do
clear
echo "Indique el tipo de permisos que tendra el recurso compartido"
echo "1) Abierto(sin credenciales)"
echo "2) Restrigindo (con credenciales) \n"
read OP
case $OP in
1)
clear
echo "Ingrese el nombre del recurso compartido.
Nombre con el que se vera nuestro recurso"
read COM
echo "Ingrese la ruta adsoluta del recurso a compartir"
read RUT
echo " 
[$COM] \n
path = $RUT
browseable = yes
writable = yes
guest ok = yes
guest only = yes
create mode = 0777
directory mode = 0777 
share mode = yes" >> /etc/samba/smb.conf

echo "Creando directorio $RUT"
mkdir $RUT
chmod 777 $RUT
echo "Reiniciando servicio SAMBA"
/etc/init.d/samba restart
echo "Verifique el directorio compartido en su equipo Windows"
;;
2)
clear
echo "Ingrese el nombre del recurso compartido.
Nombre con el que se vera nuestro recurso"
read COM
echo "Ingrese la ruta adsoluta del recurso a compartir"
read RUT
echo "Ingrese el nombre de grupo por el cual se validaran los usuarios"
read VAL
echo "
[$COM] \n
path = $RUT
browseable = yes
writable = yes
create mode = 0770
directory mode = 0770 
guest ok = no 
valid users = @$VAL" >> /etc/samba/smb.conf

echo "Agregando grupo $VAL"
groupadd $VAL
echo "Creando directorio $RUT"
mkdir $RUT
chgrp $VAL $RUT
chmod 2770 $RUT
echo " "
echo "Ingrese el nombre de un usuario que formara parte 
del grupo $VAL y tendra acceso al directorio compartido $RUT 
por ultimo defina la contraseña 2 veces"
S="s"
while [ $S = "s" ]
do
echo " "
read US
adduser $US
echo "Se le pedira nuevamente una contraseña para el servicio de SAMBA
Su contraseña puede ser la misma utilizada en su cuenta local"
smbpasswd -a $US
usermod $US -a -G $VAL
echo "Desea agregar otro usuario?(s/n)"
read S
done
echo "Usuarios agregados"
echo "Reiniciando servicio SAMBA"
/etc/init.d/samba restart
;;
esac
echo " "
echo "Desea compartir otro recurso? (s/n)"
read X
done
echo "Fichero de configuracion listo"
