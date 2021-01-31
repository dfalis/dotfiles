#! /bin/bash

TVSERVICE='/opt/vc/bin/tvservice'
FIFTMINUTE=$((SECONDS + 5*60))
#TEMP_FILE=$(mktemp)

printf -- 'Polling for HDMI.\n'

while [[ $SECONDS -lt $FIFTMINUTE ]]; do

	if $TVSERVICE -d /dev/null | grep -q '^Written'; then
	
		printf -- 'Starting Kodi...\n'

		kodi --standalone
		break
	fi

	sleep 5
done
