#!/bin/bash
clear
cd

red(){
echo "Por favor asegures de tener su adaptador de red en NAT en su VirtualBox"
echo "Enter para continuar"
read NADA
sed --in-place "10 c\iface eth0 inet dhcp" /etc/network/interfaces
sed --in-place "10 a\#NADA " /etc/network/interfaces
sed --in-place "10 a\#NADA " /etc/network/interfaces
ifdown eth0
ifup eth0
echo "Configuracion de interface lista"
}

red2(){
clear
echo "Por favor cambie su adaptador de red a Red Interna"
echo "Enter para continuar"
read NADA
echo "Digite su direccion IP"
read IP
echo "Digite su mascara de red"
read MASK
sed --in-place "10 c\iface eth0 inet static" /etc/network/interfaces
sed --in-place "11 c\address $IP " /etc/network/interfaces
sed --in-place "12 c\netmask $MASK " /etc/network/interfaces
ifdown eth0 
ifup eth0
echo "Configuracion de interface lista"
}

pr(){
echo " "
echo "Enter para continuar"
read NADA
}

red
clear
echo "Descarga de paquetes"
apt-get update
apt-get -y install apache2 php5 nbtscan php5-mysql php5-gd libnet1 libnet1-dev libpcre3
apt-get -y install libpcre3-dev autoconf libtool gcc-4.4 g++ automake gcc make flex bison
apt-get -y install nmap ruby ruby-pcaprub mysql-server libmysqlclient-dev

clear
echo "Comprobacion de paquetes"
sleep 5
apt-get -y install apache2 php5 nbtscan php5-mysql php5-gd libnet1 libnet1-dev libpcre3
pr
apt-get -y install libpcre3-dev autoconf libtool gcc-4.4 g++ automake gcc make flex bison
pr
apt-get -y install nmap ruby ruby-pcaprub mysql-server libmysqlclient-dev
pr

clear
cd
echo "Descarga libcap-1.1.1"
wget http://www.tcpdump.org/release/libpcap-1.1.1.tar.gz
tar -zxvf libpcap-1.1.1.tar.gz
cd libpcap-1.1.1/
./configure --prefix=/usr --enable-shared
make 
make install

clear
cd
echo "Descarga libdnet-1.12"
wget ftp://ftp.linux.kiev.ua/macports/distfiles/libdnet/libdnet-1.12.tgz
tar -zxvf libdnet-1.12.tgz
cd libdnet-1.12/
./configure --prefix=/usr --enable-shared
make 
make install

clear
cd
echo "Descarga snort-daq"
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
tar -zxvf daq-2.0.6.tar.gz
cd daq-2.0.6/
./configure
make 
make install 
ldconfig

####Limpieza
rm -r lib*
rm -r daq*
####

clear
cd
echo "Descarga de paquetes adicionales"
apt-get -y install libgnutls-dev python lua50 libprelude-dev libpreludedb-dev python-preludedb
apt-get -y install python-prelude libprelude-perl libpreludedb-perl prelude-correlator
apt-get -y install prelude-manager
clear

echo "Comprobacion de paquetes"
sleep 5
apt-get -y install libgnutls-dev python lua50 libprelude-dev libpreludedb-dev python-preludedb
pr
apt-get -y install python-prelude libprelude-perl libpreludedb-perl prelude-correlator
pr
apt-get -y install prelude-manager
pr

clear
sed --in-place "3 c\RUN=yes " /etc/default/prelude-manager
/usr/sbin/prelude-manager -d -P /var/run/prelude-manager.pid
pr
apt-get -y install prelude-lml
/usr/bin/prelude-lml -d -q -P /var/run/prelude-lml.pid
/usr/bin/prelude-lml -d -q -P /var/run/prelude-lml.pid

###Resgistrar sensores
clear
echo "Por favor abrir otra terminal y digitar el siguiente comando \n"
echo "prelude-admin registration-server prelude-manager \n"
echo "Luego de realizar lo anterior, digite la clave generada de la otra terminal aqui abajo \n"

prelude-admin register "prelude-lml" "idmef:w" 127.0.0.1 --uid 0 --gid 0
echo "Listo, sensor registrado"
sleep 5

clear
echo "Se comprobara la lista de sensores"
prelude-admin list -l 
pr

###Instalacion de interfaz grafica
clear
cd
apt-get -y install prewikka
chmod 755 /etc/prewikka/prewikka.conf
apt-get -y install apache2-utils libapache2-mod-python

echo '<VirtualHost *:80>
	ServerAdmin admin@domain.com
	<Location />
		SetHandler mod_python
		PythonHandler prewikka.ModPythonHandler
		PythonOption PrewikkaConfig /etc/prewikka/prewikka.conf
	</Location>
	
	<Location /prewikka>
		SetHandler None
	</Location>

	Alias /prewikka /usr/share/prewikka/htdocs
	Alias /htdocs /usr/share/prewikka/htdocs
</VirtualHost>' > /etc/apache2/sites-available/prewikka.conf

cd
clear
echo "Digite su direccion IP"
read IP
sed --in-place "2 c\127.0.1.1	`hostname`.domain.com	`hostname` " /etc/hosts
sed --in-place "3 c\ $IP	`hostname`.domain.com	`hostname` " /etc/hosts

a2dissite 000-default.conf
a2ensite prewikka.conf
service apache2 restart
pr

clear
sed --in-place "68 c\user: root" /etc/prewikka/prewikka.conf
echo "Digite su contraseña de root de mysql"
read PASS
sed --in-place "69 c\pass: $PASS" /etc/prewikka/prewikka.conf

prewikka-httpd &


##Instalacion de suricata
echo "Instalacion de suricata"
cd
apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf
apt-get -y install automake libtool libpcap-dev libnet1-dev libyaml-0-2 zlib1g
apt-get -y install libcap-ng-dev libcap-ng0 libyaml-dev pkg-config

clear
echo "Comprobacion de paquetes"
sleep 5
apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf
pr
apt-get -y install automake libtool libpcap-dev libnet1-dev libyaml-0-2 zlib1g
pr
apt-get -y install libcap-ng-dev libcap-ng0 libyaml-dev pkg-config
pr

clear
echo "Descarga paquete suricata"
wget http://www.openinfosecfoundation.org/download/suricata-current.tar.gz
tar -zxvf suricata-current.tar.gz
cd suricata-*
./configure --prefix=/usr --enable-shared --enable-prelude
mkdir -p /var/log/suricata/
make
make install 
mkdir /etc/suricata/
mkdir /etc/suricata/rules
cp suricata.yaml /etc/suricata/
cp classification.config /etc/suricata/
cp reference.config /etc/suricata/
cp threshold.config /etc/suricata/
cd rules/
cp * /etc/suricata/rules/

cd
clear
red2
echo "Digite su IP de red (example: 192.168.1.0/24) "
read IPRD
sed --in-place "391 c\      enabled: yes " /etc/suricata/suricata.yaml
sed --in-place "15 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "16 c\    HOME_NET: \"[$IPRD]\" " /etc/suricata/suricata.yaml
sed --in-place "52 c\default-rule-path: /etc/suricata/rules " /etc/suricata/suricata.yaml
sed --in-place "54 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "56 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "57 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "58 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "59 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "61 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "62 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "63 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "64 c\##NADA " /etc/suricata/suricata.yaml
clear
echo "Hecho[1]!"
sed --in-place "65 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "66 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "67 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "71 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "74 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "75 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "76 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "77 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "78 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "79 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "80 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "81 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "84 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "86 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "87 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "88 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "89 c\##NADA " /etc/suricata/suricata.yaml
clear
echo "Hecho![2]"
sed --in-place "90 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "91 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "92 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "93 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "94 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "95 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "97 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "98 c\##NADA " /etc/suricata/suricata.yaml
clear
echo "Hecho![3]"
sed --in-place "99 c\ - decoder-events.rules " /etc/suricata/suricata.yaml
sed --in-place "100 c\ - stream-events.rules " /etc/suricata/suricata.yaml
sed --in-place "101 c\ - http-events.rules " /etc/suricata/suricata.yaml
sed --in-place "102 c\ - smtp-events.rules " /etc/suricata/suricata.yaml
sed --in-place "103 c\ - dns-events.rules " /etc/suricata/suricata.yaml
sed --in-place "104 c\ - tls-events.rules " /etc/suricata/suricata.yaml
clear
echo "Hecho![4]"
sed --in-place "105 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "106 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "107 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "108 c\##NADA " /etc/suricata/suricata.yaml
sed --in-place "110 c\classification-file: /etc/suricata/classification.config " /etc/suricata/suricata.yaml
sed --in-place "111 c\reference-config-file: /etc/suricata/reference.config " /etc/suricata/suricata.yaml
sed --in-place "112 c\threshold-file: /etc/suricata/threshold.config " /etc/suricata/suricata.yaml
sed --in-place "122 c\default-log-dir: /var/log/suricata/ " /etc/suricata/suricata.yaml
sed --in-place "526 c\      filename: /var/log/suricata/suricata.log " /etc/suricata/suricata.yaml
pr

##Limpieza
cd
rm -r lib*
rm -r daq*
rm -r suricata-*
#########


###Registrar suricata en prelude-manager
clear
cd
echo "Se realizara el registro del sensor de suricata"
echo "Por favor abrir otra terminal y ejecutar el siguiente comando \n"
echo "prelude-admin registration-server prelude-manager \n"
echo "Luego a continuacion digite la clave generada en la terminal. Recuerda dar yes en la autenticacion \n"
prelude-admin register "suricata" "idmef:w" 127.0.0.1 --uid 0 --gid 0
echo "Listo, sensor registrado"
sleep 5
service prelude-manager restart
clear
echo "Configuracion completada \n"
echo "Se ejecutara el sensor de suricata"
echo "Enter para continuar"
read NADA
echo "Ingrese a su navegador con la IP del equipo para revisar el estado de los agentes \n"
/usr/bin/prelude-lml -d -q -P /var/run/prelude-lml.pid
suricata -c /etc/suricata/suricata.yaml -i eth0
