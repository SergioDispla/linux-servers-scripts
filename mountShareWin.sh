#!/bin/bash
clear
OP="s"
while [ $OP != "n" ]
do
echo "Digite la direccion IP del servidor/cliente con la carpeta compartida"
read IP
echo "Digite el nombre de la carpeta compartida"
read COM
echo "Digite el nombre del usuario dueño de la carpeta compartida"
read US
echo "Digite la contraseña del usuario"
read PAS
echo "Indique la ruta absoluta donde desea montar la carpeta"
read RUT

echo "
//$IP/$COM	$RUT	cifs	username=$US,password=$PAS,user,owner,auto	0	0" >> /etc/fstab
echo "Listo"
echo "Desea montar otra carpeta?(s/n)"
read OP
done 
echo "Se necesita reiniciar el equipo para aplicar los cambios"
echo "Enter para continuar"
reboot

