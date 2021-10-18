#!/bind/bash
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

echo "Digite el nombre de dominio al que pertenece este equipo"
read DOMD
echo "Digite la direccion IP de su servidor DNS"
read IPDNS
echo "domain $DOMD
search $DOMD
namesearch $IPDNS" > /etc/resolv.conf
echo "Configuracion de interface lista"
}

echo "Desea agregar el servicio de Clamav?(s/n)"
read CLOP
if [ $CLOP != n ]
then
CLV=`dpkg --get-selections | grep "clamav" | wc -l`
echo $CLV
read NADA
	if [ $CLV != 5 ]
	then 
	red ##CONFIGURACION EN DHCP
	apt-get -y install clamav
	apt-get -y install clamav-daemon clamsmtp
	echo "Listo"
	fi
clear
red2 ##CONFIGURACION EN ESTATICA

clear
sed --in-place "27 c\Header: X-AV-Checked: ClamAV using ClamSMTP" /etc/clamsmtpd.conf
sed --in-place "45 c\User: clamav" /etc/clamsmtpd.conf

chown -R clamav. /var/spool/clamsmtp
chown -R clamav. /var/run/clamsmtp
chown -R clamav. /var/spool/clamsmtp
chown -R clamav. /var/run/clamsmtp

echo " " >> /etc/postfix/main.cf
echo "content_filter = scan:127.0.0.1:10026" >> /etc/postfix/main.cf

echo '
scan unix -       -       n       -       16       smtp
   -o smtp_data_done_timeout=1200
   -o smtp_send_xforward_command=yes
   -o disable_dns_lookups=yes
127.0.0.1:10025 inet n       -       n       -       16       smtpd
   -o content_filter=
   -o local_recipient_maps=
   -o relay_recipient_maps=
   -o smtpd_restriction_classes=
   -o smtpd_client_restrictions=
   -o smtpd_helo_restrictions=
   -o smtpd_sender_restrictions=
   -o smtpd_recipient_restrictions=permit_mynetworks,reject
   -o mynetworks_style=host
   -o smtpd_authorized_xforward_hosts=127.0.0.0/8' >> /etc/postfix/master.cf

systemctl restart dovecot
systemctl restart clamav-daemon
systemctl restart clamsmtp
systemctl restart postfix
systemctl disable dovecot.socket
fi
echo "Configuracion Finalizada"