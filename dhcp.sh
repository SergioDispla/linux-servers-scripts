#!/bind/bash

clear
B=`dpkg --get-selections | grep "isc-dhcp-server" | wc -l`

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

if [ $B != 1 ]
then
echo "Los paquetes de isc-dhcp-server no estan instalados"
red ##CONFIGURA LA TARJETA PARA DHCP CON NAT
clear
apt-get -y install isc-dhcp-server
clear
red2 #CONFIGURA LA TARJETA DE RED EN ESTATICA
fi
clear
echo "Paquetes isc-dhcp-server estan instalados"
red2 #CONFIGURA LA TARJETA DE RED EN ESTATICA 

clear
echo "Ingrese el nombre de su dominio DNS (Example: midominio.com)"
read DOM
echo "Ingrese la direccion IP de su servidor DNS"
read IPDNS
echo "Ingrese el nombre de equipo de su servidor DNS"
read NOMDNS
##FICHERO HOSTS
echo "Trabajando en el fichero hosts"
sed --in-place "2 c\127.0.1.1	`hostname`.$DOM 	`hostname`" /etc/hosts
sed --in-place "3 c\ $IPDNS	$NOMDNS.$DOM 	$NOMDNS" /etc/hosts
sed --in-place "3 a\ $IP	`hostname`.$DOM	`hostname`" /etc/hosts

##FICHERO HOST.CONF
echo "Trabajando en el fichero host.conf"
echo "order bind,hosts 
multi on" > /etc/host.conf

##FICHERO RESOLV.CONF
echo "Trabajando en el fichero resolv.conf"
echo "domain $DOM
search $DOM
nameserver $IPDNS" > /etc/resolv.conf

#DHCP
echo "Trabajando en DHCP"
echo > /etc/default/isc-dhcp-server 
echo "INTERFACES=\"eth0\" " > /etc/default/isc-dhcp-server

cd ; cd /etc/dhcp/
clear
echo "Ingrese el rango de su servidor DHCP"
echo "IP Inicial"
read RANG2
echo "Rango $RANG2 - "
echo "IP Final"
read RANG3
echo "Rango $RANG2 - $RANG3"
echo > dhcpd.conf
RANGE=`echo $IP | cut -d"." -f1,2,3`
echo "log-facility local7;

subnet $RANGE.0 netmask $MASK {
  range $RANG2 $RANG3;
  option domain-name-servers $IPDNS;
  option domain-name \"$DOM.\";
  option routers $GAT;
  option broadcast-address $RANGE.255;
  default-lease-time 600;
  max-lease-time 7200;
}" > /etc/dhcp/dhcpd.conf

##CONFIG DE DHCP.conf
echo "dhcpd.conf listo"
/etc/init.d/isc-dhcp-server restart
echo "SERVICIO DHCP COMPLETADO"

