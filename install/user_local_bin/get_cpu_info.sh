#! /bin/bash

cpu_freq=$(($(vcgencmd measure_clock arm | cut -d= -f2) / 1000000))
cpu_temp=$(vcgencmd measure_temp | cut -d= -f2)
cpu_voltage=$(vcgencmd measure_volts | cut -d= -f2)
cpu_throttled=$(vcgencmd get_throttled | cut -d= -f2)

echo "Freq = $cpu_freq MHz"
echo "Temp = $cpu_temp"
echo "Voltage = $cpu_voltage"
echo -n "Throttled = "
if [ "$cpu_throttled" = "0x0" ]; then
	echo "False"
else
		echo "$cpu_throttled"
fi

exit 0
