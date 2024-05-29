set -x 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

lxc launch ubuntu:22.04 $CONTAINER_NAME

# wait for container
sleep 10 

lxc file push -r $MAAS_DIR $CONTAINER_NAME/home/ubuntu/ > /dev/null
lxc exec $CONTAINER_NAME --cwd /home/ubuntu --user 0 -- chown -R ubuntu:ubuntu maas

echo "Updating.."
lxc exec $CONTAINER_NAME --user 0 -- sh -c "echo 'Acquire::http::Proxy \"http://172.0.2.15:3129\";' | sudo tee /etc/apt/apt.conf.d/99proxy"
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/ --user 0 -- apt-get update 
lxc exec $CONTAINER_NAME --user 1000 -- git config --global --add safe.directory /home/ubuntu/maas

echo "Fetching submodules.."
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 1000 -- git submodule update --init --recursive

echo "Installing dependencies.."
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 0 -- apt-get -y install make > /dev/null
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 0 -- make install-dependencies > /dev/null

echo "Making debs.."
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/maas --user 1000 -- make package > /dev/null

echo "Downloading artifacts.."
TMPDIR=$(mktemp -d)
lxc file pull -r $CONTAINER_NAME/home/ubuntu/build-area/ $TMPDIR > /dev/null
lxc delete -f $CONTAINER_NAME

sleep 5

echo "Creating test container.."

lxc launch ubuntu:22.04 $CONTAINER_NAME
sleep 5
lxc config device add $CONTAINER_NAME eth1 nic name=eth1 nictype=bridged parent=$CONTAINER_NAME
sleep 10
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

echo "Uploading artifacts.."
lxc file push -r $TMPDIR/build-area $CONTAINER_NAME/home/ubuntu > /dev/null
lxc exec $CONTAINER_NAME --cwd /home/ubuntu --user 0 -- chown -R ubuntu:ubuntu build-area

rm -rf $TMPDIR

echo "Installing MAAS.."
lxc exec $CONTAINER_NAME --user 0 --  add-apt-repository -y ppa:maas-committers/latest-deps
lxc exec $CONTAINER_NAME --user 0 -- apt-get update
lxc exec $CONTAINER_NAME --cwd /home/ubuntu/build-area --user 0 -- bash -c "apt install -y ./*.deb"
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu -- maas createadmin --username maas --password maas --email maas 

