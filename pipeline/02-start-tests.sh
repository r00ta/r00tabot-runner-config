exec_and_check() {
  sh -c "$1"
  if [ $? -ne 0 ]; then
    echo "Command '$1' failed"
    exit 1
  fi
}


sh -c "printf \"\$(maas apikey --username maas)\" > /tmp/api-key-file"

cd $SCRIPT_DIR/../tests/
# Execute the commands and check for failures
exec_and_check "./00-setup.sh"
lxc start vm01
if [ $? -ne 0 ]; then
    echo "Command 'lxc start vm01 failed"
    exit 1
fi
exec_and_check "./01-enlist.sh"
exec_and_check "./02-commission.sh"
exec_and_check "./03-deploy.sh"
exec_and_check "./04-ssh.sh"
exec_and_check "./05-release.sh"


