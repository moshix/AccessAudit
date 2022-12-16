#!/usr/bin/env bash
# Copyright 2022 by moshix
# AccessAudit installer
#  1. obtains an immudb container
#  2. create a database called 'audit' in it
#  3. adds to rsylog.conf a line that makes all logs be *also* logged in the audit database
#  4. provides query tool

# v0.1 Humbe beginnings

# This is the command we will use when we need superuser privileges. It is
# exported so scripts we call will also use this value. If you use "doas" you
# may change it here.


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
    echo "$logdate:$1" >> ./logs/zLinux_installer.log."$logextension"
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
}


#main here


