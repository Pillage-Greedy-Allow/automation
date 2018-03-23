#! /bin/bash
# Automates initial hardening of a server

# Checks to see if run as root
if [ "$EUID" -ne 0 ]; then
  echo 'Please run as root!'
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
echo -e "\nDo you want to run the kernel hardening script\?"
select choice in "Yes" "No" "Exit setup"; do
  case $choice in
    "Yes" ) chmod 700 ./harden_kernel.sh; ./harden_kernel.sh; break;;
    "No" ) break;;
    "Exit setup" ) exit;;
  esac
done

# Cronjobs
cronFunc() {
  for user in $(cut -f1 -d: /etc/passwd); do
    echo -e "\n$user" >> cronHistory.txt
    crontab -u $user -l >> cronHistory.txt
    crontab -u $user -r
  done
  echo 'cron jobs printed to cronHistory.txt'
}

echo 'Do you want to print and delete cronjobs for all users?'
select choice in "Yes" "No" "Exit setup"; do
  case $choice in
    "Yes" ) cronFunc; break;;
    "No" ) break;;
    "Exit setup" ) exit;;
  esac
done


## This could potential mess with the scoring engine or with some distro's of linux
# prevent ip spoofing host.conf -> host.conf.old
# mv /etc/host.conf /etc/host.conf.old
# cat << EOF > /etc/host.conf
# order bind,hosts
# nospoof on
# EOF
