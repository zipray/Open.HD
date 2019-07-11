#!/bin/bash

if [ -e "/tmp/settings.sh" ]; then
    OK=`bash -n /tmp/settings.sh`
    if [ "$?" == "0" ]; then
        source /tmp/settings.sh
    else
        echo "ERROR: wifobroadcast config file contains syntax error(s)!"
        collect_errorlog
        sleep 365d
    fi else
    echo "ERROR: wifobroadcast config file not found!"
    collect_errorlog
    sleep 365d
fi

#IP Camera don`t have DHCP, so, fixed IP. Must be moved to better place.
ifconfig eth0 192.168.0.215 netmask 255.255.0.0 up
service ssh start

/home/pi/RemoteSettings/Air/TxBandSwitcher.sh &
sleep 0.2
/home/pi/RemoteSettings/Air/RxBandSwitcher.sh &
sleep 0.2
python3.5 /home/pi/RemoteSettings/BandSwitchAir.py -DefaultBandWidthAth9k $Bandwidth -SecondaryCamera $1 -BitrateMeasured $2 &
