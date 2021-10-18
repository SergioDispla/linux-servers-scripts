#!/bind/bash
clear
A=`dpkg --get-selections | grep "slapd" | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
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
echo "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n
allow-hotplug eth0
iface eth0 inet static
address $IP
netmask $MASK " > /etc/network/interfaces
ifdown eth0
ifup eth0 2> /dev/null
echo "Configuracion de interface lista"
}

if [ $A != 1 ]
then
echo "Los paquetes slapd y ldap-utils no estan instalados"
red ##CONFIGURACION DE TARJETA EN DHCP NAT
sed --in-place "5 c\#NADA" /etc/apt/sources.list
apt-get -y install slapd ldap-utils nfs-kernel-server
fi
clear

red2 ##CONFIGURACION DE TARJETA EN ESTATICA
clear

echo "Ingrese el nombre de dominio DNS al que pertenece su equipo
Example: midominio.com"
read DOMDNS
echo "Digite la direccion IP de su servidor DNS"
read IPDNS
echo "Trabajando en el fichero resolv.conf"
echo "domain $DOMDNS 
search $DOMDNS
nameserver $IPDNS" > /etc/resolv.conf

#configurar el nfs exports
REC=`echo $IPDNS | cut -d"." -f1,2,3`
echo "/home	$REC.0/24(rw)" >> /etc/exports
/etc/init.d/nfs-kernel-server start

clear
echo "Se procedera a reconfigurar el paquete slapd para cambiar el motor de 
la base de datos (hdb)"
echo "Se le solitara su contraseña de Administrador LDAP.
NOTA: Despues el programa le volvera a solicitar ingresar la contraseña"
read -p "Digite a continuacion su LDAPASS y presione ENTER: " LDAPASS
dpkg-reconfigure slapd

#comprobacion
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn
echo "Compruebe que su   ^   motor de BDD ha cambiado a hdb"
echo "Es correcto?(s/n)"
read SF 
while [ $SF = n ]
do
dpkg-reconfigure slapd
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config dn
echo "Compruebe que su   ^   motor de BDD ha cambiado a hdb"
echo "Es correcto?(s/n)"
read SF
done
clear

echo "Se procedera a generar la clave y el hash para el usuario que
administrara la BD"
echo "#slappaswd: Digite una contraseña para generar su clave HASH"
echo "Digitela 3 veces"
read PASSLDAP
slappasswd > /root/passLDAP 

echo  "Su contraseña cifrada es: \n"
cat /root/passLDAP
echo " \n"

echo "Digite lo siguiente y al finalizar presione Ctrl + D
NOTA: Omitir las comillas\n"
echo "\"dn: olcDatabase={0}config,cn=config\"
\"add: olcRootPW\"
\"olcRootPW: {SSHA}----aqui--va--su--contraseña--cifrada--\" \n"

ldapmodify -Y EXTERNAL -H ldapi:///

CONFIGDNS=`echo $DOMDNS | cut -d. -f1`

echo "dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=$CONFIGDNS,dc=com
-
replace: olcRootDN
olcRootDN: cn=admin,dc=$CONFIGDNS,dc=com
-
replace: olcAccess
olcAccess: to attrs=userPassword by dn=\"cn=admin,dc=$CONFIGDNS,dc=com\" write by anonymous auth by self write by * none
olcAccess: to attrs=shadowLastChange by self write by * "read"
olcAccess: to dn.base=\"\" by * "read"
olcAccess: to * by dn=\"cn=admin,dc=$CONFIGDNS,dc=com\" write by * "read"  " > /root/config.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/config.ldif
echo "Enter para continuar"
read NADA 

echo "Se revisara nuevamente el funcionamiento"
echo "Digite su contraseña: $PASSLDAP"
ldapsearch -xLLL -b cn=config -D cn=admin,cn=config -W olcDatabase={1}hdb

MAY=`echo $CONFIGDNS | tr [:lower:] [:upper:]`
echo "dn: dc=$CONFIGDNS,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: $MAY
dc: $MAY
description: Servidor LDAP de $MAY.com

dn: ou=people,dc=$CONFIGDNS,dc=com
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=$CONFIGDNS,dc=com
objectClass: organizationalUnit
ou: groups " > /root/base.ldif

echo "Se agregara el fichero, digite su contraseña: $LDAPASS"

ldapadd -x -D cn=admin,dc=$CONFIGDNS,dc=com -W -f /root/base.ldif

echo "Obtuvo algun tipo de error?(s/n)"
read ASK

if [ $ASK = s ]
then
echo "dn: ou=people,dc=$CONFIGDNS,dc=com
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=$CONFIGDNS,dc=com
objectClass: organizationalUnit
ou: groups " > /root/base.ldif


echo "Se agregara el fichero, digite su contraseña: $LDAPASS"
ldapadd -x -D cn=admin,dc=$CONFIGDNS,dc=com -W -f /root/base.ldif
fi

echo "Se deben crear usuarios adicionales para el servicio"
P="s"
while [ $P != n ]
do 
echo "Digite el nombre de un usuario"
read USERNUEV
adduser $USERNUEV
echo "Desea agregar otro usuario?(s/n)"
read P
done 
echo "Usuarios agregados"


SUFFIX="dc=$CONFIGDNS,dc=com"
LDIF="/root/ldapuser.ldif"

echo -n > $LDIF
for line in `grep "x:[1-9][0-9][0-9][0-9]:" /etc/passwd | sed -e "s/ /%/g"`
do
    UID1=`echo $line | cut -d: -f1`
    NAME=`echo $line | cut -d: -f5 | cut -d, -f1`
    if [ ! "$NAME" ]
    then
        NAME=$UID1
    else
        NAME=`echo $NAME | sed -e "s/%/ /g"`
    fi
    SN=`echo $NAME | awk '{print $2}'`
    if [ ! "$SN" ]
    then
        SN=$NAME
    fi
    GIVEN=`echo $NAME | awk '{print $1}'`
    UID2=`echo $line | cut -d: -f3`
    GID=`echo $line | cut -d: -f4`
    PASS=`grep $UID1: /etc/shadow | cut -d: -f2`
    SHELL=`echo $line | cut -d: -f7`
    HOME=`echo $line | cut -d: -f6`
    EXPIRE=`passwd -S $UID1 | awk '{print $7}'`
    FLAG=`grep $UID1: /etc/shadow | cut -d: -f9`
    if [ ! "$FLAG" ]
    then
        FLAG="0"
    fi
    WARN=`passwd -S $UID1 | awk '{print $6}'`
    MIN=`passwd -S $UID1 | awk '{print $4}'`
    MAX=`passwd -S $UID1 | awk '{print $5}'`
    LAST=`grep $UID1: /etc/shadow | cut -d: -f3`

    echo "dn: uid=$UID1,ou=people,$SUFFIX" >> $LDIF
    echo "objectClass: inetOrgPerson" >> $LDIF
    echo "objectClass: posixAccount" >> $LDIF
    echo "objectClass: shadowAccount" >> $LDIF
    echo "uid: $UID1" >> $LDIF
    echo "sn: $SN" >> $LDIF
    echo "givenName: $GIVEN" >> $LDIF
    echo "cn: $NAME" >> $LDIF
    echo "displayName: $NAME" >> $LDIF
    echo "uidNumber: $UID2" >> $LDIF
    echo "gidNumber: $GID" >> $LDIF
    echo "userPassword: {crypt}$PASS" >> $LDIF
    echo "gecos: $NAME" >> $LDIF
    echo "loginShell: $SHELL" >> $LDIF
    echo "homeDirectory: $HOME" >> $LDIF
    echo "shadowExpire: $EXPIRE" >> $LDIF
    echo "shadowFlag: $FLAG" >> $LDIF
    echo "shadowWarning: $WARN" >> $LDIF
    echo "shadowMin: $MIN" >> $LDIF
    echo "shadowMax: $MAX" >> $LDIF
    echo "shadowLastChange: $LAST" >> $LDIF
    echo >> $LDIF
done


cat /root/ldapuser.ldif

echo "Se agregara la DB al servicio de directorio LDAP, 
digite su contraseña: $LDAPASS"
ldapadd -x -D cn=admin,dc=$CONFIGDNS,dc=com -W -f /root/ldapuser.ldif


SUFFIXE="dc=$CONFIGDNS,dc=com"
LDID="/root/ldapgroup.ldif"

echo -n > $LDID
for lines in `grep "x:[1-9][0-9][0-9][0-9]:" /etc/group`
do
CM=`echo $lines | cut -d: -f1`
GIB=`echo $lines | cut -d: -f3`
echo "dn: cn=$CM,ou=groups,$SUFFIXE" >> $LDID
echo "objectClass: posixGroup" >> $LDID
echo "cn: $CM" >> $LDID
echo "gidNumber: $GIB" >> $LDID
userss=`echo $lines | cut -d: -f4 | sed "s/ / /g"`
for userd in ${userss} ; do
echo "memberUid: ${userd}" >> $LDID
done
echo >> $LDID
done

cat /root/ldapgroup.ldif

echo "Se agregaran los grupos al directorio de servicio"
echo "Digite su contraseña: $LDAPASS"
ldapadd -x -D cn=admin,dc=$CONFIGDNS,dc=com -W -f /root/ldapgroup.ldif
echo "Se realizara un test de su servicio LDAP. Enter para continuar"
read NADA
slaptest 
sleep 5; echo "Reiniciando servicio"
read NADA
/etc/init.d/nfs-kernel-server restart
echo "Configuracion servicio LDAP finalizado"

