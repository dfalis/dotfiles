#! /bin/bash

# Main variables
AP_IFACE='wlan0'
INTERNET_IFACE='wlan1'
AP_NAME='Raspberry yo'
AP_PASSWORD='pipopipo'
CMD_PARAMS='-c 8 -w 2 --freq-band 2.4 --no-virt -g 192.168.7.1'

# Check if connected to wifi {{{

curl -s "https://ipapi.co/json" > /dev/null 2>&1

if [[ $? -eq 0 ]]
then
	CONNECTED=true
	printf -- 'Connected to wifi... Not creating AP for control.\n'
else
	CONNECTED=false
fi

# }}}

# Create AP if not connected to wifi {{{

if [[ "$CONNECTED" = false ]]; then

	printf -- 'Not connected to wifi... Trying to create AP...\n'

	CMD_PARAMS+=' -n'
	/usr/bin/create_ap $CMD_PARAMS "$AP_IFACE" "$AP_NAME" "$AP_PASSWORD"

	# Else dont do anything
#else
	# /usr/bin/create_ap $CMD_PARAMS "$AP_IFACE" "$INTERNET_IFACE" "$AP_NAME" "$AP_PASSWORD"
fi

# }}}
