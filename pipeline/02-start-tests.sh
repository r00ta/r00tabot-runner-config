SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

exec_and_check() {
  lxc exec $CONTAINER_NAME --user 1000 --cwd /home/ubuntu/tests -- sh -c "$1"
  if [ $? -ne 0 ]; then
    echo "Command '$1' failed"
    exit 1
  fi
}


lxc exec $CONTAINER_NAME --user 0 -- snap install jq --classic
lxc file push -r $SCRIPT_DIR/../tests $CONTAINER_NAME/home/ubuntu
lxc exec $CONTAINER_NAME --cwd /home/ubuntu --user 0 -- chown -R ubuntu:ubuntu tests
lxc exec $CONTAINER_NAME --user 0 --cwd /home/ubuntu/ -- chmod +x -R /home/ubuntu/tests
lxc exec $CONTAINER_NAME --user 0 --cwd /tmp/ -- sh -c "printf \"\$(maas apikey --username maas)\" > api-key-file"

# Execute the commands and check for failures
exec_and_check "SUBNET_PREFIX=$SUBNET_PREFIX ./00-setup.sh"
lxc start vm01-$SUBNET_PREFIX
if [ $? -ne 0 ]; then
    echo "Command 'lxc start vm01-$SUBNET_PREFIX' failed"
    exit 1
fi
exec_and_check "SUBNET_PREFIX=$SUBNET_PREFIX ./01-enlist.sh"
exec_and_check "./02-commission.sh"
exec_and_check "./03-deploy.sh"
exec_and_check "./04-ssh.sh"
exec_and_check "./05-release.sh"


