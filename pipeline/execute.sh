#!/bin/bash

# ENV VARIABLES REQUIRED:
#
# SUBNET_PREFIX: an integer between 1 and 253 that will be used to create a bridged network with such prefix and identify the runners
# TYPE: deb or snap.



SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. $SCRIPT_DIR/../utils/functions.sh

# Initialize a variable to hold the value of --maas_dir
maas_dir=""

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --maas_dir)
            maas_dir="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if the --maas_dir argument was provided
if [ -z "$maas_dir" ]; then
    echo "Usage: $0 --maas_dir <directory>"
    exit 1
fi

export MAC_1=$(get_mac)
export MAC_2=$(get_mac)
export MAAS_DIR="$maas_dir"
export CONTAINER_NAME="maas-tester-$SUBNET_PREFIX"


$SCRIPT_DIR/00-create-vms-and-networks.sh  
if [ "$TYPE" == "deb" ]; then
    $SCRIPT_DIR/01-deb-create.sh
else
    $SCRIPT_DIR/01-snap-create.sh
fi
$SCRIPT_DIR/02-start-tests.sh
