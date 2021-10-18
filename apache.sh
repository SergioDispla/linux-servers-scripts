#!/bin/bash

clear
#comprobacion de paquetes
A=`dpkg --get-selections | grep apache2 | wc -l`

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

##FUNCION PARA EDITAR EL INDEX.HTML
index(){
sed --in-place "6 c\    <title> $PAG </title>" /var/www/html/$PAG/index.html
sed --in-place "193 c\          $PAG" /var/www/html/$PAG/index.html
sed --in-place "219 c\          BIENVENIDO A $PAG" /var/www/html/$PAG/index.html
}


if [ $A != 5 ]
then
red ##CONFIGURACION DE TARJETA EN DHCP
apt-get -y install apache2 apache2-doc apache2-utils
clear
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
echo "Listo"
else
echo "Paquetes apache ya instalados"
red2 ##CONFIGURACION DE TARJETA EN ESTATICA
echo "Configuracion de interface lista"
fi

#configuracion de dns
clear
echo "Configuracion de DNS"
echo "Digite el nombre del dominio DNS al que pertenece este equipo"
read DNS
echo "Digite la direccion IP de su servidor DNS"
read IPD

#resolv.conf
echo "Trabajando en resolv.conf"
echo "domain $DNS
search $DNS
nameserver $IPD" > /etc/resolv.conf
echo "Listo"
/etc/init.d/apache2 restart

echo "Desea agregar servidores virtuales? (s/n)"
read ASK

if [ $ASK != n ]
then
MK=0
S="s"
	while [ $S != n ]
	do
	echo "Digite el nombre de su pagina: (example.com)"
	read PAG
	mkdir /var/www/html/$PAG
	cp /var/www/html/index.html /var/www/html/$PAG/
	index ##FUNCION DE HTML 
	cd /etc/apache2/sites-available/
	echo "<VirtualHost *:80>
	ServerAdmin webmaster@$PAG
	ServerName $PAG
	ServerAlias www.$PAG
	DocumentRoot /var/www/html/$PAG
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost> " > $PAG.conf 

	cd
	chmod 755 /var/www/html/
	chmod -R 755 /var/www/html/$PAG/
	echo "Pagina agregada correctamente\n"
	a2ensite $PAG.conf
	clear

	##CONFIGURACION SSL 
	echo "Desea agregar configuracion SSL a su pagina?(s/n)"
	read SS
		if [ $SS != n ]
		then
		DN=`echo $PAG | cut -d"." -f1`
			if [ $MK = 0 ]
			then 
			mkdir /etc/apache2/ssl 
			echo "SSLStrictSNIVHostCheck on" > /etc/apache2/httpd.conf
			echo "Include /etc/apache2/httpd.conf" >> /etc/apache2/apache2.conf
			fi
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/$DN.key -out /etc/apache2/ssl/$DN.crt
			if [ $MK = 0 ]
			then
			a2enmod ssl 
			fi
		cd /etc/apache2/sites-available/
		cp default-ssl.conf $PAG.ssl.conf

		#fichero ssl.conf
		P="/etc/apache2/sites-available/$PAG.ssl.conf"
		sed --in-place "3 c\		ServerAdmin webmaster@$PAG" $P
		sed --in-place "4 c\		ServerName $PAG" $P
		sed --in-place "5 c\		DocumentRoot /var/www/html/$PAG" $P
		sed --in-place "6 c\		ServerAlias www.$PAG" $P
		sed --in-place "32 c\		SSLCertificateFile	/etc/apache2/ssl/$DN.crt" $P
		sed --in-place "33 c\		SSLCertificateKeyFile /etc/apache2/ssl/$DN.key" $P
		echo "\n Configuracion SSL Finalizada\n"
		a2ensite $PAG.ssl.conf
		MK=$(( $MK + 1 ))
		fi
	clear
	##CONFIGURACION DE AUTENTICACION
	echo "Desea agregar autenticacion a su sitio web?(s/n)"
	read SL
	AU="/etc/apache2/sites-available/$PAG.conf"
		if [ $SL != n ]
		then
		sed --in-place "7 a\  " / $AU
		sed --in-place "8 a\<Directory /var/www/html/$PAG/> " $AU
		sed --in-place "9 a\	AuthType Basic " $AU
		sed --in-place "10 a\	AuthName \"Autenticacion\"  " $AU
		sed --in-place "11 a\	AuthUserFile /etc/apache2/.$PAG " $AU
		sed --in-place "12 a\	require valid-user " $AU
		sed --in-place "13 a\</Directory> " $AU
		sed --in-place "14 a\  " $AU
		echo "Listo"

		clear
		echo "Se deben agregar usuarios para la autenticacion"
		C="s"
		AT=0
			while [ $C != n ]
			do
			echo "Digite el nombre de un nuevo usuario"
			read UA
				if [ $AT = 0 ]
				then
				htpasswd -c /etc/apache2/.$PAG $UA
				AT=$(( $AT + 1 ))
				else
				htpasswd /etc/apache2/.$PAG $UA
				fi
			echo "Desea agregar otro usuario?(s/n)"
			read C
			done
			echo "Usuarios agregados\n"
		echo "Configuracion de autenticacion finalizada"
		fi

	echo "Desea agregar otra pagina web?(s/n)\n"
	read S
	done
	clear
	echo "SERVICIO COMPLETADO\n"
	echo "NOTA: Por defecto se ha creado un fichero index.html, en cada directorio
	creado para su pagina web, si desea puede cambiarlo.\n"
	echo "Enter para finalizar"
	read NADA
fi
/etc/init.d/apache2 restart
service apache2 reload
echo "Servicio Apache Finalizado"
