# Start the container first because it might take some seconds to be active. In the meantime we build the snap


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

lxc launch ubuntu:24.04 $CONTAINER_NAME
lxc config device add $CONTAINER_NAME eth1 nic name=eth1 nictype=bridged parent=$CONTAINER_NAME

git -C $MAAS_DIR submodule update --init --recursive
(cd $MAAS_DIR && make snap-tree)

lxc exec $CONTAINER_NAME --user 0 -- sh -c "echo 'Acquire::http::Proxy \"http://172.0.2.15:3129\";' | sudo tee /etc/apt/apt.conf.d/99proxy"

lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu/ -- sh -c "printf \"
network:
    version: 2
    ethernets:
        eth1:
            addresses:
                - $SUBNET_PREFIX.0.1.2/24
\" >> /etc/netplan/99-static-eth1.yaml"
lxc exec $CONTAINER_NAME --user 0 -- netplan apply 

lxc file push $MAAS_DIR/dev-snap/maas.snap $CONTAINER_NAME/home/ubuntu/
lxc exec $CONTAINER_NAME --cwd /home/ubuntu --user 0 -- chown ubuntu:ubuntu maas.snap
lxc file push --uid 1000 $MAAS_DIR/utilities/connect-snap-interfaces $CONTAINER_NAME/home/ubuntu/
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu/ -- snap install --dangerous maas.snap
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu/ -- ./connect-snap-interfaces

lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- apt-get update
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- apt-get install postgresql -y 
lxc exec $CONTAINER_NAME --user 0 -- sudo -u postgres psql -c "CREATE USER \"maasdb\" WITH ENCRYPTED PASSWORD 'maasdb'"
lxc exec $CONTAINER_NAME --user 0 -- sudo -u postgres createdb -O "maasdb" "maasdb" 
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- sh -c "echo 'host    maasdb   maasdb    0/0     md5' >> /etc/postgresql/16/main/pg_hba.conf"
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- systemctl restart postgresql 
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- sh -c "maas init region+rack --database-uri 'postgres://maasdb:maasdb@localhost/maasdb'  --maas-url http://$SUBNET_PREFIX.0.1.2:5240/MAAS"
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- maas createadmin --username maas --password maas --email maas 
