# !/bin/bash

set -x

script_dir_path=$(dirname "${BASH_SOURCE[0]}")
. ${script_dir_path}/common.sh

echo "Configuring MAAS.."
sudo maas apikey --username maas > /tmp/api-key-file
lxc config trust add --name maas -q > /tmp/lxd-token

# MAAS might be slow at startup and return 502 here.
retry_until_success_contains "maas login admin http://localhost:5240/MAAS `cat /tmp/api-key-file`" "You are now logged in to the MAAS server at"

# Use local mirror if it's up and running
if ping -c 1 172.0.2.161 | grep -q "1 received"; then
  maas admin maas set-config name=enable_http_proxy value=True
  maas admin maas set-config name=http_proxy value=http://172.0.2.161:8000
  maas admin boot-resources stop-import
  if [ -d /snap/maas/current/usr/share/keyrings/ ]; then
    maas admin boot-sources create keyring_filename=/snap/maas/current/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg url=http://172.0.2.161/maas/images/ephemeral-v3/stable/
  else
    maas admin boot-sources create keyring_filename=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg url=http://172.0.2.161/maas/images/ephemeral-v3/stable/
  fi
  maas admin boot-source delete 1
  maas admin boot-source-selections create 2 os=ubuntu release=noble arches=amd64 subarches="*" labels="*" 
fi

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
sudo chown runner:runner /tmp/id_rsa /tmp/id_rsa.pub
sudo chmod 600 /tmp/id_rsa
sudo chmod 644 /tmp/id_rsa.pub
maas admin sshkeys create key="$(cat /tmp/id_rsa.pub)"
