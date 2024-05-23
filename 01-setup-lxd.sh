# !/bin/bash

echo "Installing LXD.."
sudo snap install --channel=latest/stable lxd

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
    size: 150GiB
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

lxc config set core.trust_password fuffapassword
