#! /bin/bash
# vim:fileencoding=utf-8:foldmethod=marker

# Install /usr/local/bin scripts {{{

BIN_SRC="./user_local_bin"
USR_LOCAL_BIN="/usr/local/bin"

[[ ! -d $USR_LOCAL_BIN ]] && sudo mkdir -p "$USR_LOCAL_BIN"

printf -- 'Which device are you on? [rpi]\n'
printf -- '(normal | rpi)\n'

read device
device=${device:-rpi}

if [[ "$device" -eq "normal" ]]
then
	sudo cp "$BIN_SRC/notification-service.sh" "$USR_LOCAL_BIN"

elif [[ "$device" -eq "rpi" ]]
then
	sudo cp -r "$BIN_SRC/*" "$USR_LOCAL_BIN"

else
	printf -- 'Unknown option!\n'
fi

# }}}

