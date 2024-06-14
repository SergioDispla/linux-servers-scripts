# linux-servers-scripts
Hi All, Here you can find scripts for installing services like Apache, Postfix, FTP on Linux OS (specially designed for Debian 8.X)

### IMPORTANT NOTE: IT IS RECOMMENDED TO RUN AN APT-GET UPDATE BEFORE EXECUTING THE SCRIPT TO HAVE THE REPOSITORIES UPDATED. IT IS ALSO IMPORTANT TO HAVE THE MANUAL AT HAND TO CORRECTLY FOLLOW THE INSTALLATION OF THE SERVICE IN QUESTION.

- **addLinuxToSamba**: For clients, especially those with a Linux graphical interface, this script adds a Linux client to the sambaPDC domain. Requirements: Clean Linux machine in NAT, and having an internal DHCP server (PDC).

- **addProxyToLinux**: Configures the proxy on a Linux/Debian client, so that it remains as system configuration. Requirements: Linux OS machine without UI.

- **addServersToBind**: Used to add the IP addresses of your static servers to DNS records (forward and reverse zones) in the db files. Various types of servers are included. Requirements: Execute it on a DNS server.

- **addSNMPtoLinux**: Script to configure an SNMP client for monitoring. Requirements: Debian machine (With or Without Interface), Ubuntu Server 14. NAT network adapter.

- **apache**: Handles the entire installation and configuration of the Apache server. Includes: SSL, User Authentication.

- **bacula.sh**: Installs and configures the Bacula service. Requirements: Clean Debian machine, NAT on adapter 1. Note: Local copies are stored in "/copies".

- **cacti**: Installs and configures the Cacti monitoring service. Requirements: Clean Ubuntu Server 14 machine, NAT or Bridged network adapter. See Nagios info in the Security/MonitoringManagement folder.

- **dnsdhcp**: Configures DNS/DHCP. Requirements: Clean machine.

- **dhcp**: Installs and configures only the DHCP service (without DNS). Requirements: Clean machine, must have a separate DNS server already created.

- **interfaceConf**: Saves time by editing the /etc/network/interfaces file to switch between DHCP or Static for the network card.

- **ldapclient**: Configures a Linux client to use the LDAP service. Requirements: 1. LDAP server already created. 2. Execute it on a clean Linux client.

- **ldapserver**: Installs and configures the LDAP server. Requirements: Clean Debian machine, Adapter 1 in NAT.

- **mirrors**: Updates the /etc/apt/sources.list file to refresh the Debian mirrors.

- **mount**: Script to mount USB devices (FAT32, NTFS, EXFAT).

- **mountShareWin**: Works to mount a shared Windows folder on a Linux client (UI).

- **nagioSQL**: Installs and configures the Nagios monitoring server. See Nagios info in the Security/MonitoringManagement folder.

- **nisClient**: Configures a Linux client to use the NIS server. Requirements: 1. NIS server already created. 2. Execute it on a Linux client.

- **nisServer**: Installs and configures the NIS server.

- **ocsServer**: Installs and configures the OCS Inventory server. See Nagios info in the Security/MonitoringManagement folder.

- **ossecServer**: Installs and configures the OSSEC alert server. Requirements: Clean Ubuntu Server 16.04 machine, NAT network adapter.

- **ossecAgent**: Installs and configures an agent for monitoring with OSSEC. Requirements: Ubuntu Server or Desktop 14, Debian 8, NAT or Bridged network adapter.

- **postfixBasico**: Installs and configures the basic mail server, WITHOUT SSL. (This script complements postfixSSL).

- **postfixSSL**: Adds SSL authentication to the mail. Requirements: 1. Basic mail configuration installed and configured (WITHOUT SSL or CLAMAV).

- **postfixClamav**: Under testing. Does not work.

- **postfix**: Installs and configures the mail server, with the option to add SSL authentication. Does NOT include Clamav/antivirus. Handles the entire installation in one go.

- **prelude**: Script to install the Prelude alert server, Prelude-lml sensors, and Suricata. Requirements: Clean Ubuntu Server 14.04 machine, NAT or Bridged network adapter (Preferably Bridged). See info in the Security/Firewalls folder.

- **proFTPD**: Installs and configures a proFTPD server. Requirements: Debian machine, NAT network adapter.

- **proxy**: Installs and configures the proxy server, with options to add user authentication, ACLs, Clamav. It's an all-in-one script. Requirements: Machine with 2 network interfaces. 1-NAT, 2-Internal Network.

- **proxyMenu**: Displays a menu for proxy installation. If you have already executed proxy.sh and missed any options (Authentication, ACL, Clamav), you can add that missing feature with this script, avoiding re-execution of proxy.sh and potential errors. Requirements: Same as proxy.sh.

- **proxyTrans**: Installs and configures the proxy in transparent mode. Includes an option to add ACLs. Requirements are the same as proxy.sh.

- **sambaPDC**: Installs and configures the Samba server, but only up to the step before restarting (see MontiManual). Verification after the restart must be done manually, as well as adding users. Requirements: Clean machine.

- **sambaFINALPDC**: Fully installs and configures the Samba server, including a post-restart verification script. Option to add users to the PDC. Requirements: Clean machine. IMPORTANT: After the restart, /etc/init.d/sambaScript.sh must be executed to continue with the verification.

- **sambaServer**: Installs and configures a Samba server, only works for sharing folders with Windows.

- **snmp**: Installs and configures the SNMP service on Linux, to make it server-manageable. See SNMP Instructions file for more details. Requirements: Clean Ubuntu Server 16 or 14 machine (without graphical interface), NAT, 1 adapter.

- **snort_scripts**: Scripts to install a Snort server for intrusion detection. (BETA) Requirements: Clean Ubuntu Server 16 machine, NAT or Bridged network adapter.

- **ulteoAllOne**: Script to install the Ulteo server and Ulteo app server in one go. Requirements: Clean Ubuntu Server (14.04) machine, NAT on adapter 1.

- **ulteoserver.sh**: Run on the machine that will be the main Ulteo server. Requirements: Clean Ubuntu Server (14.04) machine, NAT on adapter 1.

- **ulteoappserver.sh**: Run on the machine that will be the application server. Requirements: Clean Ubuntu Server (14.04) machine, NAT on adapter 1.

- **vpn**: Installs and configures the VPN server. Requirements: Machine with 2 network interfaces. 1-VPN, 2-Internal.

- **webhosting**: Installs and configures the web hosting server (similar to apache.sh), to access the website directory via SFTP.

- **zenoss**: Installs and configures the ZenOss monitoring server. See Nagios info in the Security/MonitoringManagement folder.
