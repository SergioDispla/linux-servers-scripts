#!/bin/bash

echo "Digite el nombre del servidor apache(nombre equipo)"
read NOM
echo "Digite la direccion IP de su servidor apache"
read IP
DOM=`cat /etc/resolv.conf | grep domain | cut -d" "  -f2`
INV=`echo $IP | cut -d. -f4`
DB=`cat /etc/network/interfaces | grep address | cut -d" "  -f2`

echo "www			A	$IP
$NOM			A	$IP" >> /etc/bind/db.$DOM

echo "$INV			PTR	$NOM.$DOM.
$INV			PTR	www.$DOM." >> /etc/bind/db.$DB

/etc/init.d/bind9 restart
echo "Listo, se ha agregado su servidor apache al DNS"

