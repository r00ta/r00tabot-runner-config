lxc launch ubuntu:22.04 $CONTAINER_NAME
lxc file push -r maas $CONTAINER_NAME/home/ubuntu
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 0 -- apt-get update 
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 1000 -- git submodule update --init --recursive
lxc exec $CONTAINER_NAME --cwd /home/ubuntu --user 0 -- apt-get install make
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 0 -- make install-dependencies
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 1000 -- make package

lxc file pull -r $CONTAINER_NAME/home/ubuntu/build-area/*.deb .
lxc delete -f $CONTAINER_NAME

lxc launch ubuntu:22.04 $CONTAINER_NAME
lxc config device add $CONTAINER_NAME eth1 nic name=eth1 nictype=bridged parent=$CONTAINER_NAME
lxc file push -r build-area $CONTAINER_NAME/home/ubuntu
lxc exec $CONTAINER_NAME --user 0 --  add-apt-repository -y ppa:maas-committers/latest-deps
lxc exec $CONTAINER_NAME --user 0 -- apt-get update
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/build-area --user 0 -- bash -c "apt install -y ./*.deb"

