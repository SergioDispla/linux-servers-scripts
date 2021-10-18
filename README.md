# linux-servers-scripts
Hi All, Here you can find scripts for installing services like Apache, Postfix, FTP on Linux OS (specially designed for Debian 8.X)

Please translate to English:

Guia for Dummies:v
NOTA IMPORTANTE: ES RECOMENDABLE REALIZAR UN APT-GET UPDATE ANTES DE EJECUTAR EL SCRIPT PARA TENER LOS REPOSITORIOS ACTUALIZADOS
TAMBIEN ES IMPORTANTE TENER EL MANUAL A MANO PARA SEGUIR CORRECTAMENTE LA INSTALACION DEL
SERVICIO EN CUESTION 

addLinuxToSamba: Para clientes especialmente con interfaz grafica de linux, este script agrega un cliente linux al dominio sambaPDC. Requisitos: Maquina Limpia Linux y en NAT, ademas de contar con un servidor DHCP interno(PDC).

addProxyToLinux: Configura el proxy en un cliente linux/debian, de modo que queda como configuracion del sistema. Requisitos: Maquina SO Linux sin UI.

addServersToBind: Funciona para agregar en los registros del DNS, las IPs de sus servidores estaticos (zona directa e inversa) esto, en los ficheros db.
Se incluyen varios tipos de servidores. Requisitos: Ejecutarlo en un server DNS

addSNMPtoLinux: Script para configurar un cliente SNMP, para poder ser monitoreado.
Requisitos: Maquina Debian (Con o Sin Interfaz), Ubuntu Server 14. Adaptador de red NAT

apache: Realiza toda la instalacion y configuracion del servidor apache.
Incluye: SSL, Autenticacion de usuarios.

bacula.sh: Instala y configura el servicio de bacula.
Requisitos: Maquina Debian Limpia, adaptador 1 en NAT
Nota: Las copias locales se almacenan en "/copias"

cacti: Instala y configura el servicio de monitoreo de cacti
Requisitos: Maquina Ubuntu Server 14, Limpia, adaptador de red en NAT o Puente
Ver Info de Nagios en la carpeta de Seguridad/GestionMonitoreo.

dnsdhcp: Configura DNS/DHCP. Requisitos: Maquina Limpia

dhcp: Instala y configura unicamente el servicio de dhcp (sin DNS).
Requisitos: Maquina Limpia, Tener ya creado un servidor DNS aparte.

interfaceConf: Funciona para ahorrar tiempo en editar el fichero /etc/network/interfaces, esto para cambiar ya sea la tarjeta a DHCP o Estatica.

ldapclient: Configura un cliente linux para que pueda hacer uso del servicio de LDAP. Requisitos: 1.Tener ya creado el server ldap. 2.Ejecutarlo en un cliente linux limpio 

ldapserver: Instala y configura el servidor LDAP. 
Requisitos: Maquina Debian Limpia, Adaptador 1 en NAT

mirrors: Realiza un cambio del fichero /etc/apt/sources.list para actualizar
los mirrors de Debian.

mount: Script para montar dispositivos USB (FAT32, NTFS, EXFAT)

mountShareWin: Funciona para montar una carpeta compartida de windows en un cliente linux(UI).

nagioSQL: Instala y configura el servidor de monitoreo de Nagios.
Ver Info de Nagios en la carpeta de Seguridad/GestionMonitoreo.

nisClient: Configura un cliente linux para hacer uso del servidor NIS. Requisitos: 1.Tener creado un server NIS 2. Ejecutarlo en un cliente linux

nisServer: Instala y configura el servidor NIS.

ocsServer: Instala y configura el servidor ocsInventory.
Ver Info de Nagios en la carpeta de Seguridad/GestionMonitoreo.

ossecServer: Instala y configura el servidor de alertas OSSEC
Requisitos: Maquina Ubuntu Server 16.04 Limpia, Adaptador de Red NAT.

ossecAgent: Instala y configura un agente para poder ser monitoreado por Ossec
Requisitos: Ubuntu Server o Desktop 14, Debian 8, Adaptador de red en NAT o Puente.

postfixBasico: Instala y configura el servidor de correo basico, SIN SSL. (Este script de complementa con el postfixSSL) 

postfixSSL: Agrega solo la autenticacion SSL al correo. Requisitos: 1. Tener instalado y configurado el correo con la configuracion basica (SIN SSL o CLAMAV).

postfixClamav: en pruebas:v No funciona.

postfix: Instala y configura el servidor de correo, con la opcion de agregar la autenticacion SSL. NO incluye Clamav/antivirus. Realiza la instalacion todo en 1

prelude: Script para instalar el servidor de alertas Prelude, sensores prelude-lml y Suricata.
Requisitos: Maquina Ubuntu Server 14.04, Limpia, Adaptador de red en NAT o Puente (Preferiblemente Puente) Ver info en carpeta Seguridad/Seguridad&Firewalls

proFTPD: Instalacion y configuracion de un servidor proFTPD
Requisitos: Maquina Debian, Adaptador de red NAT

proxy: Instalacion y configuracion del servidor proxy, con la opcion de agregar autenticacion de usuarios, ACLs, Clamav. Es un script todo en 1.
Requisitos: Maquina con 2 interfaces de red. 1-NAT,2-Red Interna

proxyMenu: Muestra un menu de instalacion de proxy, en caso de que ya haya ejecutado el proxy.sh, y no agrego alguna de las opciones(Autenticacion,ACL,Clamav), puede agregar esa caracteristica faltante con este script, evitando volver a ejecutar el proxy.sh y con esto evitar posibles errores. Requisitos: Igual que proxy.sh

proxyTrans: Instala y configura el proxy en modo transparente. Incluye opcion para agregar ACLs. Requisitos igual que proxy.sh

sambaPDC: Instala y configura el servidor samba, no obstante llega hasta el paso antes del reinicio (ver MontiManual:v), la comprobacion despues del reinicio se debe hacer manualmente, al igual que agregar los usuarios. Requisitos: Maquina limpia

sambaFINALPDC: Instala y configura el servidor samba completamente, incluye un script de comprobacion despues del reinicio. Opcion para agregar usuarios al PDC. Requisitos: Maquina limpia. IMPORTANTE: despues del reinicio se debe ejecutar /etc/init.d/sambaScript.sh para continuar con la comprobacion.

sambaServer: Instala y configura un server samba, unicamente funciona para compartir carpetas con windows.

snmp: Instala y configura el servicio de SNMP en un Linux, para que este Server Manager. Ver Fichero Instrucciones SNMP para mas detalles.
Requisitos: Maquina Ubuntu Server 16 o 14 (sin interfaz grafica), Limpia, 1 Adaptador en NAT

snort_scripts: Scripts para instalar servidor de Snort, deteccion de intrusos. (BETA)
Requisitos: Maquina Ubuntu Server 16, Limpia, adaptador de red en NAT o Puente.

ulteoAllOne: Script para instalar el ulteo server y el ulteo app server en uno solo.
Requisitos: Maquina Ubuntu Server (14.04) Limpia, adaptador 1 en NAT

ulteoserver.sh: Ejecutarlo en la maquina que sera el server principal de Ulteo. Requisitos: Maquina Ubuntu Server (14.04) Limpia, adaptador 1 en NAT.

ulteoappserver.sh: Ejecutarlo en la maquina que sera el servidor de aplicaciones. Requisitos: Maquina Ubuntu Server (14.04) Limpia adaptador 1 en NAT

vpn: Instala y configura el servidor VPN. Requisitos: Maquina con 2 interfaces de red. 1-VPN,2-Interna

webhosting: Instala y configura el servidor webhosting (similar al apache.sh), para acceder via SFTP al directorio de la pagina web. 

zenoss: Instala y configura el servidor de monitoreo de ZenOss.
Ver Info de Nagios en la carpeta de Seguridad/GestionMonitoreo.
