#!/bin/bash

# More/less taken from https://github.com/linuxserver/docker-baseimage-alpine/blob/3eb7146a55b7bff547905e0d3f71a26036448ae6/root/etc/cont-init.d/10-adduser
source /etc/openvpn/utils.sh

RUN_AS=root

if [ -n "$PUID" ] && [ ! "$(id -u root)" -eq "$PUID" ]; then
    RUN_AS=root
    if [[ "true" = "$LOG_TO_STDOUT" ]]; then
      chown ${RUN_AS}:${RUN_AS} /dev/stdout
    fi

    if [ ! "$(id -u ${RUN_AS})" -eq "$PUID" ]; then
        usermod -o -u "$PUID" ${RUN_AS};
    fi
    if [ -n "$PGID" ] && [ ! "$(id -g ${RUN_AS})" -eq "$PGID" ]; then
        groupmod -o -g "$PGID" ${RUN_AS};
    fi

    if [[ "true" = "$LOG_TO_STDOUT" ]]; then
      chown ${RUN_AS}:${RUN_AS} /dev/stdout
    fi

    # Make sure directories exist before chown and chmod
    echo "Enforcing ownership on Plex config directory"
    chown -R ${RUN_AS}:${RUN_AS} \
        /config

    echo "Applying permissions to Plex config directory"
    chmod -R go=rX,u=rwX \
        /config
fi

echo "
-------------------------------------
Plex will run as
-------------------------------------
User name:   ${RUN_AS}
User uid:    $(id -u ${RUN_AS})
User gid:    $(id -g ${RUN_AS})
-------------------------------------
"

export PUID
export PGID
export RUN_AS
