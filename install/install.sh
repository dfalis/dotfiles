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

# Install services and timers {{{

if [[ "$device" -eq "rpi" ]]
then
	PATH_SERVICES="./custom_services"
	PATH_DEST="/etc/systemd/system/"

	# copy services and timers into /etc/systemd/system
	sudo cp "$PATH_SERVICES/*.service" "$PATH_DEST"
	sudo cp "$PATH_SERVICES/*.timer" "$PATH_DEST"

	# Reload daemon after installation of services and timers
	sudo systemctl daemon-reload

	sudo systemctl enable --now automnt.service
	sudo systemctl enable create_ap_at_boot.timer
fi

# }}}

# Additional setup for auto-mount service on rpi {{{

if [[ "$device" -eq "rpi" ]]
then
	MNT_MEDIA="/media"

	[[ ! -d $MNT_MEDIA ]] && sudo mkdir -p "$MNT_MEDIA"
	
	# create udev rules for mounting to /media
	sudo cp "./custom_rules/99-udisks2.rules" "/etc/udev/rules.d/"
	
	# remove mountpoints in /media on boot
	sudo bash -c 'echo "D /media 0755 root root 0 -" > /etc/tmpfiles.d/media.conf'
fi

# }}}

# Create user kodi_autologin {{{

if [[ "$device" -eq "rpi" ]]
then
	sudo useradd -m kodi_autologin
fi

# }}}

# Install override to autologin as kodi_autologin user {{{

UNIT="getty@tty1"
DIR="/etc/systemd/system/${UNIT}.service.d"

sudo mkdir "$DIR"
sudo cp "./service_overrides/${UNIT}_override.conf" "$DIR/override.conf"

# }}}
