lxc network create maas-test --type=bridge ipv4.address=12.0.1.1/24 ipv4.dhcp=false ipv6.address=none

lxc init --empty --vm vm01 -c security.secureboot=false -c volatile.eth0.hwaddr=00:16:3e:4a:03:01 -c limits.memory=4GiB
lxc config device add vm01 eth0 nic network=maas-test name=eth0  boot.priority=10

lxc init --empty --vm vm02 -c security.secureboot=false -c volatile.eth0.hwaddr=00:16:3e:4a:03:02 -c limits.memory=4GiB
lxc config device add vm02 eth0 nic network=maas-test name=eth0  boot.priority=10

