SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

exec_and_check() {
  "$@"
  if [ $? -ne 0 ]; then
    echo "Command '$*' failed"
    exit 1
  fi
}

# Execute the commands and check for failures
exec_and_check "$SCRIPT_DIR/../00-setup.sh"
exec_and_check "$SCRIPT_DIR/01-setupvault.sh"
exec_and_check "$SCRIPT_DIR/02-checksecrets.sh"
exec_and_check "$SCRIPT_DIR/03-cleanup.sh"


