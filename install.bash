#!/usr/bin/env bash
# Copyright 2022 by moshix
# AccessAudit installer
#  1. obtains an immudb container
#  2. create a database called 'audit' in it
#  3. adds to rsylog.conf a line that makes all logs be *also* logged in the audit database
#  4. provides query tool

# v0.1 Humble beginnings

# This is the command we will use when we need superuser privileges. It is
# exported so scripts we call will also use this value. If you use "doas" you
# may change it here.

source ./Version

SUDO="sudo"
export SUDO

set_colors() {
    red=`tput setaf 1`
    green=`tput setaf 2`
    yellow=`tput setaf 3`
    blue=`tput setaf 4`
    magenta=`tput setaf 5`
    cyan=`tput setaf 6`
    white=`tput setaf 7`
    bold=`tput bold`
    uline=`tput smul`
    blink=`tput blink`
    rev=`tput rev`
    reset=`tput sgr0`
}

test_sudo () {
#    echo "${yellow}Testing if '$SUDO' command works ${reset}"
    if [[ $($SUDO id -u) -ne 0 ]]; then
        echo "${rev}${red}$SUDO did not set us to uid 0; you must run this script with a user that has $SUDO privileges.${reset}"
        exit 1
    fi
}

check_if_root () {
    # check if I am root and terminate if so
    if [[ $(id -u) -eq 0 ]]; then
        echo "${rev}${red}You are root. You must run this installer as a regular user. Terminating...${reset}"
        exit 1
    fi
}

logextension=`date "+%F-%T"`
logit () {
    # log to file all messages
    logdate=`date "+%F-%T"`
    echo "$logdate:$1" >> ./logs/AccessAudit_installer.log."$logextension"
}


check_os () {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "${rev}${red}MacOS detected. Sorry, MacOS is not yet supported.${reset}"
        exit 1
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "${rev}${red}Cygwin detected. Sorry, Cygwin is not supported.${reset}"
        exit 1
    elif [[ "$OSTYPE" == "win32" ]]; then
        echo "${rev}${red}Windows detected. Sorry, Windows is not supported.${reset}"
        exit 1
    else
        echo "${rev}${red}Unrecognized operating system. Exiting now.${reset}"
        exit 1
    fi
    os=`awk -F= '/^NAME/{print $2}' /etc/os-release` # OS type is in $os !!

}


#main here
set_colors # to get terminal coloring settings

# are we running from the AccessAudit directory (instead of higher or lower directory?)
cpwd=`pwd`
curdir=`basename "$cpwd"`

if [[ "$curdir"  != "AccessAudit" ]]; then
	echo "${rev}${red}This script needs to be executed from inside the AccessAudit directory. Please retry. ${red}"
	exit 1
fi


mkdir -p logs/

check_if_root # cannot be root
logit "user invoking install script: $(whoami)"

check_os  # $os will contain operating system (centos or ubuntu etc.)
echo " "

echo "${yellow}Welcome to AccessAudit Installer $version"
echo "${yellow}===================================${reset}"
echo "${yellow} "
echo "Your operating system is: $os"
echo " "
echo "This installer will do the following: "
echo " 1. Obtain the latest immudb container"
echo " 2. Install it and create an audit database in it"
echo " 3. Add to rsyslog.conf an additional logging of all logins to the audit database"
echo " 4. Install a tool in /usr/local/bin which allows you to query the audit database"
echo "${reset} "
    read -p "${white}Continue with installation (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || echo "${yellow}Bye${reset}"; exit 1
echo "${reset}"

# check if we have wget or curl installed
foundtool="true"
type wget &> /dev/null || type curl &> /dev/null || foundtool="false"
if [[ $foundtool != "true" ]]; then
    echo "${rev}${red}Neither curl nor wget are available! Please install one now and restart the install script. ${reset}"
    exit 1
fi

# user said it's ok to download. get iso
./scripts/getimmudb || exit 1
