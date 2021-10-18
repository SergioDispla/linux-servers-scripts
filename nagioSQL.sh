#!/bin/bash
clear
cd

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
echo "Por favor configura su red como ADAPTADOR PUENTE
Presione ENTER para continuar"
read NADA
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
auto eth0
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
echo "source /etc/network/interfaces.d/* \n
auto lo
iface lo inet loopback \n
auto eth0
iface eth0 inet static
address $IP
netmask $MASK " > /etc/network/interfaces
ifdown eth0
ifup eth0
echo "Configuraracion de Interface lista"
echo "Se reiniciara el equipo. Enter para continuar"
read NADA
init 6
}

red
apt-get update
apt-get -y install apache2 
apt-get -y install apache2-utils 
apt-get -y install libapache2-mod-php5
apt-get -y install build-essential
apt-get -y install mysql-server mysql-client
apt-get -y install php-pear rrdtool librrds-perl 
apt-get -y install php5-gd php5-mysql
apt-get -y install unzip

clear
##SE CREA USUARIO Y GRUPO NAGIOS
echo  "Se creara el usuario: nagios"
sleep 2 
useradd -m -s /bin/bash nagios
echo "Digite una contraseña para el usuario nagios"
passwd nagios
echo " \n"
echo "Se creara el grupo: nagcmd"
sleep 2
groupadd nagcmd

usermod -a -G nagcmd nagios
usermod -a -G nagcmd,nagios www-data
clear
##DESCARGA FICHERO NAGIOS
echo '
############################################################################
####               DESCARGANDO NAGIOS CORE                              ####
############################################################################ 
'
cd
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.0.tar.gz
tar -xzf nagios-4.2.0.tar.gz
cd nagios-4*
NGN=`pwd | cut -d/ -f3`
sed --in-place "4823 c\		HTTPD_CONF=\"/etc/apache2/sites-available\" " /root/$NGN/configure

##EJECUTAR EL SCRIPT CONFIGURE
./configure --with-command-user=nagios --with-command-group=nagcmd --with-nagios-user=nagios --with-nagios-group=nagcmd

make all
sleep 2;
make install 
sleep 2;
make install-init
sleep 2;
make install-config
sleep 2;
make install-commandmode
sleep 2;
make install-webconf
sleep 2;

clear
echo "Digite una contraseña para el usuario: nagiosadmin"
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

make install-exfoliation
sleep 2;
chmod 600 /usr/local/nagios/etc/htpasswd.users
chown nagios:nagcmd /usr/local/nagios/etc/htpasswd.users

cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
clear
##DESCARGAR NAGIOS PLUGIN
echo '
############################################################################
####               DESCARGANDO NAGIOS PLUGIN                            ####
############################################################################ 
'
cd
rm -r nagios-*
wget https://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
tar -xzf nagios-plugins-2.1.2.tar.gz
cd nagios-plugins-*
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make 
sleep 2;
make install 
sleep 2;

cd
sed --in-place "51 c\cfg_dir=/usr/local/nagios/etc/servers" /usr/local/nagios/etc/nagios.cfg
mkdir -p /usr/local/nagios/etc/servers
clear
a2enmod rewrite
a2enmod cgi

ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/

clear
service apache2 restart
service nagios start
service nagios restart

sed --in-place "858 c\   extension=msql.so" /etc/php5/apache2/php.ini
clear
##DESCARGA NAGIOSQL
echo '
############################################################################
####               DESCARGANDO NAGIOSQL                                 ####
############################################################################ 
'
wget https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.1.1/nagiosql_311.tar.gz
tar -xvzf nagiosql_311.tar.gz
mv nagiosql /usr/local/nagios/nagiosql
ln -s /usr/local/nagios/nagiosql /var/www/html/nagiosql
pear install HTML_Template_IT

mkdir /usr/local/nagios/etc/objects/hosts
mkdir /usr/local/nagios/etc/objects/services
mkdir /usr/local/nagios/etc/objects/backup
mkdir /usr/local/nagios/etc/objects/backup/hosts
mkdir /usr/local/nagios/etc/objects/backup/services

chown -R nagios:nagcmd /usr/local/nagios
chmod 770 /usr/local/nagios/nagiosql/config
chmod 770 /usr/local/nagios/nagiosql/config/
chmod g+w /usr/local/nagios/nagiosql 
chmod g+w /usr/local/nagios/nagiosql/
chmod g+w /usr/local/nagios/etc/objects/hosts
chmod g+w /usr/local/nagios/etc/objects/services
chmod g+w /usr/local/nagios/etc/objects/backup
chmod g+w /usr/local/nagios/etc/objects/backup/hosts
chmod g+w /usr/local/nagios/etc/objects/backup/services


echo '#!/bin/bash
sed --in-place '845 c\host_perfdata_file_template=DATATYPE::HOSTPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tHOSTPERFDATA::$HOSTPERFDATA$\\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$ '/usr/local/nagios/etc/nagios.cfg
echo "Presione Enter"
read NADA
sed --in-place '845 c\service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tSERVICEDESC::$SERVICEDESC$\\tSERVICEPERFDATA::$SERVICEPERFDATA$\\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$\\tSERVICESTATE::$SERVICESTATE$\\tSERVICESTATETYPE::$SERVICESTATETYPE$ ' /usr/local/nagios/etc/nagios.cfg
echo "Presione Enter"
read NADA
' > /root/rem-nagios.sh


AH="'845 c\\"
BH='host_perfdata_file_template=DATATYPE'
CH='HOSTPERFDATA\\\\tTIMET::$TIMET$\\\\tHOSTNAME::$HOSTNAME$\\\\tHOSTPERFDATA'
DH='$HOSTPERFDATA$\\\\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\\\\tHOSTSTATE'
EH='$HOSTSTATE$\\\\tHOSTSTATETYPE::$HOSTSTATETYPE$'
FH=" ' /usr/local/nagios/etc/nagios.cfg "


AS="'846 c\\"
BS='service_perfdata_file_template=DATATYPE'
CS='SERVICEPERFDATA\\\\tTIMET::$TIMET$\\\\tHOSTNAME::$HOSTNAME$\\\\tSERVICEDESC'
DS='$SERVICEDESC$\\\\tSERVICEPERFDATA::$SERVICEPERFDATA$\\\\tSERVICECHECKCOMMAND'
ES='$SERVICECHECKCOMMAND$\\\\tHOSTSTATE::$HOSTSTATE$\\\\tHOSTSTATETYPE'
FS='$HOSTSTATETYPE$\\\\tSERVICESTATE::$SERVICESTATE$\\\\tSERVICESTATETYPE::$SERVICESTATETYPE$ '
GS=" ' /usr/local/nagios/etc/nagios.cfg "

sed --in-place "2 c\sed --in-place $AH\\ $BH::$CH::$DH::$EH $FH " /root/rem-nagios.sh
sed --in-place "5 c\sed --in-place $AS\\ $BS::$CS::$DS::$ES::$FS $GS " /root/rem-nagios.sh


#################################SCRIPT INTERNO###########################################
echo '#!/bin/bash
clear
cd
echo "Por favor dirigirse a su navegador e ingresar a http://suIP/nagiosql"
echo "Realizar la configuracion inicial segun el manual"
sleep 10;
echo "  "
echo "NOTA: Realizar esto cuando el asistente web se lo pida"
echo "Presione ENTER para eliminar el directorio /usr/local/nagios/nagiosql/install"
read NADA
rm -rf /usr/local/nagios/nagiosql/install/
clear
echo "Vuelva a ingresar al navegador"
echo "Se debe de configurar la parte de  Dominios manualmente hasta la parte de edicion
del fichero nagios.cfg (Nagios Config)"
sleep 10;
echo "Una vez realizado lo anterior presione ENTER para continuar "
read NADA
sed --in-place "29 c\#NADA " /usr/local/nagios/etc/nagios.cfg
sed --in-place "30 c\#NADA " /usr/local/nagios/etc/nagios.cfg
sed --in-place "31 c\#NADA " /usr/local/nagios/etc/nagios.cfg
sed --in-place "32 c\#NADA " /usr/local/nagios/etc/nagios.cfg
sed --in-place "35 c\#NADA " /usr/local/nagios/etc/nagios.cfg
echo "
cfg_file=/usr/local/nagios/nagiosql/contacttemplates.cfg
cfg_file=/usr/local/nagios/nagiosql/contactgroups.cfg
cfg_file=/usr/local/nagios/nagiosql/contacts.cfg
cfg_file=/usr/local/nagios/nagiosql/timeperiods.cfg
cfg_file=/usr/local/nagios/nagiosql/commands.cfg
cfg_file=/usr/local/nagios/nagiosql/hostgroups.cfg
cfg_file=/usr/local/nagios/nagiosql/servicegroups.cfg
cfg_dir=/usr/local/nagios/etc/objects/hosts
cfg_dir=/usr/local/nagios/etc/objects/services
cfg_file=/usr/local/nagios/nagiosql/hosttemplates.cfg
cfg_file=/usr/local/nagios/nagiosql/servicetemplates.cfg
cfg_file=/usr/local/nagios/nagiosql/servicedependencies.cfg
cfg_file=/usr/local/nagios/nagiosql/serviceescalations.cfg
cfg_file=/usr/local/nagios/nagiosql/hostdependencies.cfg
cfg_file=/usr/local/nagios/nagiosql/hostescalations.cfg
cfg_file=/usr/local/nagios/nagiosql/hostextinfo.cfg
cfg_file=/usr/local/nagios/nagiosql/serviceextinfo.cfg " >> /usr/local/nagios/etc/nagios.cfg
sleep 2;

clear
echo "Vaya nuevamente al navegador e ingrese a http://suIP/nagiosql"
echo "Por favor dirigirse a Herramientas/Control de Nagios y haga clic en todos los botones
segun su orden \n"
echo "Una vez realizado lo anterior, puede continuar con la ejecucion del script"
sleep 10; 
echo "Enter para continuar"
read NADA
service nagios restart
clear
##DESCARGA PNP4NAGIOS
echo "
############################################################################
####               DESCARGANDO PNP4NAGIOS                               ####
############################################################################ 
"

cd
wget https://sourceforge.net/projects/pnp4nagios/files/latest/pnp4nagios
tar -xzf pnp4nagios
cd pnp4nagios-*

PNP=`pwd | cut -d/ -f3`
sed --in-place "5806 c\                HTTPD_CONF=\"/etc/apache2/sites-available\" " /root/$PNP/configure
./configure -prefix=/usr/local/nagios/pnp4nagios 
sleep 2;
make all
sleep 2;
make fullinstall
sleep 2;
mv contrib/ssi/status-header.ssi /usr/local/nagios/share/ssi/
chown -R nagios:nagcmd /usr/local/nagios/share/ssi
chown -R nagios:nagcmd /usr/local/nagios/pnp4nagios
chmod 777 /usr/local/nagios/etc/htpasswd.users
/etc/init.d/apache2 restart 

sed --in-place "810 c\process_performance_data=1" /usr/local/nagios/etc/nagios.cfg
sed --in-place "832 c\host_perfdata_file=/usr/local/nagios/pnp4nagios/var/host-perfdata " /usr/local/nagios/etc/nagios.cfg
sed --in-place "833 c\service_perfdata_file=/usr/local/nagios/pnp4nagios/var/service-perfdata " /usr/local/nagios/etc/nagios.cfg
sh /root/rem-nagios.sh
rm /root/rem-nagios.sh
sed --in-place "857 c\host_perfdata_file_mode=a " /usr/local/nagios/etc/nagios.cfg
sed --in-place "858 c\service_perfdata_file_mode=a " /usr/local/nagios/etc/nagios.cfg
sed --in-place "868 c\host_perfdata_file_processing_interval=15 " /usr/local/nagios/etc/nagios.cfg
sed --in-place "869 c\service_perfdata_file_processing_interval=15 " /usr/local/nagios/etc/nagios.cfg
sed --in-place "878 c\host_perfdata_file_processing_command=process-host-perfdata-file " /usr/local/nagios/etc/nagios.cfg
sed --in-place "879 c\service_perfdata_file_processing_command=process-service-perfdata-file " /usr/local/nagios/etc/nagios.cfg
service apache2 restart
service nagios restart
clear

##BORRAR FICHEROS
cd
rm -r nagios-plugins*
rm -r nagiosql*
rm -r pnp4nagios*

echo "Configuracion Finalizada"
echo "Por favor continue con la parte de COMANDOS y DEFINICIONES" 
sleep 4; ' > /etc/init.d/nagioSQL.sh

chmod 777 /etc/init.d/nagioSQL.sh
clear
echo "Configuracion primer etapa finalizada"
echo "Se reiniciara el equipo. Por favor despues del reinicio ejecutar 
/etc/init.d/nagioSQL "
echo "Enter para continuar"
read NADA
cd
init 6
