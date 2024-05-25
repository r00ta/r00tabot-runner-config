lxc launch ubuntu:22.04 maas-deb-builder
lxc file push -r maas maas-deb-builder/home/ubuntu
lxc exec maas-deb-builder --cwd /home/ubuntu/maas --user 0 -- apt-get update 
lxc exec maas-deb-builder --cwd /home/ubuntu/maas --user 1000 -- git submodule update --init --recursive
lxc exec maas-deb-builder --cwd /home/ubuntu --user 0 -- apt-get install make
lxc exec maas-deb-builder --cwd /home/ubuntu/maas --user 0 -- make install-dependencies
lxc exec maas-deb-builder --cwd /home/ubuntu/maas --user 1000 -- make package

lxc file pull -r maas-deb-builder/home/ubuntu/build-area/*.deb .
lxc delete -f maas-deb-builder

lxc launch ubuntu:22.04 maas-tester
lxc config device add maas-tester eth1 nic name=eth1 nictype=bridged parent=maas-test
lxc file push -r build-area maas-tester/home/ubuntu
lxc exec maas-tester --user 0 --  add-apt-repository -y ppa:maas-committers/latest-deps
lxc exec maas-tester --user 0 -- apt-get update
lxc exec maas-tester --cwd /home/ubuntu/build-area --user 0 -- bash -c "apt install -y ./*.deb"

