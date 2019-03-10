#!/bin/bash

# Remove old output files.
sudo rm Date-*

# Create new output filename.
currDate=$(date)
filename="Date"
for c in ${currDate}; do
  filename="${filename}-${c}"
done

# Put output in a new file.
yum check-update > ./$filename

# Run system update.
yum update

# Configure network interface.
ifup enp0s8
dhclient

# Redirect stdout and stderr to /var/log/system-bootstrap.log
set -o errexit
readonly LOG_FILE="/var/log/system-bootstrap.log"
sudo touch $LOG_FILE
exec 1>$LOG_FILE
exec 2>&1

# Change SELINUX to disabled
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# Config to log in with RSA key.
(umask 077 && test -d ~/.ssh || mkdir ~/.ssh)
(umask 077 && touch ~/.ssh/authorized_keys)
cat RSA-key.txt > ~/.ssh/authorized_keys
