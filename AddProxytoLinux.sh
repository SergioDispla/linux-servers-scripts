#!/bin/bash
clear

echo "Se realizara la configuracion de cliente proxy"
echo "ENTER para continuar"
read NADA
echo "Digite la direccion IP de su servidor Proxy"
read IP
echo "
Acquire::http::Proxy \"http://$IP:3128/\"\;
Acquire::https::Proxy \"http://$IP:3128/\"\;
Acquire::ftp::Proxy \"http://$IP:3128/\"\; " > /etc/apt/apt.conf

echo "
export \"http_proxy=http://$IP:3128/\";
export \"https_proxy=http://$IP:3128/\";
export \"ftp_proxy=http://$IP:3128/\"; " >> /etc/bash.bashrc

echo "
http_proxy = http://$IP:3128/ 
https_proxy = http://$IP:3128/
ftp_proxy = http://$IP:3128/ " >> /etc/wgetrc

echo "Listo"
