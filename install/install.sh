#! /bin/bash
# vim:fileencoding=utf-8:foldmethod=marker

# Get device type
printf -- 'Which device are you on? (normal/RPI)\n'
read device
device=${device:-rpi}
printf -- '\n'

# Ask to shorten boot time only if on RPI device
if [[ "$device" -eq "rpi" ]]
then
	# Shorten boot time
	printf -- 'Do you want to shorten boot time by disabling services that are not needed? (Y/n)\n'
	read shorten_boot
	shorten_boot=${shorten_boot:-y}
	
	printf -- '\n'
fi

# Get name of new user {{{

printf -- 'What user do you want to create? (default: pipo)\n'
read user_name
user_name=${user_name:-pipo}

printf -- '\n'
# }}}

# Create new user $user_name instead of the default one {{{

printf -- 'Creating user %s...\n' "$user_name"
# sudo useradd -G wheel -m $user_name
printf -- 'Insert password for user %s\n' "$user_name"
# sudo passwd $user_name

printf -- '\n'
# }}}

#

# Configure locale {{{

printf -- 'Changing locale...\n'
# in file /etc/locale.gen find line '#en_US.UTF-8 UTF-8' find and uncomment with sed
# locale-gen

printf -- '\n'
# }}}

# Configure time zone {{{

sudo timedatectl set-timezone Europe/Bratislava

# }}}

# Make pacman colorful {{{

printf -- 'Setting colorful pacman...\n'
#  uncomment '#Color'
printf -- '\n'
# }}}

# Add pipo to sudoers file {{{

printf -- 'Adding user %s to sudoers...\n' "$user_name"
# TODO:

# }}}

# install yay {{{

printf -- 'Installing yay...\n'
# pacman -Syy
# pacman -S --needed git base-devel sudo
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si
# cd ..

printf -- '\n'
# }}}

# install other packages {{{

printf -- 'Installing other packages...\n'
# yay -S zsh prezto prezto-git lsd neofetch htop youtube-dl avahi figlet

#if [[ "$device" -eq "rpi" ]]
#then
#	printf -- 'Installing rng-tools on rpi...\n'
# 	yay -S rng-tools
#fi

# if rpi 4
#	printf -- 'Installing ffmpeg...\n'
# 	yay -S ffmpeg

printf -- '\n'
# }}}

# Setup rng-tools {{{

#if [[ "$device" -eq "rpi" ]]
#then
# if any rpi, check if rnd or haveged is running, if haveged, configure rngd
#	printf -- 'Checking status of rngd and haveged...\n'
#	if running haveged, and if on zero then
#	
# 	bash -c 'echo RNGD_OPTS=\"-o /dev/random -r /dev/hwrng\" > /etc/conf.d/rngd'
#	printf -- 'Disabling haveged...\n'
# 	sudo systemctl disable --now haveged.service
#	printf -- 'Enabling rngd...\n'
# 	sudo systemctl enable --now rngd.service

#	add to /boot/cmdline.txt entry random.trust_cpu=on

#	printf -- '\n'
#fi

# }}

# Install /usr/local/bin scripts {{{

printf -- 'Installing my custom scripts...\n'

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

printf -- '\n'
# }}}

# Install services and timers {{{

if [[ "$device" -eq "rpi" ]]
then
	PATH_SERVICES="./custom_services"
	PATH_DEST="/etc/systemd/system/"

	# copy services and timers into /etc/systemd/system
	printf -- 'Installing services...\n'
	sudo cp "$PATH_SERVICES/*.service" "$PATH_DEST"
	printf -- 'Installing timers...\n'
	sudo cp "$PATH_SERVICES/*.timer" "$PATH_DEST"

	# Reload daemon after installation of services and timers
	printf -- 'Reloading daemon...\n'
	sudo systemctl daemon-reload

	printf -- 'Enabling services...\n'
	sudo systemctl enable --now automnt.service
	sudo systemctl enable --now create_ap_at_boot.timer
	sudo systemctl enable --now cron-log-cpu-info.timer
	sudo systemctl enable --now notification-service.timer

	printf -- '\n'
fi

# }}}

# Setup network services {{{

# sudo systemctl mask systemd-networkd.service
# sudo systemctl enable --now NetworkManager.service

# }}}

# Shorted boot time for RPi by disabling services {{{
if [[ "$device" -eq "rpi" ]] && [[ "$shorten_boot" -eq "y" ]]
then
	printf -- 'Speeding up boot...\n'
	printf -- 'Disabling lvm2-monitor.service\n'
	# on rpi we dont need lvm and it shortends time by a lot
	sudo systemctl mask lvm2-monitor.service
	
	printf -- 'Disabling systemd-rfkill.service\n'
	# also we dont need to kill any wireless devices
	# (comment if want to make HW wifi killswitch)
	sudo systemctl mask systemd-rfkill.service
	
	printf -- '\n'
fi
# }}}

# Additional setup for auto-mount service on rpi {{{

if [[ "$device" -eq "rpi" ]]
then
	printf -- 'Adding auto mount rules...\n'
	MNT_MEDIA="/media"

	[[ ! -d $MNT_MEDIA ]] && sudo mkdir -p "$MNT_MEDIA"
	
	# create udev rules for mounting to /media
	sudo cp "./custom_rules/99-udisks2.rules" "/etc/udev/rules.d/"
	
	# remove mountpoints in /media on boot
	sudo bash -c 'echo "D /media 0755 root root 0 -" > /etc/tmpfiles.d/media.conf'
	
	printf -- '\n'
fi

# }}}

# Create user kodi_autologin and install autologin override for getty@tty1 {{{

if [[ "$device" -eq "rpi" ]]
then
	printf -- 'Creating user kodi_autologin'
	sudo useradd -m kodi_autologin

	UNIT="getty@tty1"
	DIR="/etc/systemd/system/${UNIT}.service.d"
	
	sudo mkdir "$DIR"
	printf -- 'Creating override service for %s' "$UNIT"
	sudo cp "./service_overrides/${UNIT}_override.conf" "$DIR/override.conf"
	
	printf -- '\n'
fi

# }}}

printf -- 'Done!\n'
