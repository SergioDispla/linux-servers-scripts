#!/bin/bash 

S="s"
while [ $S != "n" ] 
do
echo "Que desea agregar?"
echo "1) Servidor Web"
echo "2) Servidor de correo"
echo "3) Servidor FTP"
echo "4) Servidor Proxy"
echo "5) Servidor NIS/SAMBA/ProFTPD"
echo "6) Salir"
read K
case $K in
1)
#Saca el nombre del dominio DNS
DOM=`cat /etc/resolv.conf | grep domain | cut -d" " -f2`

#Saca la direccion IP del servidor DNS
IPDA=`cat /etc/resolv.conf | grep nameserver | cut -d" " -f2`

echo "Digite el nombre de equipo de su servidor Web"
read NOMB
echo "Digite la direccion IP de su servidor Web"
read IP
#Saca el ultimo digito de la IP del servidor Web
IPDB=`echo $IP | cut -d. -f4`

CONT=0
S="s"
while [ $S != n ]
do
echo "Digite el nombre de su pagina(example.com)"
read NOM
cd /etc/bind/
echo "\$ORIGIN	.
\$TTL	86400
$NOM	IN	SOA	`hostname`.$NOM. root.$NOM. (
			2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL


		NS	`hostname`.$NOM.
\$ORIGIN		$NOM.
`hostname`		A	$IPDA
www		A	$IP " > db.$NOM

	if [ $CONT = 0 ]
	then
	echo "$IPDB		PTR	$NOMB.$DOM." >> db.$IPDA
	echo "$NOMB 		A	$IP" >> db.$DOM 
	CONT=$(( $CONT + 1 ))
	fi 

echo "$IPDB		PTR	www.$NOM." >> db.$IPDA

echo "
zone \"$NOM\" {
	type master;
	file \"db.$NOM\";
	}; " >> named.conf.local 

echo "Desea agregar otra pagina al registro DNS?(s/n)"
read S
done
echo "Configuracion Finalizada"
/etc/init.d/bind9 restart
;;
2)
echo "Ingrese la direccion IP de su servidor"
read IP
echo "Ingrese el nombre de maquina de su servidor"
read NOM
echo "Ingrese un nombre alias para su servidor de correo"
read ALI

DOM=`cat /etc/resolv.conf | grep domain | cut -d" " -f2`
IPDOM=`cat /etc/resolv.conf | grep nameserver | cut -d" " -f2`
IPB=`echo $IP | cut -d. -f4`
IPC=`echo $IP | cut -d. -f1,2,3`

echo "$NOM		A	$IP" >> /etc/bind/db.$DOM
echo "$ALI		CNAME	$NOM.$DOM." >> /etc/bind/db.$DOM
echo "www		A	$IP" >> /etc/bind/db.$DOM
echo "$IPB		PTR		$NOM.$DOM." >> /etc/bind/db.$IPC.1
echo "$IPB		PTR		$ALI.$DOM." >> /etc/bind/db.$IPC.1
sed --in-place "4 c\ $IP		$NOM.$DOM	$NOM" /etc/hosts
/etc/init.d/bind9 restart
echo "Listo, se agrego su servidor a los ficheros BIND"
;;
3) echo "En pruebas"
;;
4)
echo "Ingrese la direccion IP de su servidor Proxy"
read IP
echo "Ingrese el nombre de maquina de su servidor Proxy"
read NOM

DOM=`cat /etc/resolv.conf | grep domain | cut -d" " -f2`
IPDOM=`cat /etc/resolv.conf | grep nameserver | cut -d" " -f2`
IPB=`echo $IP | cut -d. -f4`
IPC=`echo $IP | cut -d. -f1,2,3`

echo "$NOM		A	$IP" >> /etc/bind/db.$DOM
echo "$IPB		PTR		$NOM.$DOM." >> /etc/bind/db.$IPC.1

/etc/init.d/bind9 restart


echo "Listo, se agrego su servidor a los ficheros BIND"
;;

5)
echo "Ingrese la direccion IP de su servidor"
read IP
echo "Ingrese el nombre de maquina de su servidor"
read NOM

DOM=`cat /etc/resolv.conf | grep domain | cut -d" " -f2`
IPDOM=`cat /etc/resolv.conf | grep nameserver | cut -d" " -f2`
IPB=`echo $IP | cut -d. -f4`
IPC=`echo $IP | cut -d. -f1,2,3`

echo "$NOM		A	$IP" >> /etc/bind/db.$DOM
echo "$IPB		PTR		$NOM.$DOM." >> /etc/bind/db.$IPC.1

/etc/init.d/bind9 restart


echo "Listo, se agrego su servidor a los ficheros BIND"
;;
6) exit
;;
esac
echo " \n"
echo "Desea agregar otro servidor?(s/n)"
read S
done 
echo "Finalizado"


