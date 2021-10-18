#!/bin/bash 
clear
##CONFIGURACION DE AUTENTICACION
echo "FUNCION BETA"
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

