#! /bin/bash

retry_until_success_contains() {
  local maas_command="$1"
  local status_to_check="$2"
  local max_wait_time=600
  local sleep_interval=10
  local elapsed_time=0

  while [ $elapsed_time -lt $max_wait_time ]; do
    output=$(eval "$maas_command" 2>&1)
    echo "$output"

    if echo "$output" | grep -q "$status_to_check"; then
      echo "Success: Found expected output."
      return 0
    fi

    echo "Waiting... ($elapsed_time/$max_wait_time seconds elapsed)"
    sleep $sleep_interval
    elapsed_time=$((elapsed_time + sleep_interval))
  done

  echo "Timeout reached. Desired output not found."
  return 1
}

retry_until_success() {
  local maas_command="$1"
  local status_to_check="$2"
  local max_wait_time=600
  local sleep_interval=10
  local elapsed_time=0

  while [ $elapsed_time -lt $max_wait_time ]; do
    output=$(eval "$maas_command")
    if [ "$output" = "$status_to_check" ]; then
      echo "Success!"
      return 0  # Success
    fi
    sleep $sleep_interval
    elapsed_time=$((elapsed_time + sleep_interval))
  done

  echo "Timeout reached. Importing may not be complete."
  return 1  # Timeout
}

function get_first_system_id_with_timeout {
    local max_wait_time=600
    local sleep_interval=10
    local elapsed_time=0
    local system_ids

    while [ $elapsed_time -lt $max_wait_time ]; do
	system_ids=$(maas admin machines read | jq -r ".[] | .system_id")

        if [ -n "$system_ids" ]; then
            echo "$system_ids" | head -n 1
            return 0
        fi

        sleep $sleep_interval
        elapsed_time=$((elapsed_time + sleep_interval))
    done

    echo "No system_id found after $max_wait_time seconds"
    return 1
}


function wait_for_status {
    local system_id="$1"
    local status="$2"
    local max_wait_time=600
    local sleep_interval=10
    local elapsed_time=0

    while [ $elapsed_time -lt $max_wait_time ]; do
        machine_info=$(maas admin machine read "$system_id")

        status_name=$(echo "$machine_info" | jq -r ".status_name")

        if [ "$status_name" == "$status" ]; then
            return 0
        fi

        sleep $sleep_interval
        elapsed_time=$((elapsed_time + sleep_interval))
    done

    return 1
}
