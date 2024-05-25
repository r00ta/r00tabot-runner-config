SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

lxc exec $CONTAINER_NAME --user 0 -- snap install jq --classic
lxc file push -r $SCRIPT_DIR/../tests $CONTAINER_NAME/home/ubuntu
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu/ -- chmod +x -R /home/ubuntu/tests
lxc exec $CONTAINER_NAME --user 0 --cwd /tmp/ -- sh -c "printf \"\$(maas apikey --username maas)\" > api-key-file"

lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "SUBNET_PREFIX=$SUBNET_PREFIX ./00-setup.sh" 
lxc start vm01-$SUBNET_PREFIX
lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "SUBNET_PREFIX=$SUBNET_PREFIX ./01-enlist.sh" 
lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "./02-commission.sh" 
lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "./03-deploy.sh" 
lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "./04-ssh.sh" 
lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "./05-release.sh" 

