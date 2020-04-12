#!/bin/bash

PROXY_BYPASS_USER="proxy"
PROXY_FWMARK="0x163"
PROXY_ROUTE_TABLE="0x163"
PROXY_DNS_SERVER="127.0.0.1:1053"
PROXY_FORCE_NERADDR="198.18.0.0/16"
CLASH_REDIRECT_PORT="7892"
CLASH_DNS_PORT="1053"


/opt/script/clash-tproxy/clean-clash-tproxy.sh
#创建tporxy需要的ip rule, ip route
ip route replace local default dev lo table "$PROXY_ROUTE_TABLE"
ip rule add fwmark "$PROXY_FWMARK" lookup "$PROXY_ROUTE_TABLE"
#创建tproxy相关的iptables链
iptables -t nat -N CLASH_TPROXY_LOCAL
iptables -t nat -F CLASH_TPROXY_LOCAL
iptables -t nat -N CLASH_TPROXY_EXTERNAL
iptables -t nat -F CLASH_TPROXY_EXTERNAL
#tcp_local
iptables -t nat -A CLASH_TPROXY_LOCAL -m owner --uid-owner "$PROXY_BYPASS_USER" -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 0.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 10.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 127.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 169.254.0.0/16 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 172.16.0.0/12 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 192.168.0.0/16 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 224.0.0.0/4 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -d 240.0.0.0/4 -j RETURN
iptables -t nat -A CLASH_TPROXY_LOCAL -p tcp -j REDIRECT --to "$CLASH_REDIRECT_PORT"
#tcp_external
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 0.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 10.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 127.0.0.0/8 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 169.254.0.0/16 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 172.16.0.0/12 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 192.168.0.0/16 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 224.0.0.0/4 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -d 240.0.0.0/4 -j RETURN
iptables -t nat -A CLASH_TPROXY_EXTERNAL -p tcp -j REDIRECT --to "$CLASH_REDIRECT_PORT"
#insert to output and prerouting table
iptables -t nat -I OUTPUT -p tcp -j CLASH_TPROXY_LOCAL
iptables -t nat -I PREROUTING -p tcp -j CLASH_TPROXY_EXTERNAL
#创建dns相关iptabels链
iptables -t nat -N CLASH_DNS_LOCAL
iptables -t nat -F CLASH_DNS_LOCAL
iptables -t nat -N CLASH_DNS_EXTERNAL
iptables -t nat -F CLASH_DNS_EXTERNAL
#iptables
iptables -t nat -A CLASH_DNS_LOCAL -m owner --uid-owner "$PROXY_BYPASS_USER" -j RETURN
iptables -t nat -A CLASH_DNS_LOCAL -p udp --dport 53 -j REDIRECT --to "$CLASH_DNS_PORT"
iptables -t nat -A CLASH_DNS_EXTERNAL -p udp --dport 53 -j REDIRECT --to "$CLASH_DNS_PORT"
iptables -t nat -I OUTPUT -p udp -j CLASH_DNS_LOCAL
iptables -t nat -I PREROUTING -p udp -j CLASH_DNS_EXTERNAL
#table mangle
iptables -t mangle -N CLASH_TPROXY_LOCAL
iptables -t mangle -F CLASH_TPROXY_LOCAL
iptables -t mangle -N CLASH_TPROXY_EXTERNAL
iptables -t mangle -F CLASH_TPROXY_EXTERNAL

iptables -t mangle -A CLASH_TPROXY_LOCAL -m owner --uid-owner "$PROXY_BYPASS_USER" -j RETURN
iptables -t mangle -A CLASH_TPROXY_LOCAL -p udp -j MARK --set-mark "$PROXY_FWMARK"

iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -d 240.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH_TPROXY_EXTERNAL -p udp -j TPROXY --on-port 7892 --tproxy-mark "$PROXY_FWMARK"/"$PROXY_FWMARK"

iptables -t mangle -I OUTPUT -p udp -j CLASH_TPROXY_LOCAL
iptables -t mangle -I PREROUTING -p udp -j CLASH_TPROXY_EXTERNAL
