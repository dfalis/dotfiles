#! /bin/bash

DATE=`date "+%Y-%m-%d %H:%M:%S"`
logfile="$HOME/Desktop/cpu-temps.log"

cpu_freq=$(($(vcgencmd measure_clock arm | cut -d= -f2) / 1000000))
cpu_temp=$(vcgencmd measure_temp | cut -d= -f2 | /bin/grep -oP "^[0-9]*\.[0-9]+(?='C)")
cpu_voltage=$(vcgencmd measure_volts | cut -d= -f2)
cpu_throttled=$(vcgencmd get_throttled | cut -d= -f2)

reset_color="\e[0m"

# if is throtling print red throttle hexcode
#	else print greel False
if [ "$cpu_throttled" = "0x0" ]
then
	cpu_throttled="\e[1;32mFalse"
else
	cpu_throttled="\e[1;38;5;197m$cpu_throttled"
fi


# if cpu is higher than 60'C, print red temp,
#	elif higher than 50'C, print orange temp
#	else print green temp
if (( $(echo "$cpu_temp > 60.0" |bc -l) ))
then
	# red color
	cpu_temp="\e[1;38;5;197m$cpu_temp"

elif (( $(echo "$cpu_temp >= 50.0" |bc -l) ))
then
	# orange color
	cpu_temp="\e[1;38;5;208m$cpu_temp"

else
	# green color
	cpu_temp="\e[1;32m$cpu_temp"
fi

cpu_freq_color="\e[1;38;5;197m"

if (( $(echo "$cpu_freq <= 700" |bc -l) ))
then
	#green color
	cpu_freq_color="\e[1;32m"

elif (( $(echo "$cpu_freq <= 875" |bc -l) ))
then
	#yellow color
	cpu_freq_color="\e[1;38;5;220m"

elif (( $(echo "$cpu_freq <= 1166" |bc -l) ))
then
	#orange color
	cpu_freq_color="\e[1;38;5;208m"
fi


# printf "CPU $temp" | systemd-cat -t "cpu-temp"

#echo -e "$DATE  Temp= $cpu_temp; Freq= ${cpu_freq}Mhz;	Voltage= $cpu_voltage; Throttled= $cpu_throttled" >> $logfile
printf "%s  Temp= %b$reset_color;  Freq= $cpu_freq_color%7b$reset_color;  Voltage= %s$reset_color;  Throttled= %b$reset_color\n" \
	"$DATE" "$cpu_temp" "${cpu_freq}Mhz" "${cpu_voltage}" "$cpu_throttled" >> $logfile
