#!/bin/bash

usage() {
  
  cat<<EOF
Usage: ${0##*/} [-h | --help]
       ${0##*/}

This script clean any previous OneData deployment. Do not run this
script as root

Examples:
${0##*/}

    Clean up all configuration files, docker containers and uploaded
    files of any previous OneData deployment.

Options:
  -h, --help       display this help and exit
EOF
  
    exit 0

}

if [[ $1 == '-h' || $1 == '--help' ]]; then
    usage
fi

# Definisci il PREFIX
PREFIX=$(dirname $(dirname $(realpath $0)))
SCENARIOS_DIR=${PREFIX}/scenarios

CONFIG=~/.odlbtconfig

# Make sure you are not root
if [ "$(whoami)" == root ]; then
  echo "This script must NOT be run as root!" 1>&2
  exit 1
fi

# Run as sudo
echo "The cleaning procedure will need to run commands using sudo, in order to remove volumes created by docker. Please provide a password if needed."

echo "Removing configuration files..."
rm -f $CONFIG

echo "Removing provider and/or zone config dirs..."
cd ${SCENARIOS_DIR}
for d in scenario*; do
    sudo rm -rf ${d}/config_one*
    sudo rm -rf ${d}/oneprovider_data
done


echo "Removing Onedata containers..."
for c in onezone-2 trieste-2 heidelberg-2 \
         onezone-3 trieste-3 heidelberg-3; do
    sudo docker rm -vf ${c} 2> /dev/null
done

# Remove docker network for scenario 2
sudo docker network rm 20oneprovideronezone_scenario2 2> /dev/null

echo "This is the output of 'docker ps -a' command, please make sure that there are no onedata containers listed!"
sudo docker ps -a
