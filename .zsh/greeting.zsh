# vim:fileencoding=utf-8:foldmethod=marker

# Colors and other variables {{{

# Colors
COLOR_RESET=$'\033[0m'
COLOR_GREEN=$'\033[1;32m'
COLOR_RED=$'\033[1;38;5;197m'

# Other variables
COLUMNS=$(tput cols)

# }}}

# Functions {{{
function set_color_reset() {
	# reset color
	printf -- "$COLOR_RESET"
}

function set_color_green() {
	# set green color
	printf -- "$COLOR_GREEN"
}

function set_color_red() {
	# set red color
	printf -- "$COLOR_RED"
}

# }}}

# Hello world figlet {{{

set_color_green

# add -c to figlet to center
figlet -w $COLUMNS -c -fslant -k "hello world"

# }}}

# Print info lines {{{

REMAINING_SPACE=$(printf '%-20s %11s' 'Remaining space:' "$(df -BM / | awk 'NR>1 {print substr($4, 1, length($4)-1)/1024}')GiB")
HALF_COLUMN=$(( ($COLUMNS+1)/2 ))
#PKG_NUM=$(notification-service.sh -r)

CURR_TEMP=$(printf '%-20s %11s' 'Curr. temperature:' "$(vcgencmd measure_temp | cut -d= -f2)")
CURR_WIFI=$(printf '%-20s %11s' 'Connected to:' "$(iwconfig wlan0 | head -n1 | sed -r 's/(.*?)"(.*?)"(.*?)/\2/g')")

# if [[ "$PKG_NUM" -eq "0" ]]; then
# 	PKG_COLOR="$COLOR_GREEN"
# 	NUM_PKG_TO_UPDATE="No packages to be updated!"
# else
# 	PKG_COLOR="$COLOR_RED"
# 	NUM_PKG_TO_UPDATE=$(printf "%35s" "Need to update $PNG_NUM packages.")
# fi

# reset color
set_color_reset

printf -- "%*s\n" $(( $HALF_COLUMN + ${#REMAINING_SPACE}/2 )) "$REMAINING_SPACE"
printf -- "%*s\n" $(( $HALF_COLUMN + ${#CURR_TEMP}/2 )) "$CURR_TEMP"
printf -- "%*s\n" $(( $HALF_COLUMN + ${#CURR_WIFI}/2 )) "$CURR_WIFI"
#printf -- "${PKG_COLOR}%*s${COLOR_RESET}\n" $(( $HALF_COLUMN + ${#NUM_PKG_TO_UPDATE}/2 )) $"$NUM_PKG_TO_UPDATE"

# }}}
