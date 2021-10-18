#!/bin/bash 
clear
A=`dpkg --get-selections | grep "postfix" | wc -l`

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
ifup eth0 
echo "Configuracion de interface lista"
}

if [ $A != 1 ]
then
echo "Los paquetes de postfix no estan instalados"
red ##CONFIGURACION RED DHCP
apt-get -y install postfix sasl2-bin
apt-get -y install dovecot-core dovecot-pop3d dovecot-imapd
apt-get -y install heirloom-mailx 
apt-get -y install squirrelmail
echo "Listo"
fi
clear
red2 #CONFIGURACION DE RED ESTATICA

clear
echo "Ingrese el nombre de dominio DNS al que pertenece este 
equipo (midominio.com)"
read DOM
echo "Ingrese el nombre de maquina su servidor DNS"
read NOMDNS
echo "Ingrese la direccion IP de su servidor DNS"
read IPDNS

##hosts
echo "Trabajando en el fichero hosts"
echo > /etc/hosts
echo "127.0.0.1		localhost
127.0.1.1		`hostname`.$DOM 	`hostname`
$IPDNS		$NOMDNS.$DOM 		$NOMDNS
$IP 		`hostname`.$DOM		`hostname`" > /etc/hosts

##resolv.conf
echo "Trabajando en el fichero resolv.conf"
echo "domain $DOM
search $DOM
nameserver $IPDNS" > /etc/resolv.conf

cp /usr/lib/postfix/main.cf /etc/postfix/main.cf
clear
echo "Digite el nombre de su dominio de correo"
read DOM
echo "Digite su IP de red(example:192.168.1.0/24)"
read IPRED
sed --in-place '59 c\mail_owner = postfix' /etc/postfix/main.cf
sed --in-place "76 c\myhostname = `hostname`.$DOM" /etc/postfix/main.cf
sed --in-place "83 c\mydomain = $DOM" /etc/postfix/main.cf
sed --in-place '104 c\myorigin = $mydomain' /etc/postfix/main.cf
sed --in-place '118 c\inet_interfaces = all' /etc/postfix/main.cf
sed --in-place '166 c\mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain' /etc/postfix/main.cf
sed --in-place '209 c\local_recipient_maps = unix:passwd.byname $alias_maps' /etc/postfix/main.cf
sed --in-place "268 c\mynetworks = 127.0.0.0/8, $IPRED " /etc/postfix/main.cf
sed --in-place '388 c\alias_maps = hash:/etc/aliases' /etc/postfix/main.cf
sed --in-place '399 c\alias_database = hash:/etc/aliases' /etc/postfix/main.cf
sed --in-place '421 c\home_mailbox = Maildir/' /etc/postfix/main.cf
sed --in-place '557 c\smtpd_banner = $myhostname ESMTP' /etc/postfix/main.cf
sed --in-place '631 c\sendmail_path =/usr/sbin/postfix' /etc/postfix/main.cf
sed --in-place '636 c\newaliases_path = /usr/bin/newaliases' /etc/postfix/main.cf
sed --in-place '641 c\mailq_path = /usr/bin/mailq' /etc/postfix/main.cf
sed --in-place '647 c\setgid_group = postdrop' /etc/postfix/main.cf
sed --in-place '651 c\#html_directory =' /etc/postfix/main.cf
sed --in-place '655 c\#manpage_directory =' /etc/postfix/main.cf
sed --in-place '660 c\#sample_directory =' /etc/postfix/main.cf
sed --in-place '664 c\#readme_directory =' /etc/postfix/main.cf
echo "message_size_limit = 10485760" >> /etc/postfix/main.cf
echo "mailbox_size_limit = 1073741824" >> /etc/postfix/main.cf
echo " " >> /etc/postfix/main.cf
echo 'smtpd_sasl_type = dovecot' >> /etc/postfix/main.cf
echo 'smtpd_sasl_path = private/auth' >> /etc/postfix/main.cf
echo 'smtpd_sasl_auth_enable = yes' >> /etc/postfix/main.cf
echo 'smtpd_sasl_security_options = noanonymous' >> /etc/postfix/main.cf
echo 'smtpd_sasl_local_domain = $myhostname' >> /etc/postfix/main.cf
echo 'smtpd_recipient_restrictions=permit_mynetworks,permit_auth_destination,permit_sasl_authenticated,reject' >> /etc/postfix/main.cf
echo "Final"

newaliases
/etc/init.d/postfix restart
clear

echo "Configuracion del agente de correo Dovecot"
sed --in-place "30 c\listen = *" /etc/dovecot/dovecot.conf
sed --in-place "10 c\disable_plaintext_auth = no " /etc/dovecot/conf.d/10-auth.conf
sed --in-place "100 c\auth_mechanisms = plain login" /etc/dovecot/conf.d/10-auth.conf
sed --in-place "30 c\mail_location = maildir:~/Maildir" /etc/dovecot/conf.d/10-mail.conf
sed --in-place "96 c\unix_listener /var/spool/postfix/private/auth {" /etc/dovecot/conf.d/10-master.conf
sed --in-place "97 c\mode = 0666" /etc/dovecot/conf.d/10-master.conf
sed --in-place "98 c\user = postfix" /etc/dovecot/conf.d/10-master.conf
sed --in-place "99 c\group = postfix" /etc/dovecot/conf.d/10-master.conf
sed --in-place "100 c\ }" /etc/dovecot/conf.d/10-master.conf

systemctl restart dovecot
systemctl status dovecot
squirrelmail-configure
cd /etc/apache2/sites-available 
ln -s /etc/squirrelmail/apache.conf squirrelmail.conf
sed --in-place "2 c\Alias /webmail /usr/share/squirrelmail" /etc/apache2/sites-available/squirrelmail.conf
a2ensite squirrelmail.conf
cd
service apache2 reload

/etc/init.d/postfix restart
/etc/init.d/apache2 restart

echo "Configuracion Postfix finalizada"
###SE RECOMIENDA REINICIAR EN CASO DE NO FUNCIONAR EL WEBMAIL ENTRE USUARIOS
