#! /bin/bash
# vim:fileencoding=utf-8:foldmethod=marker

printf -- 'Which device are you on? [rpi]\n'
printf -- '(normal | rpi)\n'

read device
device=${device:-rpi}

# Install /usr/local/bin scripts {{{

BIN_SRC="./user_local_bin"
USR_LOCAL_BIN="/usr/local/bin"

[[ ! -d $USR_LOCAL_BIN ]] && sudo mkdir -p "$USR_LOCAL_BIN"

if [[ "$device" -eq "normal" ]]; then
	sudo cp "$BIN_SRC/notification-service.sh" "$USR_LOCAL_BIN"
	sudo chmod a+x "$USR_LOCAL_BIN"

elif [[ "$device" -eq "rpi" ]]; then
	sudo cp -r "$BIN_SRC/*" "$USR_LOCAL_BIN"
	sudo chmod a+x "$USR_LOCAL_BIN"

else
	printf -- 'Unknown option!\n'
fi

# }}}

# Install auto-mount service on rpi {{{

if [[ "$device" -eq "rpi" ]]
then
	MNT_MEDIA="/media"
	PATH_SERVICES="./custom_services"
	PATH_DEST="/etc/systemd/system/"

	[[ ! -d $MNT_MEDIA ]] && sudo mkdir -p "$MNT_MEDIA"
	
	# create service
	sudo cp "$PATH_SERVICES/automnt.service" "$PATH_DEST"

	# create udev rules for mounting to /media
	sudo cp "./custom_rules/99-udisks2.rules" "/etc/udev/rules.d/"
	
	# remove mountpoints in /media on boot
	sudo bash -c 'echo "D /media 0755 root root 0 -" > /etc/tmpfiles.d/media.conf'
fi

# }}}

