printf "Setting up network" 

lxc network create net-test --type=bridge ipv4.address=10.0.1.1/24 ipv4.dhcp=false ipv4.nat=true ipv6.dhcp=false ipv6.address=none

lxc init --empty --vm vm01 -c security.secureboot=false -c volatile.eth0.hwaddr=00:00:00:00:00:01 -c limits.memory=4GiB
lxc config device add vm01 eth0 nic network=net-test name=eth0  boot.priority=10

lxc init --empty --vm vm02 -c security.secureboot=false -c volatile.eth0.hwaddr=00:00:00:00:00:02 -c limits.memory=4GiB
lxc config device add vm02 eth0 nic network=net-test name=eth0  boot.priority=10

