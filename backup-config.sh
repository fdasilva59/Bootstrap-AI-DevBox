#!/bin/bash

#--------------------------------------
# This script is intended to backup
# the current shell and some of the
# development tools configuration in
# order to later restore them while
# bootstrapping a new AI-DevBox with
# the associated Ansible Playbook.
#
# usage: ./backup-configuration.sh
#
#--------------------------------------

set -e
clear
cd /home/$(logname)

# List of Target files to backup
# You may want customize the list
CFG_LIST=".gitconfig .git-credentials .profile .bashrc .ngc/config .docker/config.json .config/conky/ /etc/X11/xorg.conf"
ST3_LIST=".config/sublime-text-3/Installed* .config/sublime-text-3/Packages/ .config/sublime-text-3/Local/License.sublime_license"
VSC_LIST=".vscode/ .config/Code/User/"
PYC_LIST=".local/share/applications/jetbrains-pycharm.desktop .local/share/JetBrains/ .PyCharm2019.3/config/ .PyCharm2019.3/system .java/userPrefs/ /usr/local/bin/charm"
PIC_LIST="Pictures/"


# Print Recap of target files for backup
printf "You are about to backup the following files into $(pwd)/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz \n\n"
declare -a arr=($CFG_LIST $ST3_LIST $VSC_LIST $PYC_LIST $PIC_LIST $TEMP)
for e in "${arr[@]}"
do
    echo "$e"
done

# Warn for overwriting a previous backup archive.
if [ -f $(pwd)/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz ] ; then
    printf "\nWARNING: a previous version of $(pwd)/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz will be overwritten."
fi

# Ask confirmation & proceed
printf "\nReady to go [N/y]"
read ans
if [[ "$ans" == [yY] ]]; then
    tar  cvf ./Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz --ignore-failed-read $CFG_LIST $ST3_LIST $VSC_LIST $PYC_LIST $PIC_LIST  1 > backup-config.sh.log  2>&1
    printf "\n\nThe backup is available here: $(pwd)/Bootstrap-AI-DevBox/PrivateConfiguration.tar.gz:\n"
    printf "\n\n ~ Backup of Configuration completed ~ \n\n"
fi
