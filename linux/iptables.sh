#! /bin/bash
# This script adds rules for a generic (but strong) firewall using iptables.

# Flush the tables and delete existing chains for IPv4 and IPv6.
iptables -F
iptables -X
ip6tables -F
ip6tables -X

# Create new chains:
#     The TCP, UDP, ICMP will handle the related protocol traffic.
#     The BLOCK chain will add/update offenders to a blacklist.
iptables -N TCP
iptables -N UDP
iptables -N ICMP
iptables -N BLOCK

# Accept 127.0.0.0/8 traffic on the loopback interface.
iptables -A INPUT -i lo -j ACCEPT

# Check if the source IP has been in the blacklist for the last 180 seconds (3 minutes).
# If so, drop the packet. If they've done their time, remove them from the blacklist.
iptables -A INPUT -m recent --name BLACKLIST --rcheck --seconds 180 -j DROP
iptables -A INPUT -m recent --name BLACKLIST --rsource --remove

# Drop invalid packets (protects against fragmented packets and MOST scans).
# Accept connections already related and established.
iptables -A INPUT -m conntrack --ctstate INVALID -j LOG --log-prefix '** POTENTIAL SCAN ** '
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Send new TCP traffic starting with a SYN to the TCP chain, else drop.
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j LOG --log-prefix '** POTENTIAL TCP SCAN ** '
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Send new UDP traffic to the UDP chain.
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP

# Send new ICMP traffic to the ICMP chain.
iptables -A INPUT -p icmp -j ICMP

# TCP rules. Protects from SYN scans and floods.
##### THIS is where you can add additional TCP rules for specific ips/ports needed (at top). ######
iptables -A TCP -p tcp --dport 22 -j LOG --log-prefix '** SSH ** '
iptables -A TCP -p tcp --dport 22 -j ACCEPT
iptables -A TCP -p tcp -m multiport --dports 23,79 --tcp-flags ALL SYN -j BLOCK
iptables -A TCP -m limit --limit 2/s --limit-burst 6 -j RETURN
iptables -A TCP -j LOG --log-prefix '** TCP BLOCKED ** '
iptables -A TCP -j BLOCK

# UDP rules. Protects from packets with no content and floods.
##### THIS is where you can add additional UDP rules for specific ips/ports needed (at top). ######
iptables -A UDP -p udp -m length --length 1:28 -j LOG --log-prefix '** POTENTIAL UDP FLOOD ** '
iptables -A UDP -p udp -m length --length 1:28 -j DROP
iptables -A UDP -m limit --limit 10/s --limit-burst 20 -j RETURN
iptables -A UDP -j LOG --log-prefix '** UDP BLOCKED ** '
iptables -A UDP -j BLOCK

# ICMP rules. Accepts echo requests and protects from floods.
iptables -A ICMP -p icmp -j LOG --log-prefix '** PING ** ' # can be helpful to find scoring engine
iptables -A ICMP -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
iptables -A ICMP -m limit --limit 4/s --limit-burst 8 -j RETURN
iptables -A ICMP -j LOG --log-prefix '** PING BLOCKED ** '
iptables -A ICMP -j BLOCK

# Update the timestamp on the offending packet, if offender already exists in the blacklist.
# Add them to the blacklist if they're not already in the blacklist.
iptables -A BLOCK -j LOG --log-prefix '** BLACKLIST ** ' # helpful for debugging and finding attackers
iptables -A BLOCK -m recent --update --seconds 180 --name BLACKLIST --rsource -j DROP
iptables -A BLOCK -m recent --set --name BLACKLIST --rsource -j DROP

# Set the default policy for IPv4 and IPv6.
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
ip6tables -P OUTPUT DROP
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
