# !/bin/bash

set -x

retry_until_success() {
  local maas_command="$1"
  local status_to_check="$2"
  local max_wait_time=600
  local sleep_interval=10
  local elapsed_time=0

  while [ $elapsed_time -lt $max_wait_time ]; do
    output=$(eval "$maas_command")
    if [ "$output" = "$status_to_check" ]; then
      echo "Success!"
      return 0  # Success
    fi
    sleep $sleep_interval
    elapsed_time=$((elapsed_time + sleep_interval))
  done

  echo "Timeout reached. Importing may not be complete."
  return 1  # Timeout
}

echo "Configuring MAAS.."
sudo maas apikey --username maas > /tmp/api-key-file
lxc config trust add --name maas > /tmp/lxd-token

# MAAS might be slow at startup and return 502 here.
retry_until_success "maas login admin http://localhost:5240/MAAS `cat /tmp/api-key-file`"
# maas admin maas set-config name=http_proxy value=http://172.0.2.15:3129/
maas admin boot-resources import
retry_until_success "maas admin boot-resources is-importing" "false"
echo "Extracting primary rack.."
export PRIMARY_RACK=$(maas admin rack-controllers read | jq -r ".[] | .system_id")
maas admin rack-controller import-boot-images $PRIMARY_RACK
retry_until_success "maas admin rack-controller list-boot-images $PRIMARY_RACK | jq -r .status" "synced"

export SUBNET=10.0.1.0/24
maas admin subnets create cidr=$SUBNET name=test-subnet
echo "Extracting fabric id.."
export FABRIC_ID=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.fabric_id")
echo "Extracting vlan tag id.."
export VLAN_TAG=$(maas admin subnet read "$SUBNET" | jq -r ".vlan.vid")
echo "Updating subnet.."
maas admin subnet update $SUBNET gateway_ip=10.0.1.1
maas admin ipranges create type=dynamic start_ip=10.0.1.200 end_ip=10.0.1.254
maas admin vlan update $FABRIC_ID $VLAN_TAG dhcp_on=True primary_rack=$PRIMARY_RACK
maas admin maas set-config name=upstream_dns value=8.8.8.8

echo "Generaing ssh keys.."
ssh-keygen -q -t rsa -N "" -f "/tmp/id_rsa"
sudo chown ubuntu:ubuntu /tmp/id_rsa /tmp/id_rsa.pub
sudo chmod 600 /tmp/id_rsa
sudo chmod 644 /tmp/id_rsa.pub
maas admin sshkeys create key="$(cat /tmp/id_rsa.pub)"