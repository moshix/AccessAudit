#!/usr/bin/env bash
# Copyright 2022 by moshix
# AccessAudit installer
#  1. obtains an immudb container
#  2. create a database called 'audit' in it
#  3. adds to rsylog.conf a line that makes all logs be *also* logged in the audit database
#  4. provides query tool

# v0.1 Humble beginnings
# v0.2 Rough outline done. Refined visuals
# v0.3 Sanity checks

# This is the command we will use when we need superuser privileges. It is
# exported so scripts we call will also use this value. If you use "doas" you
# may change it here.

source ./Version
logextension
cpwd=$(pwd)
curdir=$(basename "$cpwd")

if [[ "$curdir"  != "AccessAudit" ]]; then
	echo "${rev}${red}😬 This script needs to be executed from inside the AccessAudit directory. Please retry. ${red}"
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
    echo "${rev}${red}😬 Neither curl nor wget are available! Please install one now and restart the install script. ${reset}"
    exit 1
fi

# user said it's ok to proceed with container installation
./scripts/getimmudb     || exit 1   # install immudb container and start immudb
./scripts/startimmudb   || exit 1   # make sure immudb is running
./scripts/createdb      || exit 1   # create "audit" database in immudb
./scripts/configrsyslog || exit 1   # configure rsyslog.conf
./scripts/restartlog    || exit 1   # restart log
./scripts/testAA        || exit 1   # test the whole thing
./scripts/showquery     || exit 1   # show example of query

echo "${yellow}Installation finished! Congrats! 😀 ${reset}"

exit 0

