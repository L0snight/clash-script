#!/bin/bash

PROXY_BYPASS_USER="proxy"
PROXY_FWMARK="0x163"
PROXY_ROUTE_TABLE="0x163"
PROXY_DNS_SERVER="127.0.0.1:1053"
PROXY_FORCE_NERADDR="198.18.0.0/16"
CLASH_REDIRECT_PORT="7892"
CLASH_DNS_PORT="7892"

ip route del local default dev lo table "$PROXY_ROUTE_TABLE"
ip rule del fwmark "$PROXY_FWMARK" lookup "$PROXY_ROUTE_TABLE"

iptables -t nat -D OUTPUT -p tcp -j CLASH_TPROXY_LOCAL
iptables -t nat -D PREROUTING -p tcp -j CLASH_TPROXY_EXTERNAL
iptables -t nat -D OUTPUT -p udp -j CLASH_DNS_LOCAL
iptables -t nat -D PREROUTING -p udp -j CLASH_DNS_EXTERNAL
iptables -t mangle -D OUTPUT -p udp -j CLASH_TPROXY_LOCAL
iptables -t mangle -D PREROUTING -p udp -j CLASH_TPROXY_EXTERNAL

iptables -t nat -F CLASH_TPROXY_LOCAL
iptables -t nat -X CLASH_TPROXY_LOCAL
iptables -t nat -F CLASH_TPROXY_EXTERNAL
iptables -t nat -X CLASH_TPROXY_EXTERNAL

iptables -t nat -F CLASH_DNS_LOCAL
iptables -t nat -X CLASH_DNS_LOCAL
iptables -t nat -F CLASH_DNS_EXTERNAL
iptables -t nat -X CLASH_DNS_EXTERNAL

iptables -t mangle -F CLASH_TPROXY_LOCAL
iptables -t mangle -X CLASH_TPROXY_LOCAL
iptables -t mangle -F CLASH_TPROXY_EXTERNAL
iptables -t mangle -X CLASH_TPROXY_EXTERNAL



