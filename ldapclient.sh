#!/bin/bash
clear

A=`dpkg --get-selections | grep "libnss-ldap" | wc -l`
B=`dpkg --get-selections | grep "ldap-utils" | wc -l`

##FUNCION PARA LA CONFIGURACION CON DHCP
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
echo "Configuracion de interfaces lista"
}

red2(){
echo "Por favor cambie el adaptador de red a Red Interna en su VirtualBox
Presione ENTER para continuar"
read NADA
echo "\n
Seleccione como desea configurar su cliente LDAP
1) IP por DHCP (Requiere Servidor DHCP)
2) IP ESTATICA (No requiere Servidor DHCP) "
read ORED
if [ $ORED = 1 ]
then
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet dhcp" > /etc/network/interfaces
ifdown eth0
ifup eth0
echo "Interface Configurada"
else
echo "Digite su direccion IP"
read IP
echo "Digite su mascara de red"
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
echo "Configuracion de interface lista"
clear
echo "Por favor digite el nombre de su dominio LDAP (example: midominio.com)"
read DOMLDP
echo "Digite la direccion IP de su servidor LDAP"
read IPLDP
echo "domain $DOMLDP
search $DOMLDP
nameserver $IPLDP " > /etc/resolv.conf
fi
}

if [ $A != 1 ]
then 
echo "Los paquetes ldap-utils, libnss-ldap, libpam-ldap no estan instalados"
red ##CONFIGURACION DE TARJETA EN DHCP 
apt-get update
	if [ $B != 1 ]
	then
	apt-get -y install libnss-ldap ldap-utils libpam-ldap
	echo "Listo"
	else
	apt-get -y install libnss-ldap libpam-ldap
	echo "Listo"
	fi
clear
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
clear

else

	if [ $B != 1 ]
	then
	echo "Los paquetes ldap-utils no estan instalados"
	red ##CONFIGURACION DE TARJETA EN DHCP
	clear
	apt-get -y install ldap-utils libpam-ldap
	echo "Listo"
	fi
clear
red2 #CONFIGURACION DE TARJETA DHCP/ESTATICA
#reconfigurar ldap
dpkg-reconfigure libnss-ldap
fi

##nsswitch.conf
sed --in-place "7 c\passwd:		compat dns ldap" /etc/nsswitch.conf
sed --in-place "8 c\group:		compat dns ldap" /etc/nsswitch.conf
sed --in-place "9 c\shadow:		compat dns ldap" /etc/nsswitch.conf
sed --in-place "20 c\netgroup:		ldap" /etc/nsswitch.conf

##common-password
sed --in-place "26 c\password 	[sucecess=1 user_unknown=ignore default=die] pam_ldap.so try_first_pass" /etc/pam.d/common-password

clear
echo "Elija el tipo de almacenamiento que tendran los usuarios\n"
echo "1) Local: En el directorio /home se gererara un directorio personal
para cada usuario, al iniciar sesion por primera vez\n"
echo "2) Remota: Se utiliza la integracion con NFS, se monta el servicio
de directorios por NFS, de modo que cada usuario tendra su perfil en un
servidor central y accesible desde cualquier equipo\n"
read CP
clear
case $CP in
1) echo "Almacenamiento Local"
echo "session optional pam_mkhomedir.so skel=/etc/skel umask 077" >> /etc/pam.d/common-session
;;
2) echo "Almacenamiento Remoto"
echo "Digite la direccion IP de su servidor LDAP"
read IPL
showmount -e $IPL 
echo "ENTER para continuar"
read NADA
echo "$IPL:/home	/home	nfs	rw	0	0" >> /etc/fstab
;;
esac

clear
echo "Por favor digite el nombre de su dominio LDAP (example: midominio.com)"
read DC
DOML=`echo $DC | cut -d"." -f1`
DOMJ=`echo $DC | cut -d"." -f2`

##AQUI REALIZA LA CONSULTA AL SERVER LDAP

clear
echo "Se agregara su dominio LDAP al fichero ldap.conf"
sed --in-place "8 c\BASE		dc=$DOML,dc=$DOMJ" /etc/ldap/ldap.conf
sed --in-place "9 c\URI		ldap://$IPL" /etc/ldap/ldap.conf

echo "Configuracion de cliente LDAP finalizada"

echo " \n
SU ESQUIPO SE REINICIARA, RECUERDE INGRESAR CON UN USUARIO DEL SERVICIO LDAP
ENTER PARA CONTINUAR CON EL REINICIO \n"
read NADA

echo "REINICIANDO EN"
sleep 1; echo "5"
sleep 1; echo "4"
sleep 1; echo "3"
sleep 1; echo "2"
sleep 1; echo "1"
init 6

