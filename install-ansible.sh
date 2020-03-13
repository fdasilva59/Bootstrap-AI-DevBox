#!/bin/bash
set -e
clear

#--------------------------
#   Define Proxy settings
# (leave empty if no proxy)
#--------------------------
export PROXY_HOST="" # proxy.acme.com
export PROXY_PORT="" # 1234

#--------------------------
#   Preliminary checks
#--------------------------
if [ $EUID -ne 0 ]; then
   echo "This script should be run as root: " echo " #sudo -E ./Install-ansible.sh "
   exit 1
fi

#--------------------------
# Configure Proxy for apt
#--------------------------
if ! [ -z "$PROXY_HOST" ]; then
   export http_proxy=http://$PROXY_HOST:$PROXY_PORT
   export https_proxy=http://$PROXY_HOST:$PROXY_PORT
   printf "\nConfiguring the Proxy for apt\n"
   echo "Acquire::http::proxy \"http://$PROXY_HOST:$PROXY_PORT\";" > /etc/apt/apt.conf
   echo "Acquire::https::proxy \"http://$PROXY_HOST:$PROXY_PORT\";" >> /etc/apt/apt.conf
   echo "Acquire::ftp::proxy \"http://$PROXY_HOST:$PROXY_PORT\";" >> /etc/apt/apt.conf
else
   # Clean previous configuration if needed
   rm -f /etc/apt/apt.conf
fi

#----------------------------
# Preliminary System Update
#----------------------------
printf "\nPreliminary System Update\n"
apt-get update
apt-get install -y apt-transport-https software-properties-common python3-minimal python3-distutils python3-pip
ln -sfn /usr/bin/python3 /usr/bin/python
pip3 install ansible

#----------------------------
#   Install Ansible via apt
#----------------------------
printf "\nInstalling Ansible\n"
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y --fix-missing ansible

#--------------------------
# Continue the setup with
# with the Ansible Playbook
#--------------------------
printf "\nContinuing the DevBox setup with Ansible\n\n"
if [ -z "$PROXY_HOST" ]; then
   # No proxy
   sudo ansible-playbook -e "logname=$(logname)" Install-DevBox.yaml
else
   # Pass proxy settings to use to the Ansible Palybook
   sudo ansible-playbook -e "logname=$(logname)" -e "proxyhost=$PROXY_HOST" -e "proxyport=$PROXY_PORT" Install-DevBox.yaml
fi

