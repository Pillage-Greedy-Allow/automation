#! /bin/bash

# This script finds and prompts to change the password for all users, except root.
# If you want to skip a user, then input 0 as the password.
# Then it'll prompt if you want to lock the account.
# It'll automatically lock all user accounts without a password.
# MUST BE RUN AS ROOT!

echo -e "\n\t To skip a user set the password to 0."

# Get a list of user accounts WITH a password set (users_wp)
# and a list of users WITHOUT a password set (users_np). 
# NOTE: Does not include system accounts.
users_wp=()
users_np=()
for user in $(cut -d ":" -f1 /etc/passwd); do
   users_wp+=($(sudo passwd -S $user | awk '$2 == "PS" || $2 == "P" {print $1}'))
   users_np+=($(sudo passwd -S $user | awk '$2 == "NP" {print $1}'))
done

# Prompt to change the password for all user accounts, except root.
for user in ${users_wp[*]} ${users_np[*]}; do
   if [ $user != "root" ]; then
       read -p "Type new password for $user: " pass
       if [ "$pass" == "0" ]; then
           echo "$user has been skipped."
       else
           echo "$user:$pass" | chpasswd
           echo "Password changed!"
           read -p "Lock account [y/n]? " lock
           if [ "$lock" == "y" ]; then
               passwd -l $user
               # chage -E 0 $user
               echo "$user has been locked!"
           fi
       fi
   fi
done

# Automatically lock user accounts without a password.
for user in ${users_np[*]}; do
    if [ $user != "root" ]; then
        echo "$user doesn't have a password!"
        echo -n "Locking account... "
        passwd -l $user
        #chage -E 0 $user
        echo "done!"
    fi
done
unset user users_wp users_np lock pass
