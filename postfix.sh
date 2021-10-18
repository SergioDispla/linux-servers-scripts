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

echo "Configuracion Basica Postfix finalizada"
### EN CASO DE NO ENVIAR CORREOS HACER:
### 1.Tratar de enviar un correo a otro usuario (Saldra un error de SMTP, es normal)
### 2.REINICIAR LOS SERVICIOS DE: DOVECOT & POSTFIX
### 3.VOLVER A INTENTAR ENVIAR EL MENSAJE 
### 4.EN CASO DE NO FUNCIONAR LO ANTERIOR, REINICIAR EL EQUIPO

clear
##CONFIGURACION DE AUTENTICACION
echo "Desea adicionar autenticacion SSL(s/n)"
read INF
if [ $INF != n ]
then
cd /etc/ssl/private
openssl genrsa -aes128 -out server.key 2048
echo "Certificado generado, Enter para continuar"
read NADA
openssl rsa -in server.key -out server.key
echo "Certificado generado, Enter para continuar"
read NADA
openssl req -new -days 3650 -key server.key -out server.csr
echo "Certificado generado, Enter para continuar"
read NADA
openssl x509 -in server.csr -out server.crt -req -signkey server.key -days 3650
echo "Certificado generado, Enter para continuar"
read NADA
chmod 400 /etc/ssl/private/server.*

cd
##fichero main.cf
echo "
smtpd_use_tls = yes
smtpd_tls_cert_file = /etc/ssl/private/server.crt
smtpd_tls_key_file = /etc/ssl/private/server.key
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache" >> /etc/postfix/main.cf
echo "Listo, Enter para continuar"
read NADA

#fichero master.cf
sed --in-place "28 c\smtps     inet  n       -       -       -       -       smtpd" /etc/postfix/master.cf
sed --in-place "29 c\  -o syslog_name=postfix/smtps" /etc/postfix/master.cf
sed --in-place "30 c\  -o smtpd_tls_wrappermode=yes" /etc/postfix/master.cf

#fichero 10-ssl-conf
sed --in-place "6 c\ssl = yes" /etc/dovecot/conf.d/10-ssl.conf
sed --in-place "12 c\ssl_cert = </etc/ssl/private/server.crt" /etc/dovecot/conf.d/10-ssl.conf
sed --in-place "13 c\ssl_key = </etc/ssl/private/server.key" /etc/dovecot/conf.d/10-ssl.conf

/etc/init.d/postfix restart
/etc/init.d/dovecot restart
fi
echo "Configuracion SSL Finalizada"

##PARA CONFIGURAR EL SSL EN THUNDERBIRD
## 1.Escribir el usuario, email y contraseña y hacer clic en CONTINUE
## Esperar a que encuentre la configuracion el programa. (No dar en Manual Config)
## 2.Una vez que ha encontrado los ajustes, ahora si, hacer clic en Manual Config
## 3.Cambiar (si fuera el caso ) el server hostname, y escribir el FQDN o direccion IP
## del servidor de correo. 
## 4. Seleccionar SSL/TLS y en Authentication seleccionar Automatic.
## 5.Por ultimo hacer clic en Re-test, y ya no deberia aparecer ningun error.
## 6.Clic en Done y aceptar el certificado.
 

