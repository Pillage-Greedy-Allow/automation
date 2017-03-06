#! /bin/bash
# This script hardens the linux kernel.
# It appends to the /etc/sysctl.conf file and then reloads the new configurations.
# MUST BE RUN AS ROOT!

cat << 'EOF' >> /etc/sysctl.conf
net.ipv4.ip_forward=0
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_synack_retries=2
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
kernel.sysrq=0
kernel.exec-shield=1
kernel.randomize_va_space=1
kernel.pid_max=65535
EOF
sysctl -p
