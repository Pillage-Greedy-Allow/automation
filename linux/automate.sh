#! /bin/bash
# Automates initial hardening of a server

# Checks to see if run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root!"
  exit
fi

# iptables
echo -e "\nHave you configured iptables.sh?"
select choice in "Yes, run iptables setup" "No" "Skip iptables setup"; do
  case $choice in
    "Yes, run iptables setup" ) chmod 700 ./iptables.sh; ./iptables.sh; break;;
    "No" ) echo "setup iptables"; exit;;
    "Skip iptables setup" ) break;;
  esac
done

# harden kernel
chmod 700 ./harden_kernel.sh
./harden_kernel.sh

# conrjobs
for user in $(cut -f1 -d: /etc/passwd); do
  echo -e "\n$user" >> cronHistory.txt
  crontab -u $user -l >> cronHistory.txt
  crontab -u $user -r
done

# prevent ip spoofing host.conf -> host.conf.old
mv /etc/host.conf /etc/host.conf.old
cat << EOF > /etc/host.conf
order bind,hosts
nospoof on
EOF
