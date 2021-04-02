#! /bin/bash

if (/opt/vc/bin/tvservice -s | /bin/grep -E 'HDMI|DVI')
then
    TVSERVICE='/opt/vc/bin/tvservice'
    FIFTMINUTE=$((SECONDS + 5*60))

    printf -- 'Polling for HDMI.\n'

    while [[ $SECONDS -lt $FIFTMINUTE ]]
    do

        if $TVSERVICE -d /dev/null | grep -q '^Written'
        then
            printf -- 'Starting Kodi...\n'
            LOGOUT=true

            kodi --standalone
            break
        fi

        sleep 5
    done
fi
