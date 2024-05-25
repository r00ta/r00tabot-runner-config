lxc delete -f $CONTAINER_NAME
lxc delete -f vm01-$SUBNET_PREFIX
lxc delete -f vm02-$SUBNET_PREFIX
lxc network delete $CONTAINER_NAME
