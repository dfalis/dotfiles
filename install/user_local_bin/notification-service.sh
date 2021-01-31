#! /bin/bash

cache_path="$HOME/.notification-service"
cache_file="$cache_path/num_of_packages"
regex_is_num='^[0-9]+$'

# Read value {{{
read_value(){
	if [ -f $cache_file ]; then
		read_val=$(cat "$cache_file")

		if [[ $read_val =~ $regex_is_num ]]; then
			echo "$read_val"

		else
			echo 'NaN'
		fi
	else
		echo 'File not found!'
	fi
}
# }}}

# Write value {{{
write_value(){
	yay -Sy > /dev/null 2>&1
	grepped="$(yay -Qu | wc -l)"
	[ -d $cache_path ] || mkdir $cache_path
	
	if [[ $grepped =~ $regex_is_num ]]; then
		
		echo "$grepped" > $cache_file
		printf -- '%s packages needs to be updated.' "$grepped"

	else
		echo '0' > $cache_file
		printf -- 'Bad value read! [%s]' "$grepped"
	fi
}
# }}}

show_help(){
	echo -e "Usage:"
	echo -e "\t$0 -r"
	echo -e "\tor"
	echo -e "\t$0 -w"
}

while getopts "h?rw" opt; do
	case "$opt" in
	h|\?)
		show_help
		exit 0
		;;
	r)
		read_value
		;;
	w)
		write_value
		;;
	esac
done
