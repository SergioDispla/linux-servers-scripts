#!/bin/bash
clear
sed --in-place "810 c\process_performance_data=1" /usr/local/nagios/etc/nagios.cfg
sed --in-place "832 c\host_perfdata_file=/usr/local/nagios/pnp4nagios/var/host-perfdata " /usr/local/nagios/etc/nagios.cfg
sed --in-place "833 c\service_perfdata_file=/usr/local/nagios/pnp4nagios/var/service-perfdata " /usr/local/nagios/etc/nagios.cfg
sed --in-place '845 c\host_perfdata_file_template=DATATYPE::HOSTPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tHOSTPERFDATA::$HOSTPERFDATA$\\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$ ' /usr/local/nagios/etc/nagios.cfg
echo "ENTER"
read NADA
sed --in-place '846 c\service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\\tTIMET::$TIMET$\\tHOSTNAME::$HOSTNAME$\\tSERVICEDESC::$SERVICEDESC$\\tSERVICEPERFDATA::$SERVICEPERFDATA$\\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\\tHOSTSTATE::$HOSTSTATE$\\tHOSTSTATETYPE::$HOSTSTATETYPE$\\tSERVICESTATE::$SERVICESTATE$\\tSERVICESTATETYPE::$SERVICESTATETYPE$ ' /usr/local/nagios/etc/nagios.cfg
echo "ENTER"
read NADA
sed --in-place "857 c\host_perfdata_file_mode=a " /usr/local/nagios/etc/nagios.cfg
sed --in-place "858 c\service_perfdata_file_mode=a " /usr/local/nagios/etc/nagios.cfg
sed --in-place "868 c\host_perfdata_file_processing_interval=15 " /usr/local/nagios/etc/nagios.cfg
sed --in-place "869 c\service_perfdata_file_processing_interval=15 " /usr/local/nagios/etc/nagios.cfg
sed --in-place "878 c\host_perfdata_file_processing_command=process-host-perfdata-file " /usr/local/nagios/etc/nagios.cfg
sed --in-place "879 c\service_perfdata_file_processing_command=process-service-perfdata-file " /usr/local/nagios/etc/nagios.cfg
