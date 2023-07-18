#!/usr/bin/env bash

# Copyright 2022 by moshix
# cleanup script after successful install
# removes the following:
#   install/ directory
#   logs/ files relating to installation

# v0.3 clean up
# v0.4 no sudo required
# v0.5 consistent log file name for all messages during one run
# v0.6 Check if script is being executed from correct directory

source ./Version

logextension=`date "+%F-%T"`
logit () {
    # log to file all messages
    logdate=`date "+%F-%T"`
    echo "$logdate:$1" >> ./logs/cleanup.log.$logextension
}

set_colors() {
    red=`tput setaf 1`
    green=`tput setaf 2`
    yellow=`tput setaf 3`
    blue=`tput setaf 4`
    magenta=`tput setaf 5`
    cyan=`tput setaf 6`
    white=`tput setaf 7`
    blink=`tput blink`
    rev=`tput rev`
    reset=`tput sgr0`
}

clean_stuff () {
    rm -fr install/
    rm -fr logs/*
    rm -f immuclient*
    sudo rm -rf /etc/accessaudit/
    sudo rm -f /etc/rsyslog.d/99-immudb-vault.conf


    echo "${yellow}All clean now! Goodbye. ${reset}"
    exit 0
}

# main starts here

set_colors

# are we running from the zlinux directory (instead of higher or lower directory?)
cpwd=`pwd`
curdir=`basename "$cpwd"`

if [[ "$curdir"  != "AccessAudit" ]]; then
  echo "${rev}${red}😬This script needs to be executed from inside the AccessAudit directory. Please retry. ${red}"
  exit 1
fi


echo "${yellow}AccessAudit (c) 2022 v$version${reset}"
echo "${yellow}Cleanup Procedure Version${reset}"
echo  " "

sleep 1


while true; do
    read -p "${white} Do you want to clean up your directory after a successful install? (y/n) ${reset}" runvar

    case "$runvar" in
    [Yy]*)
        echo "${yellow}Roger, cleaning it all up now... ${reset}"
        clean_stuff
        echo "${yellow}Restart rsyslog... ${reset}"
        sudo systemctl restart rsyslog
        ;;
    [Nn]*)
        echo "${yellow}Ok, terminating now....  ${reset}"
        exit
        ;;
    *)
        echo "${red}Unrecognized selection: $runvar. y or n  ${reset}" ;;
    esac
done
