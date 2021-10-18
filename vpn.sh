#!/bin/bash
clear
A=`dpkg --get-selections | grep openvpn | wc -l`

##FUNCION PARA CONFIGURACION CON DHCP
red(){ 
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
echo "Asegurese de tener su adaptador 2 en Red Interna
Presione ENTER para continuar\n"
echo "Inserte su direccion IP Local"
read IP
echo "Inserte su mascara de RED"
read MASK
echo "Inserte su IP de RED (example: 192.168.1.0)"
read IPRED
echo "
allow-hotplug eth1
iface eth1 inet static
address $IP
netmask $MASK
network $IPRED " >> /etc/network/interfaces
ifdown eth0
ifdown eth1
ifup eth0
ifup eth1
echo "Configuracion de interface lista"
}

if [ $A != 1 ]
then
clear
echo "Por favor asegurese de tener la siguiente configuracion en sus 
adaptadores de red:"
echo "1) Adaptador eth0: Red Adaptador Puente"
echo "2) Adaptador eth1: Red Interna\n"
echo "ENTER para continuar"
read NADA
red #CONFIGURACION DE TARJETA EN DHCP
apt-get -y install openvpn easy-rsa 
echo "Listo"
fi

#Configuracion de interface
clear
red2 #CONFIGURACION DE TARJETA 2 EN ESTATICA

clear
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf

IPA=`ifconfig eth0 | grep "inet addr" | tr -s " " "_"  | cut -d"_"  -f3 | cut -d":" -f2`

sed --in-place "25 c\local $IPA" /etc/openvpn/server.conf
sed --in-place "78 c\ca /etc/openvpn/ca.crt" /etc/openvpn/server.conf
sed --in-place "79 c\cert /etc/openvpn/`hostname`.crt" /etc/openvpn/server.conf
sed --in-place "80 c\key /etc/openvpn/`hostname`.key" /etc/openvpn/server.conf
sed --in-place "87 c\dh dh2048.pem" /etc/openvpn/server.conf
sed --in-place "136 c\push \"route $IPRED 255.255.255.0\" " /etc/openvpn/server.conf
sed --in-place "187 c\push \"redirect-gateway def1 bypass-dhcp\" " /etc/openvpn/server.conf
sed --in-place "195 c\push \"dhcp-option DNS 208.67.222.222\" " /etc/openvpn/server.conf
sed --in-place "196 c\push \"dhcp-option DNS 208.67.220.220\" " /etc/openvpn/server.conf
sed --in-place "262 c\user nobody" /etc/openvpn/server.conf
sed --in-place "263 c\group nogroup" /etc/openvpn/server.conf

echo 1 > /proc/sys/net/ipv4/ip_forward
sed --in-place "28 c\net.ipv4.ip_forward=1" /etc/sysctl.conf

apt-get -y install ufw
clear
ufw allow ssh
ufw allow 1194/udp
sed --in-place "19 c\DEFAULT_FORWARD_POLICY=\"ACCEPT\" " /etc/default/ufw
sed --in-place "10 a\# START OPENVPN RULES\n\# NAT table rules\n*nat\-POSTROUTING ACCEPT [0:0]\n\# Allow traffic from OpenVPN client to eth0\n-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE\nCOMMIT\n\# END OPENVPN RULES" /etc/ufw/before.rules

ufw enable
echo "Se volvera a habilitar, enter para continuar"
read NADA
ufw enable

cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys
YV='/etc/openvpn/easy-rsa/vars'
sed --in-place "64 c\export KEY_COUNTRY=\"CR\" " $YV 
sed --in-place "65 c\export KEY_PROVINCE=\"ALAJUELA\" " $YV
sed --in-place "66 c\export KEY_CITY=\"Plywood\" " $YV
sed --in-place "67 c\export KEY_ORG=\"INA\" " $YV
sed --in-place "68 c\export KEY_EMAIL=\"webmaster@inatec.net\" " $YV
sed --in-place "69 c\export KEY_OU=\"Telematica\" " $YV
sed --in-place "72 c\export KEY_NAME=\"`hostname`\" " $YV

openssl dhparam -out /etc/openvpn/dh2048.pem 2048

cd /etc/openvpn/easy-rsa/
. ./vars
echo "Presione Enter"
read NADA
./clean-all
clear
echo " \n"
echo "Se crearan los certificados, por favor presione enter en cada uno de los campos"
echo "NO INTRODUCIR O CAMBIAR DATOS\n"
echo "ENTER para continuar"
read NADA
./build-ca
./build-key-server `hostname`


cp /etc/openvpn/easy-rsa/keys/`hostname`.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa/keys/`hostname`.key /etc/openvpn/
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/

service openvpn start
service openvpn status

cd /etc/openvpn/easy-rsa
./build-key cliente
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/easy-rsa/keys/cliente.ovpn
sed --in-place "31 c\dev-node openVPN" /etc/openvpn/easy-rsa/keys/cliente.ovpn
sed --in-place "42 c\remote $IPA 1194" /etc/openvpn/easy-rsa/keys/cliente.ovpn
sed --in-place "89 c\cert cliente.crt" /etc/openvpn/easy-rsa/keys/cliente.ovpn
sed --in-place "90 c\key cliente.key" /etc/openvpn/easy-rsa/keys/cliente.ovpn

USU=`ls /home | head -1`
cd
mkdir -p /home/$USU/certificados
mkdir /root/certificados

cp /etc/openvpn/easy-rsa/keys/cliente.* /root/certificados
cp /etc/openvpn/easy-rsa/keys/ca.* /root/certificados
 
cp /etc/openvpn/easy-rsa/keys/cliente.* /home/$USU/certificados
cp /etc/openvpn/easy-rsa/keys/ca.* /home/$USU/certificados

cd /root/certificados 
chmod 777 *

cd /home/$USU/certificados
chmod 777 *

echo "Espere"
sleep 5; clear

echo "
Para mayor facilidad,los certificados del cliente fueron copiados al directorio
/home/$USU/certificados. Se recomienda copiar estos certificados desde el 
cliente utilizando el programa WinSCP"
echo "ENTER para continuar"
read NADA

echo '#!/bin/sh
#
## Vaciamos las reglas
iptables -F
iptables -X
iptables -t nat -F
# Creando nuevas cadenas
# salida a /dev/null in caso en caso de que existan de otra previa llamada
echo -n "Creando cadenas: "
for chain in ${FILTER_CHAINS} ; do
${IPTABLES} -t filter -F ${chain} > /dev/null 2>&1
${IPTABLES} -t filter -X ${chain} > /dev/null 2>&1
${IPTABLES} -t filter -N ${chain}
echo -n "${chain} "
done
echo "hecho."
echo 1 > /proc/sys/net/ipv4/ip_forward
#################Reglas.
echo -n "Nuevas reglas: "
iptables -N ext-lan
iptables -N ext-firewall
iptables -N lan-ext
iptables -N lan-firewall
iptables -N firewall-lan
iptables -N firewall-ext
iptables -N server-web
iptables -N server-mail
iptables -N server-ssh
iptables -N server-freenx
iptables -N server-ssl
iptables -N bloq-scan
iptables -N flags-tcp
iptables -N openvpn
iptables -N tun
echo "hecho." 
####### tun0
echo -n "--Tun0 : "
iptables -A INPUT -i eth0 -j ACCEPT
iptables -A OUTPUT -o eth0 -j ACCEPT
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -A INPUT -i eth1 -j ACCEPT
iptables -A OUTPUT -o eth1 -j ACCEPT
iptables -A FORWARD -i eth1 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "hecho." ' > /usr/local/S93cortafuegos.sh 
chmod 700 /usr/local/S93cortafuegos.sh

sed --in-place "13 a\/usr/local/S93cortafuegos.sh" /etc/rc.local

cd /etc/
./rc.local

echo "Finalizado"

