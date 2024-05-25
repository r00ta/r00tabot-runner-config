#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. $SCRIPT_DIR/../utils/functions.sh

maas_dir=""
random=""

# Parse the command line arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        --maas_dir)
            maas_dir="$2"
            shift # past argument
            shift # past value
            ;;
        --random)
            random="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

export SUBNET_PREFIX="$random"
export MAC_1=$(get_mac)
export MAC_2=$(get_mac)
export MAAS_DIR="$maas_dir"
export CONTAINER_NAME="maas-tester-$SUBNET_PREFIX"


$SCRIPT_DIR/00-create-vms-and-networks.sh  
$SCRIPT_DIR/01-snap-create.sh
$SCRIPT_DIR/02-start-tests.sh
