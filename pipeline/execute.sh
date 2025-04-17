#!/bin/bash
set -euo pipefail

# Resolve the directory this script is in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Usage message
usage() {
    echo "Usage: $0 --maas_dir <directory>"
    exit 1
}

# Parse arguments
parse_args() {
    local args=("$@")
    while [[ ${#args[@]} -gt 0 ]]; do
        case "${args[0]}" in
            --maas_dir)
                MAAS_DIR="${args[1]:-}"
                [[ -z "$MAAS_DIR" ]] && usage
                shift 2
                ;;
            *)
                echo "Unknown parameter passed: ${args[0]}"
                usage
                ;;
        esac
    done
}


run_install() {
    if [[ "$TYPE" == "deb" ]]; then
        "$SCRIPT_DIR/02-deb-install.sh"
    else
        "$SCRIPT_DIR/02-snap-install.sh"
    fi
}
run_cleanup() {
    if [[ "$TYPE" == "deb" ]]; then
        "$SCRIPT_DIR/99-deb-cleanup.sh"
    else
        "$SCRIPT_DIR/99-snap-cleanup.sh"
    fi
}

# Run a test suite and cleanup afterward
run_test() {
    run_install
    local test_script="$1"
    "$SCRIPT_DIR/../tests/$test_script/execute.sh"
    run_cleanup
}

main() {
    parse_args "$@"
    export MAAS_DIR

    # Setup
    "$SCRIPT_DIR/00-setup-machine.sh"

    # Build/create
    if [[ "${TYPE:-}" == "deb" ]]; then
        "$SCRIPT_DIR/01-deb-create.sh"
    else
        "$SCRIPT_DIR/01-snap-create.sh"
    fi

    # Run tests
    run_test "00_machine_lifecycle"
    run_test "01_vault"
}

main "$@"