function MAIN_TETHER_FUNCTION {
	echo "================== CHECK TETHER (tty7) ==========================="
	
	if [ "$CAM" == "0" ]; then
	    echo "Waiting some time until everything else is running ..."
	    sleep 6
	    tether_check_function
	else
	    echo "Cam found, we are TX, Check tether function disabled"
	    sleep 365d
	fi
}


function tether_check_function {
	while true; do
	    # pause loop while saving is in progress
	    pause_while
	    if [ -d "/sys/class/net/usb0" ]; then
	    	echo
			echo "USB tethering device detected. Configuring IP ..."

			nice pump -h wifibrdcast -i usb0 --no-dns --keep-up --no-resolvconf --no-ntp || {
				echo "ERROR: Could not configure IP for USB tethering device!"
				nice killall wbc_status > /dev/null 2>&1
				nice /home/pi/wifibroadcast-status/wbc_status "ERROR: Could not configure IP for USB tethering device!" 7 55 0
				collect_errorlog
				sleep 365d
			}

			# find out smartphone IP to send video stream to
			PHONE_IP=`ip route show 0.0.0.0/0 dev usb0 | cut -d\  -f3`

			# check if smartphone has been disconnected
			PHONETHERE=1
			/home/pi/RemoteSettings/dhcpeventThread.sh add $PHONE_IP &
			while [  $PHONETHERE -eq 1 ]; do
				if [ -d "/sys/class/net/usb0" ]; then
					PHONETHERE=1
					echo "Android device still connected ..."
				else
					PHONETHERE=0

				fi
				sleep 1
			done
	    else
			echo "Android device not detected ..."
	    fi
	    sleep 1
	done
}
