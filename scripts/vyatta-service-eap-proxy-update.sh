#!/bin/bash
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

/sbin/start-stop-daemon --stop --retry 30 --pidfile "$PIDFILE" --oknodo --quiet

if [[ "$COMMIT_ACTION" != "DELETE" ]]; then
    if_src=$(cli-shell-api returnValue service eap-proxy src-interface)
    if_dest=$(cli-shell-api returnValue service eap-proxy dest-interface)

    options=()
    for option in "${CONFIG_OPTIONS[@]}"; do
        if [[ "$(cli-shell-api returnValue service eap-proxy "$option")" == "enable" ]]; then
          options+=("--$option")
        fi
    done
    /sbin/start-stop-daemon --start --pidfile "$PIDFILE" --exec "$BIN_PATH" -- \
        "$if_src" "$if_dest" "${options[@]}" "${DAEMON_OPTIONS[@]}"
fi
