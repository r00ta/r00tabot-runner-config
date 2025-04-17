SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

exec_and_check() {
  sh -c "$1"
  if [ $? -ne 0 ]; then
    echo "Command '$1' failed"
    exit 1
  fi
}

# Execute the commands and check for failures
exec_and_check "../00-setup.sh"
exec_and_check "./01-enlist.sh"
exec_and_check "./02-commission.sh"
exec_and_check "./03-deploy.sh"
exec_and_check "./04-ssh.sh"
exec_and_check "./05-release.sh"

