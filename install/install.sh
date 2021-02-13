#! /bin/bash
# vim:fileencoding=utf-8:foldmethod=marker

# Get device type
printf -- 'Which device are you on? (normal/RPI)\n'
read device
device=${device:-rpi}

# Ask to shorten boot time only if on RPI device
shorten_boot='n'
if [[ "$device" -eq "rpi" ]]
then
	# Shorten boot time
	printf -- 'Do you want to shorten boot time by disabling services that are not needed? (Y/n)\n'
	read shorten_boot
	shorten_boot=${shorten_boot:-y}
fi

# Create new user pipo instead of the default one {{{

# if rpi device
#	sudo useradd -G wheel -m pipo
#	sudo passwd pipo

# }}}

# Configure locale {{{

# in file /etc/locale.gen find line '#en_US.UTF-8 UTF-8' find and uncomment with sed
# locale-gen

# }}}

# Make pacman colorful {{{

#  uncomment '#Color'

# }}}

# Add pipo to sudoers file {{{

# TODO:

# }}}

# install yay {{{

# pacman -Syy
# pacman -S --needed git base-devel sudo
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si
# cd ..

# }}}

# install other packages {{{

# yay -S zsh prezto prezto-git lsd neofetch htop youtube-dl

# if any rpi
# yay -S rng-tools

# if rpi 4
# yay -S ffmpeg

# }}}

# Setup rng-tools {{{

# if any rpi, check if rnd or haveged is running, if haveged, configure rngd
# 	bash -c 'echo RNGD_OPTS=\"-o /dev/random -r /dev/hwrng\" > /etc/conf.d/rngd'
# 	sudo systemctl disable haveged.service
# 	sudo systemctl enable --now rngd.service
# 	sudo systemctl stop haveged.service

# }}

# Install /usr/local/bin scripts {{{

BIN_SRC="./user_local_bin"
USR_LOCAL_BIN="/usr/local/bin"

[[ ! -d $USR_LOCAL_BIN ]] && sudo mkdir -p "$USR_LOCAL_BIN"

if [[ "$device" -eq "normal" ]]
then
	sudo cp "$BIN_SRC/notification-service.sh" "$USR_LOCAL_BIN"
	sudo chmod a+x "$USR_LOCAL_BIN"

elif [[ "$device" -eq "rpi" ]]
then
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
	sudo systemctl enable --now create_ap_at_boot.timer
	sudo systemctl enable --now cron-log-cpu-info.timer
	sudo systemctl enable --now notification-service.timer
fi

# }}}

# Shorted boot time for RPi by disabling services {{{
if [[ "$shorten_boot" -eq "y" ]]
then
	# on rpi we dont need lvm and it shortends time by a lot
	sudo systemctl mask lvm2-monitor.service
	
	# also we dont need to kill any wireless devices
	# (comment if want to make HW wifi killswitch)
	sudo systemctl mask systemd-rfkill.service
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

# Create user kodi_autologin and install autologin override for getty@tty1 {{{

if [[ "$device" -eq "rpi" ]]
then
	sudo useradd -m kodi_autologin

	UNIT="getty@tty1"
	DIR="/etc/systemd/system/${UNIT}.service.d"
	
	sudo mkdir "$DIR"
	sudo cp "./service_overrides/${UNIT}_override.conf" "$DIR/override.conf"
fi

# }}}
