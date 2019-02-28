#!/bin/sh
# Use tcpdump to debug EAP traffic
set -x
tcpdump -xx -e -n -vvv -i ${1:-eth0} ether proto 0x888e
