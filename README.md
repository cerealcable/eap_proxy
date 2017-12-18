# eap_proxy

Proxy EAP packets between interfaces on a  Ubiquiti Networks EdgeRouter™ Lite

Inspired by 1x_prox as posted here:

<http://www.dslreports.com/forum/r30693618->

AT&T Residential Gateway Bypass - True bridge mode!

## Instructions

- Copy `vyatta-eap-proxy.deb` to `~`
- Install with `sudo dpkg -i ~/vyatta-eap-proxy.deb`

## EdgeRouter Sample Configuration

Here's an excerpt of my EdgeRouter configuration:

```
set interfaces ethernet eth0 description WAN
set interfaces ethernet eth0 duplex auto
set interfaces ethernet eth0 firewall in name WAN_IN
set interfaces ethernet eth0 firewall local name WAN_LOCAL
set interfaces ethernet eth0 speed auto
set interfaces ethernet eth0 vif 0 address dhcp
set interfaces ethernet eth0 vif 0 description 'WAN VLAN 0'
set interfaces ethernet eth0 vif 0 dhcp-options default-route update
set interfaces ethernet eth0 vif 0 dhcp-options default-route-distance 210
set interfaces ethernet eth0 vif 0 dhcp-options name-server update
set interfaces ethernet eth0 vif 0 firewall in name WAN_IN
set interfaces ethernet eth0 vif 0 firewall local name WAN_LOCAL
set interfaces ethernet eth0 vif 0 mac 'aa:bb:cc:dd:ee:ff'
set interfaces ethernet eth1 address 192.168.1.1/24
set interfaces ethernet eth1 description LAN
set interfaces ethernet eth1 duplex auto
set interfaces ethernet eth1 speed auto
set interfaces ethernet eth2 description 'AT&T router'
set interfaces ethernet eth2 duplex auto
set interfaces ethernet eth2 speed auto
set service nat rule 5010 description 'masquerade for WAN'
set service nat rule 5010 outbound-interface eth0.0
set service nat rule 5010 protocol all
set service nat rule 5010 type masquerade
set service eap-proxy wan-interface eth0
set service eap-proxy router-interface eth2
set system offload ipv4 vlan enable
```

Update the MAC address for `eth0 vif 0` to that of your AT&T router, or let `eap_proxy` do it with the `--set-mac` option. I prefer to set it in my router config.

Note the `set system offload ipv4 vlan enable` command or you'll have horrible routing performance.

Don't forget to update the rest of your config to reference `eth0.0` as your WAN interface as needed.

I also have IPv6 working via 6rd. Here's the relevant configuration:

```
set interfaces tunnel tun0 6rd-prefix '2602:300::/28'
set interfaces tunnel tun0 6rd-default-gw '::12.83.49.81'
set interfaces tunnel tun0 address '2602:30x:xxxx:xxxx::1/60'
set interfaces tunnel tun0 description 'AT&T 6rd tunnel'
set interfaces tunnel tun0 encapsulation sit
set interfaces tunnel tun0 firewall in ipv6-name WAN6_IN
set interfaces tunnel tun0 firewall local ipv6-name WAN6_LOCAL
set interfaces tunnel tun0 local-ip YY.YY.YY.YY
set interfaces tunnel tun0 multicast disable
set interfaces tunnel tun0 ttl 255
set service dhcp-server use-dnsmasq enable
set service dns forwarding options enable-ra
set service dns forwarding options 'dhcp-range=::1,constructor:eth1,ra-names,86400'
set system offload ipv6 forwarding enable
```

The `6rd-prefix` and `6rd-default-gw` should be the same for all AT&T customers that are using 6rd. I've heard some areas may be on native dual-stack, but my area is not. The `local-ip` is your DHCP-issued WAN IP. The `tun0 address` is your 6rd delegated prefix. It is based on your WAN IP and can be computed with this bit of python:

```
python -c 'import sys;a,b,c,d=map(int,sys.argv[1].split("."));print "2602:30%x:%x%02x%x:%x%02x0::1/60" % (a>>4,a&15,b,c>>4,c&15,d)' 1.2.3.4
2602:300:1020:3040::1/60
```

If you aren't already using `dnsmasq` for DHCP, you might want to use `radvd` instead. [See the example here](https://help.ubnt.com/hc/en-us/articles/204960044-EdgeRouter-Enable-IPv6-support-via-CLI) (it's the `router-advert` section).

It may be possible to configure the tun0 interface via DHCPv6; I haven't tried.

Good luck. It works for me on my EdgeRouter Lite running EdgeOS v1.9.1.1.

## Build Instructions

To build the debian package, run the following on a host system:

```
debuild -us -uc -rsudo
```
