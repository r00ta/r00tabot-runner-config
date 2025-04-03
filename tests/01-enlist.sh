#! /bin/bash

set -x

script_dir_path=$(dirname "${BASH_SOURCE[0]}")
. ${script_dir_path}/common.sh


echo "Logging in.."
maas login admin http://localhost:5240/MAAS `cat /tmp/api-key-file`

lxc start vm01
MACHINE_SYSTEM_ID=$(get_first_system_id_with_timeout)
echo "Machine has been enlisted!"

if wait_for_status "$MACHINE_SYSTEM_ID" "New"; then
    echo "Status is New!."
else
    echo "Timeout: Status is still not Ready or an error occurred."
    exit 1
fi

echo "System ID is $MACHINE_SYSTEM_ID"
maas admin machine update $MACHINE_SYSTEM_ID power_type=lxd power_parameters_power_address=10.0.1.1 power_parameters_instance_name=vm01 power_parameters_password=`cat /tmp/lxd-token`

echo "Machine power parameters updated. Enlistement completed."
echo "$MACHINE_SYSTEM_ID" > /tmp/vm_system_id
