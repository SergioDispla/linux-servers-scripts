#!/bin/bash

echo "
# 

# deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 DVD Binary-1 20170116-11:01]/ jessie contrib main

#deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 DVD Binary-1 20170116-11:01]/ jessie contrib main

deb http://httpredir.debian.org/debian/ jessie main
deb-src http://httpredir.debian.org/debian/ jessie main

deb http://security.debian.org/ jessie/updates main contrib
deb-src http://security.debian.org/ jessie/updates main contrib

# jessie-updates, previously known as 'volatile'
deb http://httpredir.debian.org/debian/ jessie-updates main contrib
deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib" > /etc/apt/sources.list

echo "Listo"

