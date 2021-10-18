#!/bin/bash
###FUNCION PARA CONFIGURACION CON DHCP

red(){ 
echo "Por favor asegurese de tener su adaptador de red en NAT en su VirtualBox
Presione ENTER para continuar"
read NADA
sudo sed --in-place "12 c\iface enp0s3 inet dhcp" /etc/network/interfaces
sudo sed --in-place "12 a\##NADA" /etc/network/interfaces
sudo sed --in-place "12 a\##NADA" /etc/network/interfaces
sudo ifdown enp0s3
sudo ifup enp0s3
echo "Configuracion de interface lista" 
}

##FUNCION PARA CONFIGURACION EN ESTATICA
red2(){
clear
echo "Configuracion de la interface"
echo "Inserte su direccion IP"
read IPR
echo "Inserte su mascara de RED"
read MASK
sudo sed --in-place "12 c\iface enp0s3 inet static" /etc/network/interfaces
sudo sed --in-place "13 c\address $IPR " /etc/network/interfaces
sudo sed --in-place "14 c\netmask $MASK " /etc/network/interfaces
echo "Configuracion de interface lista"
echo "Se apagara el equipo, la proxima vez debe iniciarlo desde el GNS3. ENTER para continuar"
read NADA
sleep 1; echo "5"
sleep 1; echo "4"
sleep 1; echo "3"
sleep 1; echo "2"
sleep 1; echo "1"
sudo init 0
}

clear
red 
cd
echo "Se utilizara sudo. Ingrese la contraseña del usuario `whoami`"
sudo apt-get update
sudo apt-get -y install snmp
sudo apt-get -y install snmp-mibs-downloader
sudo apt-get -y install snmpd
sudo apt-get -y install libsnmp-dev

clear
cd
sudo mkdir -p /usr/share/mibs/cisco
cd /usr/share/mibs/cisco/
sudo wget ftp://ftp.cisco.com/pub/mibs/v2/CISCO-SMI.my
sudo wget ftp://ftp.cisco.com/pub/mibs/v2/CISCO-ENVMON-MIB.my

##EDITAR FICHERO /etc/snmp/snmp.conf
cd
sudo sed --in-place "4 c\##NADA " /etc/snmp/snmp.conf
sudo sed --in-place "4 a\##NADA " /etc/snmp/snmp.conf
sudo sed --in-place "4 a\##NADA " /etc/snmp/snmp.conf
sudo sed --in-place "5 c\mibdirs +/usr/share/mibs/cisco" /etc/snmp/snmp.conf
sudo sed --in-place "6 c\mibs +CISCO-ENVMON-MIB:CISCO-SMI" /etc/snmp/snmp.conf

clear
mkdir /home/`whoami`/.snmp
cp /etc/snmp/snmp.conf .snmp/
chmod 700 .snmp/

cd
echo "Ingrese el nombre de su comunidad (example: ciscolab)"
read COMM
echo "
defVersion 3
defCommunity $COMM
defSecurityName `whoami`
defSecurityLevel authNoPriv
defAuthPassphrase $COMM
defAuthType SHA " >> .snmp/snmp.conf

cd /tmp
wget https://gist.githubusercontent.com/rarylson/72d1414d6907a4548427/raw/d97aed8debf0a291a0457ec634a3be370bd16546/net-snmp-create-v3-user
chmod +x net-*
mv net-* net-snmp-create-v3-user
sudo mv net-* /usr/local/bin/

cd
clear
echo "Ingrese su IP de Red (example: 192.168.1.0/24)"
read IP
echo "Ingrese los siguientes datos"
read -p "Nombre de ubicacion (example: telematica): " LOCA
read -p "Nombre de contacto (example: admin): " CONT
read -p "Email de contacto (example: admin@domain.com): " EMAIL
sudo sed --in-place "15 c\#NADA" /etc/snmp/snmpd.conf
sudo sed --in-place "17 c\agentAddress udp:161,udp6:[::1]:161" /etc/snmp/snmpd.conf
sudo sed --in-place "51 c\ rocommunity $COMM $IP " /etc/snmp/snmpd.conf
sudo sed --in-place "53 c\ rocommunity $COMM 127.0.0.1 " /etc/snmp/snmpd.conf
sudo sed --in-place "77 c\sysLocation    $LOCA " /etc/snmp/snmpd.conf
sudo sed --in-place "78 c\sysContact     $CONT <$EMAIL> " /etc/snmp/snmpd.conf

sudo service snmpd stop
sudo net-snmp-create-v3-user -a SHA -A $COMM `whoami`
sudo service snmpd start
/etc/init.d/snmpd status
echo " \n Enter para continuar"
read NADA

red2
