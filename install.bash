#!/usr/bin/env bash
# Copyright 2022 by moshix
# AccessAudit installer
#  1. checks for all dependencies (curl, rsyslog)
#  2. adds to rsylog.conf a line that makes all logs be *also* logged in the audit database
#  3. provides query tool

# v0.1 Humble beginnings
# v0.2 Rough outline done. Refined visuals
# v0.3 Sanity checks
# v0.4 immudb Vault integration

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
        echo "${rev}${red}🤔 $SUDO did not set us to uid 0; you must run this script with a user that has $SUDO privileges.${reset}"
        exit 1
    fi
}

check_if_root () {
    # check if I am root and terminate if so
    if [[ $(id -u) -eq 0 ]]; then
        echo "${rev}${red}🤔 You are root. You must run this installer as a regular user. Terminating...${reset}"
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
        echo "${rev}${red}😬 MacOS detected. Sorry, MacOS is not yet supported.${reset}"
        exit 1
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "${rev}${red}😬 Cygwin detected. Sorry, Cygwin is not supported.${reset}"
        exit 1
    elif [[ "$OSTYPE" == "win32" ]]; then
        echo "${rev}${red}😬 Windows detected. Sorry, Windows is not supported.${reset}"
        exit 1
    else
        echo "${rev}${red}😬 Unrecognized operating system. Exiting now.${reset}"
        exit 1
    fi
    os=`awk -F= '/^NAME/{print $2}' /etc/os-release` # OS type is in $os !!

}

exit_with_error () {
msg=$1
echo "${red}$msg${reset}"
}

exit_script () {
 echo "${yellow}Bye${reset}"
 exit 1
}

#main here
mkdir -p ./logs # ensuring logs folder
logit "user invoking install script: $(whoami)"
set_colors    # to get terminal coloring settings
check_if_root # we dont' want to be root 
test_sudo     # check if we have sudo
check_os      # find out what OS we are running on
# are we running from the AccessAudit directory (instead of higher or lower directory?)
cpwd=`pwd`
curdir=`basename "$cpwd"`


if [[ "$curdir"  != "AccessAudit" ]]; then
	echo "${rev}${red}😬 This script needs to be executed from inside the AccessAudit directory. Please retry. ${red}"
	exit 1
fi


mkdir -p logs/


echo " "

echo "${yellow}Welcome to AccessAudit Installer $version"
echo "${yellow}===================================${reset}"
echo "${yellow} "
echo "Your operating system is: $os"
echo " "
echo "This installer will do the following: "
echo " 1. Check for dependencies"
echo " 2. Add to rsyslog.conf an additional logging of all logins to the immudb Vault"
echo " IMPORTANT: AccessAudit will use default collection and default ledger"

echo "${reset} "
    read -p "${white}Continue with installation (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit_script
echo "${reset}"


read -p "Enter immudb Vault Write API Key: " vaultKey

echo "Testing your key with simple request..."

vault_status_code=$(curl -w "%{http_code}" -X POST https://vault.immudb.io/ics/api/v1/ledger/default/collection/default/documents/count -H "X-API-KEY: $vaultKey" -d '{}' -H 'Content-Type: application/json' --silent --output /dev/null)
echo "Vault status code was $vault_status_code"
if [ "$vault_status_code" = "200" ]; then
    echo "API key works. Proceed with installation"
else   
    echo "Standard API key check failed. Aborting installation."
    exit 1
fi

# check if we have wget or curl installed
foundtool="true"
type curl &> /dev/null || foundtool="false"
if [[ $foundtool != "true" ]]; then
    echo "${rev}${red}😬 curl is not available! Please install one now and restart the install script. ${reset}"
    exit 1
fi

# user said it's ok to proceed with container installation
$SUDO sh ./scripts/configrsyslog $vaultKey || exit_with_error "Configuration of rsyslog failed. Pls check the logs"          # configure rsyslog.conf
$SUDO sh ./scripts/restartlog                    || exit_with_error "Could not restart rsyslog. Pls check the logs"                 # restart log

echo "${yellow}Installation finished! Congrats! 😀 ${reset}"
echo " "
echo "${yellow}Now check your immudb Vault dashboard! https://vault.immudb.io/     ${reset}"

exit 0

