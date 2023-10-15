#!/bin/bash

source /etc/openvpn/utils.sh

# Source our persisted env variables from container startup
. /plex/environment-variables.sh

# This script will be called with OpenVPN environment variables
# See https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/#scripting-and-environmental-variables
echo "Up script executed with device=$dev ifconfig_local=$ifconfig_local"
if [[ "$ifconfig_local" = "" ]]; then
  echo "ERROR, unable to obtain tunnel address"
  echo "killing $PPID"
  kill -9 $PPID
  exit 1
fi

# Re-create `--up` command arguments to maintain compatibility with old user scripts
USER_SCRIPT_ARGS=("$dev" "$tun_mtu" "$link_mtu" "$ifconfig_local" "$ifconfig_remote" "$script_context")

. /plex/userSetup.sh

if [[ ! -e "/dev/random" ]]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

if [[ "true" = "$DROP_DEFAULT_ROUTE" ]]; then
    echo "DROPPING DEFAULT ROUTE"
    # Remove the original default route to avoid leaks.
    /sbin/ip route del default via "${route_net_gateway}" || exit 1
fi

echo "STARTING PLEX"

sudo -Eu ${RUN_AS} /entrypoint.sh &

# Configure port forwarding if applicable
if [[ -f /etc/openvpn/${OPENVPN_PROVIDER,,}/update-port.sh && (-z $DISABLE_PORT_UPDATER || "false" = "$DISABLE_PORT_UPDATER") ]]; then
  echo "Provider ${OPENVPN_PROVIDER^^} has a script for automatic port forwarding. Will run it now."
  echo "If you want to disable this, set environment variable DISABLE_PORT_UPDATER=true"
  exec /etc/openvpn/${OPENVPN_PROVIDER,,}/update-port.sh &
fi

echo "Plex startup script complete."
