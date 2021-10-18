#!/bin/bash

clear

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
echo "Ingrese su nombre de dominio(minusculas: example.com)"
read DOM
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

A=`dpkg --get-selections | grep "krb5-config" | wc -l `

if [ $A != 1 ]
then
echo "Se descargaran los paquetes necesarios"
red ##RED EN DHCP
#apt-get update && apt-get upgrade
apt-get -y install samba
apt-get -y install smbclient
apt-get -y install krb5-config
apt-get -y install krb5-user
apt-get -y install winbind
apt-get -y install libnss-winbind
fi
clear
red2 ##RED EN ESTATICA

#Inicio de la configuracion
echo "order bind,hosts
multi on" > /etc/host.conf

#krb5.conf
MDOM=`echo $DOM | tr [:lower:] [:upper:]`
#DIGITE EL DOM EN MAY
echo "[libdefaults]
	default_realm = $MDOM
	dns_lookup_realm = false
	dns_lookup_kdc = true" > /etc/krb5.conf

#nsswitch.conf
sed --in-place "7 c\passwd:		compat dns winbind" /etc/nsswitch.conf
sed --in-place "8 c\group:		compat dns winbind" /etc/nsswitch.conf
sed --in-place "9 c\shadow:		compat dns winbind" /etc/nsswitch.conf
sed --in-place "20 c\netgroup:	winbind" /etc/nsswitch.conf

#renombrar smb.conf
mv /etc/samba/smb.conf /etc/samba/smb.confbk

#hosts
sed --in-place "2 c\127.0.1.1		`hostname`.$DOM	`hostname`" /etc/hosts
sed --in-place "3 c\ $IP		`hostname`.$DOM	`hostname`" /etc/hosts

clear
#comando de activacion
echo "Digite su contraseña de administrador aqui
NOTA: La contraseña debe tener minimo 8 carateres, incluyendo entre numeros
letras y simbolos especiales"
read PASMB
echo $PASMB > /etc/samba/sambapasswd
clear
echo "Se le volvera a solicitar el ingreso de su contraseña de administrador
luego de finalizar el comando"
echo "Presione ENTER aqui"
samba-tool domain provision --interactive --use-rfc2307 --option="interfaces=lo eth0" --option="bind interfaces only=yes"
echo "
ENTER para continuar"
read NADA
#inicio y status del servicio
service samba-ad-dc start
echo "Se revisara el estado del servicio de samba. Presione ENTER para continuar"
read NADA
service samba-ad-dc status 
echo "\nENTER para continuar"
read NADA
service winbind status
echo "\nENTER para continuar"
read NADA

#resolv.conf
echo "domain $DOM
search $DOM
nameserver $IP" > /etc/resolv.conf

echo "CONFIGURACION FINALIZADA"

echo '#!/bin/bash
clear
echo "Se continuara con la comprobacion del servicio SAMBA.
ENTER para continuar"
read NADA
DOM=`cat /etc/resolv.conf | grep "domain" | cut -d" " -f2`
host -t SRV _ldap._tcp.$DOM
echo "ENTER para continuar"
read NADA
host -t SRV _kerberos._udp.$DOM
echo "ENTER para continuar"
read NADA
host -t A `hostname`.$DOM
echo "ENTER para continuar"
read NADA
MAYD=`echo $DOM | tr [:lower:] [:upper:]`
SMBPAS=`cat /etc/samba/sambapasswd`
echo "A continuacion digite su contraseña de Administrador: $SMBPAS" 
kinit Administrator@$MAYD
echo "ENTER para continuar"
read NADA
klist
echo "ENTER para continuar"
read NADA
clear
echo "Se necesitan agregar usuarios al directorio SAMBA"
S="s"
while [ $S != n ]
do
clear
echo "Digite el nombre de un nuevo usuario"
echo "NOTA: la contraseña debe ser minimo de 8 caracteres(numeros,letras)"
read USAM
samba-tool user add $USAM
echo "
Desea agregar otro usuario?(s/n)"
read S
done
echo "Servicio SAMBA completado"
echo "Puede agregar un cliente windows a su dominio samba, e ingresar 
con alguno de los usuarios creados anteriormente"
' > /etc/init.d/sambaScript.sh

chmod 777 /etc/init.d/sambaScript.sh

clear
echo "El equipo se reiniciara, despues del reinicio por favor ejecutar:
/etc/init.d/sambaScript.sh"
echo "ENTER para reiniciar"
read NADA
reboot


