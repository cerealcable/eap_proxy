#!/bin/bash
# Obtain session
eval $(echo $(/bin/cli-shell-api getSessionEnv $PPID))
cli-shell-api setupSession

BIN_PATH="/opt/vyatta/sbin/eap_proxy.py"
PIDFILE="/var/run/eap_proxy.pid"
CONFIG_OPTIONS=(\
    "ping-gateway" \
    "ignore-when-wan-up" \
    "ignore-start" \
    "ignore-logoff" \
    "restart-dhcp" \
    "set-mac" \
)
DAEMON_OPTIONS=(--daemon --pidfile "$PIDFILE" --syslog)
IF_WAN=$(cli-shell-api returnValue service eap-proxy wan-interface)
IF_RG=$(cli-shell-api returnValue service eap-proxy rg-interface)
OPTIONS=()
for option in "${CONFIG_OPTIONS[@]}"; do
    if [[ "$(cli-shell-api returnValue service eap-proxy "$option")" == "enable" ]]; then
      OPTIONS+=("--$option")
    fi
done

/sbin/start-stop-daemon --stop --retry 30 --pidfile "$PIDFILE" --oknodo --quiet
/sbin/start-stop-daemon --start --pidfile "$PIDFILE" --exec "$BIN_PATH" -- \
    "$IF_WAN" "$IF_RG" "${OPTIONS[@]}" "${DAEMON_OPTIONS[@]}"
