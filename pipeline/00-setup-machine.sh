printf "Installing dependencies.."
sudo apt-get update
sudo apt-get install make
sudo snap install jq --classic
sudo snap install snapcraft --classic
sudo snap install jq --classic


echo "Installing LXD.."
sudo snap install --channel=latest/stable lxd
lxc config set core.proxy_http="http://172.0.2.17:8000/"

echo "Configuring LXD.."
cat <<EOF | sudo lxd init --preseed
config:
  core.https_address: '[::]:8443'
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config:
    size: 30GiB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
EOF

printf "Setting up network"

lxc network create net-test --type=bridge ipv4.address=10.0.1.1/24 ipv4.dhcp=false ipv4.nat=true ipv6.dhcp=false ipv6.address=none

lxc init --empty --vm vm01 -c security.secureboot=false -c volatile.eth0.hwaddr=00:00:00:00:00:01 -c limits.memory=4GiB
lxc config device add vm01 eth0 nic network=net-test name=eth0  boot.priority=10

lxc init --empty --vm vm02 -c security.secureboot=false -c volatile.eth0.hwaddr=00:00:00:00:00:02 -c limits.memory=4GiB
lxc config device add vm02 eth0 nic network=net-test name=eth0  boot.priority=10


