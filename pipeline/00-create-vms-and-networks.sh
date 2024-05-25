printf "Setting up network" 


lxc network create $CONTAINER_NAME --type=bridge ipv4.address=$SUBNET_PREFIX.0.1.1/24 ipv4.dhcp=false ipv4.nat=true ipv6.dhcp=false 

lxc init --empty --vm vm01-$SUBNET_PREFIX -c security.secureboot=false -c volatile.eth0.hwaddr=$MAC_1 -c limits.memory=4GiB
lxc config device add vm01-$SUBNET_PREFIX eth0 nic network=$CONTAINER_NAME name=eth0  boot.priority=10

lxc init --empty --vm vm02-$SUBNET_PREFIX -c security.secureboot=false -c volatile.eth0.hwaddr=$MAC_2 -c limits.memory=4GiB
lxc config device add vm02-$SUBNET_PREFIX eth0 nic network=$CONTAINER_NAME name=eth0  boot.priority=10

