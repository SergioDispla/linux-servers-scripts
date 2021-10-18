#!/bin/bash
echo "Seleccione la accion a realizar"
echo "1) Montar Dispositivo"
echo "2) Desmontar Dispositivo"

read OT
case $OT in 
#####OPCION 1 MONTAR##################################################
1) 
test -e /dev/sdb ; A=`echo $?`
if [ $A = 1 ]
then
echo "Dispositivo no conectado, Por favor conecte una unidad de almacenamiento"
else 
echo "Tipo de dispositivo"
echo "1) FAT32"
echo "2) NTFS"
echo "3) EXFAT"
try(){ #FUNCION PARA MONTAR LA UNIDAD EN CASO DE QUE SEA DIFERENTE EL DISPOSITIVO
DIS=`ls /dev/sdb* | wc -w`
if [ $DIS = 2 ]
then
mount -t $FOR /dev/sdb1 /mnt
else
mount -t $FOR /dev/sdb /mnt
fi
}
inter(){ #FUNCION PARA CAMBIAR EL FICHERO INTERFACES Y TENER INTERNET
echo "Esta operacion requiere de internet, por favor asegurese
de tener conexion a Internet con alguno de los adaptadores"
echo "Presione ENTER para continuar"
read NADA
cp /etc/network/interfaces /tmp 
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp\n" > /etc/network/interfaces
ifdown eth0
ifup eth0
sed --in-place "5 c\#NADA"	
clear
}
ifeth(){ #FUNCION PARA LEVANTAR LA TARJETA DE RED LUEGO DE SER CAMBIADA
ifdown eth0
ifup eth0
}
	read OP
	case $OP in 
	1)
	FOR="vfat"
	try
	echo "Dispositivo montado en el directorio /mnt"
	;;
	2)
	A=`dpkg --get-selections | grep "ntfs-3g" | wc -l`
	if [ $A != 1 ]
	then
	inter
	apt-get -y install libfuse2 ntfs-3g
	clear
	cat /tmp/interfaces > /etc/network/interfaces
	ifeth
	fi
	FOR="ntfs-3g"
	try
	echo "Dispositivo montado en el directorio /mnt"
	;;
	3)
	A=`dpkg --get-selections | grep "exfat-*" | wc -l`
	if [ $A != 2 ]
	then
	inter
	apt-get -y install exfat-fuse
	clear
	cat /tmp/interfaces > /etc/network/interfaces
	ifeth
	fi
	FOR="exfat"
	try
	echo "Dispositivo montado en el directorio /mnt"
	;;
	esac
fi
;;
###################################################################

##OPCION 2 DESMONTAR####
2) 
umount /mnt/
echo "Dispositivo Desmontado"
;;
esac
########################
